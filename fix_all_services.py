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
    
    # Stream output
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
    
    print("\n--- 1. DEPLOYING POSTGRESQL (Port 2905) ---")
    # URL: postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db
    # User: physio_db
    # Pass: 290503Sang.
    # DB: physio_db
    # Port: 2905
    
    db_script = """
    docker stop postgres_db || true
    docker rm postgres_db || true
    
    docker run -d \
      --name postgres_db \
      --restart unless-stopped \
      -p 2905:5432 \
      -e POSTGRES_USER=physio_db \
      -e POSTGRES_PASSWORD=290503Sang. \
      -e POSTGRES_DB=physio_db \
      postgres:15-alpine
      
    echo "Waiting for DB to start..."
    sleep 10
    docker logs postgres_db --tail 10
    """
    execute_command(client, db_script)
    
    print("\n--- 2. UPGRADING LASOTUVI TO PYTHON 3.10 ---")
    # Upgrade Dockerfile to Py3.10, install GCC, and remove problematic old libs
    tuvi_upgrade_script = """
    cd /root/lasotuvi
    
    cat > Dockerfile <<EOF
FROM python:3.10-slim

WORKDIR /app

# Install Build Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip

# Remove legacy/dev dependencies that break on new Python or aren't needed
RUN sed -i '/mypy/d' requirements.txt && \
    sed -i '/typed-ast/d' requirements.txt && \
    sed -i '/pytest/d' requirements.txt && \
    sed -i '/pluggy/d' requirements.txt && \
    sed -i '/py==/d' requirements.txt && \
    sed -i '/ephem/d' requirements.txt

# Re-add ephem (latest version compatible with Py3.10) manually
# Note: We removed the fixed version line above, now installing latest
RUN pip install ephem

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Set Python Path
ENV PYTHONPATH=/app

EXPOSE 8000
CMD ["uvicorn", "lasotuvi.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

    docker build -t lasotuvi-api .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      --env-file /root/lasotuvi/.env \
      lasotuvi-api
    """
    execute_command(client, tuvi_upgrade_script)
    
    print("\n--- 3. RESTARTING BACKEND ---")
    # Backend config should be fine now that DB is up, but let's ensure no quoting issues
    # Clean .env again just in case
    be_fix_script = """
    sed -i 's/"//g' /root/glowlab_backend/.env
    docker restart glowlab_backend
    """
    execute_command(client, be_fix_script)
    
    print("\n--- FINAL HEALTH CHECK ---")
    execute_command(client, "docker ps")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
