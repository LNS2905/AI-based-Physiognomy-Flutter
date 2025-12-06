import paramiko
import sys
import time

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n[REMOTE] Executing: {command}")
    stdin, stdout, stderr = ssh.exec_command(command)
    
    # Wait for exit
    exit_status = stdout.channel.recv_exit_status()
    
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    
    print(f"--- STDOUT ---\n{output}")
    print(f"--- STDERR ---\n{error}")
    print(f"--- EXIT CODE: {exit_status} ---")
    return output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    execute_command(client, "uname -a")
    execute_command(client, "dpkg -l | grep docker")
    execute_command(client, "which docker")
    # List docker binary explicitly
    execute_command(client, "ls -l /usr/bin/docker")
    # List files in package
    execute_command(client, "dpkg -L docker.io | grep /usr/bin/")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
