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
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    if output: print(f"STDOUT:\n{output}")
    if error: print(f"STDERR:\n{error}")
    return output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    # The error persists despite everything. 
    # The container starts, loads the file, and crashes.
    # This implies the file inside the container still has the bad content.
    # Let's debug the container file system directly by creating a container that sleeps, 
    # checking the file, and then running the app.
    
    print("\n--- DEBUGGING CONTAINER FILES ---")
    
    debug_script = """
    # Create a debug Dockerfile entrypoint
    cd /root/lasotuvi
    
    cat > Dockerfile <<EOF
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev build-essential && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --upgrade pip
RUN sed -i '/mypy/d' requirements.txt && sed -i '/typed-ast/d' requirements.txt && sed -i '/pytest/d' requirements.txt && sed -i '/pluggy/d' requirements.txt && sed -i '/py==/d' requirements.txt && sed -i '/ephem/d' requirements.txt
RUN pip install ephem
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PYTHONPATH=/app
EXPOSE 8000
# Debug CMD: Print the database_pg.py file then run
CMD sh -c "cat /app/lasotuvi/api/database_pg.py | grep DATABASE_URL && uvicorn lasotuvi.api.main:app --host 0.0.0.0 --port 8000"
EOF

    docker build --no-cache -t lasotuvi-debug .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi -p 8000:8000 lasotuvi-debug
    """
    execute_command(client, debug_script)
    
    print("\n--- CHECKING DEBUG LOGS ---")
    time.sleep(5)
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
