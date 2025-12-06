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
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    if output:
        print(f"Output:\n{output}")
    if error:
        print(f"Error/Stderr:\n{error}")
    return output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)

    print("\n--- CHECKING /opt/ DIRECTORY ---")
    execute_command(client, "ls -F /opt/")
    
    # Check specific likely folders
    execute_command(client, "ls -F /opt/physiognomy-api/")
    execute_command(client, "ls -F /opt/glowlab/")
    execute_command(client, "ls -F /opt/backend/")
    execute_command(client, "ls -F /opt/tuvi/")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
