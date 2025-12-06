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
    
    # It seems Docker build cache is reusing the layer "COPY . ." from BEFORE my sed patch?
    # "Step 9/12 : COPY . . ---> Using cache"
    # Yes! The file change on host was NOT picked up because docker cache thought "COPY . ." hasn't changed? 
    # Actually, if file changes, hash changes. But maybe timestamps?
    
    print("\n--- REBUILDING NO CACHE ---")
    
    # Ensure file is patched
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    cmd_patch = f"sed -i 's|^DATABASE_URL = .*|DATABASE_URL = \"{db_url}\"|' /root/lasotuvi/lasotuvi/api/database_pg.py"
    execute_command(client, cmd_patch)
    
    # Force rebuild
    execute_command(client, "cd /root/lasotuvi && docker build --no-cache -t lasotuvi-api . && docker restart lasotuvi")
    
    print("\n--- FINAL LOGS ---")
    execute_command(client, "sleep 5 && docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
