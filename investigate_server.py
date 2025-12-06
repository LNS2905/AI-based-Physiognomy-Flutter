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

    print("\n--- CHECKING INSTALLED TOOLS ---")
    execute_command(client, "which docker")
    execute_command(client, "which pm2")
    execute_command(client, "which node")
    execute_command(client, "which python3")
    execute_command(client, "java -version")

    print("\n--- CHECKING DIRECTORIES ---")
    execute_command(client, "ls -F /")
    execute_command(client, "ls -F /home")
    execute_command(client, "ls -F /root")
    execute_command(client, "ls -F /var/www")

    print("\n--- CHECKING RUNNING PROCESSES ---")
    execute_command(client, "ps aux | head -n 20")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
