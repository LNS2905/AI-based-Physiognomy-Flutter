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
    
    print("\n--- CHECKING PROJECT FILES ---")
    execute_command(client, "ls -R /root/lasotuvi | grep main.py")
    execute_command(client, "ls -F /root/lasotuvi")
    
    print("\n--- REBUILDING LASOTUVI ---")
    # Use a generic command first to just keep container running, so we can explore if needed
    # Or try to find the right path based on LS output above.
    # Assuming structure: lasotuvi/lasotuvi/api/main.py based on LS output earlier?
    
    # Let's do a safe build first that lists files on run
    build_script = """
    cd /root/lasotuvi
    
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Debug: List files to find main.py
CMD ["find", ".", "-name", "main.py"]
EOF

    docker build -t lasotuvi-debug .
    docker run --rm lasotuvi-debug
    """
    execute_command(client, build_script)
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
