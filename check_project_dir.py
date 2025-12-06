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
    
    if output:
        print(f"Output:\n{output}")
    if error:
        print(f"Error/Stderr:\n{error}")

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    print("Connected successfully.")

    print("\n--- LISTING PROJECT DIRECTORY ---")
    execute_command(client, "ls -la /root/AIPhysiognomy/")
    
    print("\n--- CHECKING FOR DOCKER COMPOSE ---")
    execute_command(client, "ls -la /root/AIPhysiognomy/docker-compose.yml")
    execute_command(client, "cat /root/AIPhysiognomy/docker-compose.yml")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
