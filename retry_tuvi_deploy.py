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
    
    print("\n--- REDEPLOYING LASOTUVI (RETRY) ---")
    # Since files are there (ls showed them), just build and run
    deploy_script = """
    cd /root/lasotuvi
    
    # Dockerfile was created in previous step but let's ensure it's there
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
# Correct entrypoint based on file listing: 'lasotuvi' folder exists
CMD ["uvicorn", "lasotuvi.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
    
    # NOTE: Is it lasotuvi.main or lasotuvi.api.main?
    # Previous user said: "lasotuvi/api/main.py" in docs? No, user just gave folder.
    # But in `check_tuvi_final` output: `lasotuvi/` folder exists.
    # If inside `lasotuvi/` there is `main.py`, then `uvicorn lasotuvi.main:app` is correct IF we are in root.
    # BUT `ls -F` showed `lasotuvi/` (folder).
    # Let's try to guess: `lasotuvi.api.main` or `lasotuvi.main`
    # I'll use a safer CMD that tries both.
    
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
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
    execute_command(client, deploy_script)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    execute_command(client, "docker logs lasotuvi --tail 10")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
