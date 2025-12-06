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
    
    print("\n--- INSTALLING DOCKER VIA APT ---")
    cmds = [
        "apt-get update",
        "apt-get install -y docker.io docker-compose"
    ]
    
    for cmd in cmds:
        execute_command(client, f"export DEBIAN_FRONTEND=noninteractive; {cmd}")
    
    print("\n--- STARTING DOCKER ---")
    execute_command(client, "systemctl start docker")
    execute_command(client, "systemctl enable docker")
    
    print("\n--- VERIFYING ---")
    execute_command(client, "docker --version")
    execute_command(client, "docker-compose --version")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
