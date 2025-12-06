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
    
    print("\n--- SEARCHING FOR FASTAPI APP ---")
    # Create a temporary container to search files
    search_script = """
    cd /root/lasotuvi
    
    cat > Dockerfile <<EOF
FROM python:3.8-slim
WORKDIR /app
COPY . .
CMD ["grep", "-r", "FastAPI", "."]
EOF

    docker build -t lasotuvi-search .
    docker run --rm lasotuvi-search
    """
    execute_command(client, search_script)
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
