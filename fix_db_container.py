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
    
    # Error: No such container: postgres_db
    # The DB container might have stopped or been removed.
    # Let's restart it and connect to network.
    
    print("\n--- RESTARTING DB AND CONNECTING TO NETWORK ---")
    db_script = """
    docker stop postgres_db || true
    docker rm postgres_db || true
    
    docker run -d \
      --name postgres_db \
      --restart unless-stopped \
      --network app_network \
      -p 2905:5432 \
      -e POSTGRES_USER=physio_db \
      -e POSTGRES_PASSWORD=290503Sang. \
      -e POSTGRES_DB=physio_db \
      postgres:15-alpine
      
    echo "Waiting for DB startup..."
    sleep 10
    """
    execute_command(client, db_script)
    
    print("\n--- RESTARTING SERVICES ---")
    execute_command(client, "docker restart lasotuvi glowlab_backend")
    
    print("\n--- FINAL CHECK ---")
    time.sleep(10)
    print(">>> LasoTuvi Logs:")
    execute_command(client, "docker logs lasotuvi --tail 20")
    print(">>> Backend Logs:")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
