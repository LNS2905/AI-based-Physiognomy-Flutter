import paramiko
import time
import sys

# Force UTF-8 output for Windows consoles if possible
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n[REMOTE] Executing: {command}")
    # Try to source environment variables
    full_command = f"source /etc/profile; source ~/.bashrc; {command}"
    
    # Note: exec_command runs in a new session each time usually, but paramiko might hold it open if we used invoke_shell.
    # Here we use exec_command which is one-off. So we must source every time.
    
    stdin, stdout, stderr = ssh.exec_command(full_command)
    # Wait for command to finish
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    
    if output:
        print(f"Output:\n{output}")
    if error:
        print(f"Error/Stderr:\n{error}")
    return output

def restart_service(ssh, port, name_hint):
    print(f"\n>>> Processing Service on Port {port} ({name_hint})")
    
    # Find ID by port
    cmd_find_port = f"docker ps -a | grep :{port} | awk '{{print $1}}' | head -n 1"
    container_id = execute_command(ssh, cmd_find_port)
    
    if not container_id:
        print(f"   Container on port {port} not found. Trying name '{name_hint}'...")
        cmd_find_name = f"docker ps -a --filter 'name={name_hint}' --format '{{{{.ID}}}}' | head -n 1"
        container_id = execute_command(ssh, cmd_find_name)
        
    if container_id:
        print(f"   Found Container ID: {container_id}")
        print("   Restarting...")
        execute_command(ssh, f"docker restart {container_id}")
        print("   Checking logs...")
        execute_command(ssh, f"docker logs {container_id} --tail 10")
    else:
        print(f"   FAILED: Could not find container for Port {port} or Name {name_hint}")

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    print("Connected successfully.")

    print("\n--- CHECKING ENVIRONMENT ---")
    execute_command(client, "echo $PATH")
    execute_command(client, "which docker")
    # Try to find docker manually if which fails
    execute_command(client, "ls -l /usr/bin/docker /usr/local/bin/docker /snap/bin/docker")

    print("\n--- CHECKING INITIAL STATUS ---")
    execute_command(client, "uptime")
    execute_command(client, "docker ps -a")

    # Restart All Services
    restart_service(client, 3000, "glowlab_backend")
    restart_service(client, 8000, "lasotuvi")
    restart_service(client, 8001, "physiognomy")

    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")

    client.close()

except ImportError:
    print("Error: 'paramiko' library not found.")
except Exception as e:
    print(f"An error occurred: {e}")
