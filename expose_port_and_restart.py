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
    
    print("\n--- EXPOSING PORT 8000 ---")
    # Replace 127.0.0.1:8000:8000 with 8000:8000
    fix_cmd = "sed -i 's/127.0.0.1:8000:8000/8000:8000/g' /root/AIPhysiognomy/docker-compose.yml"
    execute_command(client, fix_cmd)
    
    print("\n--- RESTARTING CONTAINER ---")
    cmd_up = "cd /root/AIPhysiognomy && /usr/local/bin/docker-compose up -d"
    execute_command(client, cmd_up)
    
    print("\n--- FINAL NETWORK CHECK ---")
    execute_command(client, "netstat -tulpn | grep 8000")
    execute_command(client, "docker ps")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
