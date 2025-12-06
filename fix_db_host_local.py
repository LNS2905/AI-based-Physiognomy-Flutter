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
    
    # Change 160.250.180.132 -> 172.17.0.1 in both files
    # Host gateway IP in Docker is usually 172.17.0.1
    
    print("\n--- UPDATING DB HOST TO LOCAL DOCKER IP ---")
    
    # 1. LasoTuvi Code
    cmd_tuvi = "sed -i 's/160.250.180.132/172.17.0.1/g' /root/lasotuvi/lasotuvi/api/database_pg.py"
    execute_command(client, cmd_tuvi)
    
    # 2. Backend Env
    cmd_be = "sed -i 's/160.250.180.132/172.17.0.1/g' /root/glowlab_backend/.env"
    execute_command(client, cmd_be)
    
    print("\n--- RESTARTING WITH MOUNTS ---")
    
    # We must restart with mounts to ensure changes are picked up
    cmd_restart = """
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      -v /root/lasotuvi/lasotuvi/api/database_pg.py:/app/lasotuvi/api/database_pg.py \
      lasotuvi-api
      
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      -v /root/glowlab_backend/.env:/app/.env \
      glowlab-backend
    """
    execute_command(client, cmd_restart)
    
    print("\n--- FINAL CHECK ---")
    time.sleep(8) # Wait for startup
    print(">>> LasoTuvi Logs:")
    execute_command(client, "docker logs lasotuvi --tail 20")
    print(">>> Backend Logs:")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
