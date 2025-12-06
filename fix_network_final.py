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
    
    # Connection refused at 172.17.0.1:2905
    # Because DB is mapped to 2905 on HOST, but listening on 5432 inside container.
    # 172.17.0.1 is host bridge IP.
    # Standard way: Create a network, put everyone in it, use container name and internal port (5432).
    
    print("\n--- CREATING DOCKER NETWORK ---")
    execute_command(client, "docker network create app_network || true")
    
    print("\n--- CONNECTING DB TO NETWORK ---")
    execute_command(client, "docker network connect app_network postgres_db || true")
    
    print("\n--- UPDATING CONFIG TO USE CONTAINER NAME & PORT 5432 ---")
    # DB Host: postgres_db
    # DB Port: 5432 (Internal)
    
    # 1. LasoTuvi: update code
    # Replace 172.17.0.1:2905 -> postgres_db:5432
    cmd_tuvi = "sed -i 's/172.17.0.1:2905/postgres_db:5432/g' /root/lasotuvi/lasotuvi/api/database_pg.py"
    execute_command(client, cmd_tuvi)
    
    # 2. Backend: update env
    cmd_be = "sed -i 's/172.17.0.1:2905/postgres_db:5432/g' /root/glowlab_backend/.env"
    execute_command(client, cmd_be)
    
    print("\n--- RESTARTING APPS IN NETWORK ---")
    
    # Stop old
    execute_command(client, "docker stop lasotuvi glowlab_backend || true")
    execute_command(client, "docker rm lasotuvi glowlab_backend || true")
    
    # Run with --network app_network
    cmd_run = """
    # LasoTuvi
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      --network app_network \
      -p 8000:8000 \
      -v /root/lasotuvi/lasotuvi/api/database_pg.py:/app/lasotuvi/api/database_pg.py \
      lasotuvi-api
      
    # Backend
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      --network app_network \
      -p 3000:3000 \
      -v /root/glowlab_backend/.env:/app/.env \
      glowlab-backend
    """
    execute_command(client, cmd_run)
    
    print("\n--- FINAL CHECK ---")
    time.sleep(10)
    print(">>> LasoTuvi Logs:")
    execute_command(client, "docker logs lasotuvi --tail 20")
    print(">>> Backend Logs:")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
