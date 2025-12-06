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
    
    print("\n--- FIXING LASOTUVI BUILD (PYTHON 3.8 & COMPATIBILITY) ---")
    # Downgrade to Python 3.8 (better compatibility for old typed-ast)
    # Remove typed-ast from requirements if possible? It's usually a dev dep for mypy.
    # But since we can't edit requirements easily, let's just try Py3.8 first.
    
    fix_py38_script = """
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

# Upgrade pip first
RUN pip install --upgrade pip

# Try to install typed-ast explicitly if needed, or just run requirements
# Note: mypy 0.580 is VERY old (2018), likely causing the issue.
# If installation fails, we might need to remove mypy/typed-ast from requirements via sed
# because they are likely Dev dependencies not needed for Runtime.

# Attempt 1: Remove mypy/typed-ast/pytest from requirements (Dev deps)
RUN sed -i '/mypy/d' requirements.txt && \
    sed -i '/typed-ast/d' requirements.txt && \
    sed -i '/pytest/d' requirements.txt && \
    sed -i '/pluggy/d' requirements.txt && \
    sed -i '/py==/d' requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn lasotuvi.api.main:app --host 0.0.0.0 --port 8000 || uvicorn lasotuvi.main:app --host 0.0.0.0 --port 8000 || uvicorn main:app --host 0.0.0.0 --port 8000"]
EOF

    docker build -t lasotuvi-api .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      lasotuvi-api
    """
    execute_command(client, fix_py38_script)
    
    print("\n--- FINAL CHECK ---")
    execute_command(client, "docker ps")
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
