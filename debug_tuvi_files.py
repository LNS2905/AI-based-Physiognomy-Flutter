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
    
    # Based on previous LS locally: C:\Code\lasotuvi-private\lasotuvi\api\main.py might NOT be there?
    # Wait, local LS showed:
    # d----- 11/9/2025 8:08 AM lasotuvi
    # And inside that folder might be api/main.py?
    # The debug run above outputted NOTHING for find main.py. This means main.py is MISSING or not in the zip correctly.
    
    print("\n--- LISTING ALL FILES IN LASOTUVI CONTAINER ---")
    debug_script = """
    cd /root/lasotuvi
    
    # Rebuild with ls -R to see what we actually have
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY . .
CMD ["ls", "-R"]
EOF
    
    docker build -t lasotuvi-ls .
    docker run --rm lasotuvi-ls
    """
    execute_command(client, debug_script)
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
