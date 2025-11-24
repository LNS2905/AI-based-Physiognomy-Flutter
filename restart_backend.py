                    import paramiko
import time

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n--- Executing: {command} ---")
    stdin, stdout, stderr = ssh.exec_command(command)
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    
    if output:
        print(f"Output:\n{output}")
    if error:
        print(f"Error:\n{error}")
    return output, error

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    print("Connected successfully.")

    print("\nRestarting glowlab_backend container...")
    execute_command(client, "docker restart glowlab_backend")
    
    print("\nWaiting for container to start (10s)...")
    time.sleep(10)
    
    print("\nChecking container status...")
    execute_command(client, "docker ps | grep glowlab_backend")
    
    print("\nChecking logs for startup errors...")
    execute_command(client, "docker logs glowlab_backend --tail 20")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")