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
    
    print("\n--- FIXING DOCKER-COMPOSE.YML ---")
    # Prepend version: '3' to the file
    fix_cmd = "sed -i '1s/^/version: \"3\"\\n/' /root/AIPhysiognomy/docker-compose.yml"
    execute_command(client, fix_cmd)
    
    print("\n--- DEPLOYING PHYSIOGNOMY API ---")
    cmd_up = "cd /root/AIPhysiognomy && docker-compose up -d --build"
    execute_command(client, cmd_up)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    execute_command(client, "netstat -tulpn | grep 8000")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
