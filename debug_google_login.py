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
    
    print("\n--- BACKEND LOGS ---")
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    print("\n--- GOOGLE CONNECTIVITY CHECK ---")
    execute_command(client, "docker exec glowlab_backend ping -c 3 accounts.google.com")
    
    print("\n--- ENV CHECK ---")
    # Show partial env (hide full secret but show start/end) to verify structure
    execute_command(client, "cat /root/glowlab_backend/.env | grep GOOGLE_")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
