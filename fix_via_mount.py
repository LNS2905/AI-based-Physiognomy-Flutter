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
    
    print("\n--- 1. VERIFYING HOST FILE CONTENT ---")
    # Check if the file on host definitely has NO quotes around the URL
    execute_command(client, "grep 'DATABASE_URL =' /root/lasotuvi/lasotuvi/api/database_pg.py")
    
    print("\n--- 2. STARTING LASOTUVI WITH VOLUME MOUNT ---")
    # Mount the host file to overwrite the container file at runtime
    # Also ensure we are using the image we built, or just lasotuvi-api:latest
    
    cmd_tuvi = """
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      -v /root/lasotuvi/lasotuvi/api/database_pg.py:/app/lasotuvi/api/database_pg.py \
      lasotuvi-api
    """
    execute_command(client, cmd_tuvi)
    
    print("\n--- 3. STARTING BACKEND WITH VOLUME MOUNT ---")
    # Ensure .env is mounted to avoid any copy/cache issues
    cmd_be = """
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      -v /root/glowlab_backend/.env:/app/.env \
      glowlab-backend
    """
    execute_command(client, cmd_be)
    
    print("\n--- 4. CHECKING LOGS ---")
    time.sleep(5)
    print(">>> LasoTuvi Logs:")
    execute_command(client, "docker logs lasotuvi --tail 20")
    print(">>> Backend Logs:")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
