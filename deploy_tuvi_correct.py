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
    
    print("\n--- REDEPLOYING LASOTUVI (CORRECT PATH) ---")
    # Found path: ./lasotuvi/api/main.py -> lasotuvi.api.main:app
    # Requirements: Python 3.8 (for compat) + gcc (for ephem)
    
    final_deploy_script = """
    cd /root/lasotuvi
    
    cat > Dockerfile <<EOF
FROM python:3.8-slim

WORKDIR /app

# Install Build Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip

# Remove dev dependencies that cause issues
RUN sed -i '/mypy/d' requirements.txt && \
    sed -i '/typed-ast/d' requirements.txt && \
    sed -i '/pytest/d' requirements.txt && \
    sed -i '/pluggy/d' requirements.txt && \
    sed -i '/py==/d' requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Set Python Path to include root so lasotuvi package is found
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
      lasotuvi-api
    """
    execute_command(client, final_deploy_script)
    
    print("\n--- FINAL STATUS CHECK ---")
    execute_command(client, "docker ps")
    time.sleep(5)
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
