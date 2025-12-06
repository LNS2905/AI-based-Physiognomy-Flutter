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
    
    print("\n--- STARTING PHYSIOGNOMY API ---")
    # Ensure docker service is running
    execute_command(client, "systemctl start docker")
    
    # Deploy
    cmd_up = "cd /root/AIPhysiognomy && docker-compose up -d --build"
    execute_command(client, cmd_up)
    
    print("\n--- SEARCHING FOR OTHER PROJECTS ---")
    # Search for package.json (Node) or main.py (Python) in /root but exclude known AIPhysiognomy
    # Also check /home just in case
    find_cmd = "find /root /home -maxdepth 4 -name package.json -o -name main.py | grep -v AIPhysiognomy"
    execute_command(client, find_cmd)
    
    print("\n--- FINAL DOCKER STATUS ---")
    execute_command(client, "docker ps")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
