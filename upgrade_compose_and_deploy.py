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
    
    print("\n--- UPGRADING DOCKER COMPOSE ---")
    # Download latest
    dl_cmd = 'curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
    execute_command(client, dl_cmd)
    execute_command(client, "chmod +x /usr/local/bin/docker-compose")
    
    print("\n--- VERIFYING VERSION ---")
    execute_command(client, "/usr/local/bin/docker-compose --version")
    
    print("\n--- DEPLOYING PHYSIOGNOMY API ---")
    # Force use of new binary
    cmd_up = "cd /root/AIPhysiognomy && /usr/local/bin/docker-compose up -d --build"
    execute_command(client, cmd_up)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
