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
    
    # Try to start it first to generate fresh logs if it was stopped
    print("\n--- ATTEMPTING START ---")
    execute_command(client, "docker start lasotuvi")
    
    print("\n--- CHECKING LOGS ---")
    # Get logs even if it crashed immediately
    execute_command(client, "docker logs lasotuvi --tail 50")
    
    print("\n--- CHECKING FILE STRUCTURE ---")
    # Check where main.py actually is
    execute_command(client, "docker run --rm lasotuvi-api find . -maxdepth 4 -name main.py")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
