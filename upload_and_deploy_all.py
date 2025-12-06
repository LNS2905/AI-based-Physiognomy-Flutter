import paramiko
import os
import sys
import time

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n[REMOTE] Executing: {command}")
    stdin, stdout, stderr = ssh.exec_command(command)
    
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode('utf-8', errors='replace'), end='')
        if stderr.channel.recv_ready():
            print(stderr.channel.recv(1024).decode('utf-8', errors='replace'), end='')
        time.sleep(0.1)
        
    exit_status = stdout.channel.recv_exit_status()
    return exit_status

def upload_file(sftp, local_path, remote_path):
    print(f"\n[UPLOAD] {local_path} -> {remote_path}")
    sftp.put(local_path, remote_path)
    print("Upload complete.")

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    sftp = client.open_sftp()
    
    # --- 1. DEPLOY GLOWLAB BACKEND (NodeJS) ---
    print("\n=== DEPLOYING GLOWLAB BACKEND ===")
    execute_command(client, "mkdir -p /root/glowlab_backend")
    upload_file(sftp, "ai-physio-be.zip", "/root/glowlab_backend/source.zip")
    
    script_be = """
    cd /root/glowlab_backend
    
    # Install unzip if missing
    if ! command -v unzip &> /dev/null; then apt-get install -y unzip; fi
    
    echo "Unzipping..."
    unzip -o source.zip
    rm source.zip
    
    echo "Checking Dockerfile..."
    if [ ! -f Dockerfile ]; then
        echo "Creating Dockerfile for NodeJS..."
        cat > Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF
    fi
    
    echo "Building Image..."
    docker build -t glowlab-backend .
    
    echo "Stopping old container..."
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    
    echo "Starting Container..."
    # Assuming .env is needed, check if exists, else copy example
    if [ ! -f .env ]; then cp .env.example .env; fi
    
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      --env-file .env \
      glowlab-backend
      
    echo "Backend Deployed."
    """
    execute_command(client, script_be)
    
    # --- 2. DEPLOY LASOTUVI (FastAPI) ---
    print("\n=== DEPLOYING LASOTUVI ===")
    execute_command(client, "mkdir -p /root/lasotuvi")
    upload_file(sftp, "lasotuvi.zip", "/root/lasotuvi/source.zip")
    
    script_tuvi = """
    cd /root/lasotuvi
    
    echo "Unzipping..."
    unzip -o source.zip
    rm source.zip
    
    echo "Checking Dockerfile..."
    # Ensure Dockerfile exists (sometimes it's missing in zip root)
    if [ ! -f Dockerfile ]; then
        echo "Creating Dockerfile for FastAPI..."
        cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "lasotuvi.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
    fi
    
    echo "Building Image..."
    docker build -t lasotuvi-api .
    
    echo "Stopping old container..."
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    
    echo "Starting Container (Port 8001 -> 8000 internal)..."
    # Map host 8001 to container 8000 because 8000 is taken by Physiognomy API?
    # User said old config: LasoTuvi API http://160.250.180.132:8000
    # Wait, Physiognomy API uses 8000 right now?
    # Let's check netstat first.
    """
    
    # CHECK PORT CONFLICT
    print("\nChecking Port 8000 usage...")
    execute_command(client, "netstat -tulpn | grep 8000")
    
    # If 8000 is taken by Physiognomy, we must use another port OR move Physiognomy.
    # User request: "Lasotuvi API http://160.250.180.132:8000"
    # But currently Physiognomy is on 8000.
    # I will deploy Lasotuvi on 8001 temporarily and inform user, OR swap them.
    # User said: "Physiognomy API http://160.250.180.132:8001 , LasoTuvi API http://160.250.180.132:8000"
    
    # CORRECT PLAN:
    # 1. Stop Physiognomy on 8000.
    # 2. Re-deploy Physiognomy on 8001.
    # 3. Deploy Lasotuvi on 8000.
    
    print("\n--- RECONFIGURING PORTS ---")
    
    reconfig_script = """
    # 1. Move Physiognomy to 8001
    echo "Moving Physiognomy to 8001..."
    cd /root/AIPhysiognomy
    sed -i 's/8000:8000/8001:8000/g' docker-compose.yml
    docker-compose up -d --force-recreate
    
    # 2. Deploy Lasotuvi on 8000
    cd /root/lasotuvi
    echo "Deploying Lasotuvi on 8000..."
    docker build -t lasotuvi-api .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      lasotuvi-api
    """
    execute_command(client, reconfig_script)

    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    
    sftp.close()
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
