import paramiko
import sys

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
    
    print("\n--- CHECKING CONNECTIVITY ---")
    execute_command(client, "ping -c 3 google.com")
    
    print("\n--- FIXING DNS ---")
    execute_command(client, "echo 'nameserver 8.8.8.8' > /etc/resolv.conf")
    
    print("\n--- RESTARTING DOCKER ---")
    execute_command(client, "systemctl restart docker")
    
    print("\n--- MANUAL PULL IMAGE ---")
    execute_command(client, "docker pull python:3.11-slim")
    
    print("\n--- DEPLOYING PHYSIOGNOMY API ---")
    cmd_up = "cd /root/AIPhysiognomy && /usr/local/bin/docker-compose up -d --build"
    execute_command(client, cmd_up)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
