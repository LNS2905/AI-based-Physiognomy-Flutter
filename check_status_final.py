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
    
    print("\n--- FINAL CONTAINER STATUS ---")
    execute_command(client, "docker ps")
    
    print("\n--- CHECKING PORT 8000 ---")
    execute_command(client, "netstat -tulpn | grep 8000")
    
    print("\n--- CHECKING LOGS ---")
    execute_command(client, "cd /root/AIPhysiognomy && /usr/local/bin/docker-compose logs --tail 20")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
