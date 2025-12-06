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
        time.sleep(1)
        
    exit_status = stdout.channel.recv_exit_status()
    return exit_status

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    print("\n--- CHECKING DOCKER BINARY ---")
    execute_command(client, "ls -l /usr/bin/docker")
    execute_command(client, "/usr/bin/docker --version")

    print("\n--- DEPLOYING PHYSIOGNOMY API (Port 8000) ---")
    # Use full path to docker-compose just in case
    # Also apt installed docker-compose 1.25 (python based), likely /usr/bin/docker-compose
    cmd_deploy = "cd /root/AIPhysiognomy && /usr/bin/docker-compose up -d --build"
    execute_command(client, cmd_deploy)
    
    print("\n--- CHECKING RUNNING CONTAINERS ---")
    execute_command(client, "/usr/bin/docker ps")
    
    print("\n--- SEARCHING FOR MISSING SERVICES (lasotuvi, backend) ---")
    # Look for package.json or main.py that might belong to other projects
    # Exclude AIPhysiognomy to reduce noise
    find_cmd = "find /root -name package.json -o -name main.py -o -name app.js | grep -v AIPhysiognomy"
    execute_command(client, find_cmd)

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
