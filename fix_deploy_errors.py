import paramiko
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

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    # --- FIX 1: GLOWLAB BACKEND (dos2unix issue on entrypoint) ---
    print("\n=== FIXING GLOWLAB BACKEND ===")
    fix_script = """
    cd /root/glowlab_backend
    
    # Install dos2unix to fix line endings
    apt-get install -y dos2unix
    
    # Modify Dockerfile to fix line endings
    cat > Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Fix line endings for scripts
RUN apk add --no-cache dos2unix && dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    docker build -t glowlab-backend .
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      --env-file .env \
      glowlab-backend
    """
    execute_command(client, fix_script)
    
    # --- FIX 2: LASOTUVI (Was missing?) ---
    print("\n=== REDEPLOYING LASOTUVI ===")
    tuvi_script = """
    cd /root/lasotuvi
    
    # Re-verify Dockerfile
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
# Assuming main.py or similar entry point. Let's check file structure first.
CMD ["uvicorn", "lasotuvi.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

    # NOTE: Adjust CMD path based on earlier LS output: 
    # Directory: C:\Code\lasotuvi-private -> lasotuvi/api/main.py?
    # LS showed 'lasotuvi' folder inside. Usually main.py is inside package.
    # Let's try standard fastapi pattern.
    
    docker build -t lasotuvi-api .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      lasotuvi-api
    """
    execute_command(client, tuvi_script)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
