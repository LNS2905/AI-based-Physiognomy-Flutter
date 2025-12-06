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
    
    print("\n--- CHECKING PORT 2905 (DATABASE) ---")
    execute_command(client, "netstat -tulpn | grep 2905")
    
    # DB URL provided by user
    # postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db
    # Escaping for sed:
    # The URL contains / which conflicts with sed delimiter. Use | instead.
    
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    db_url_backend = f"{db_url}?schema=public"
    
    print("\n--- UPDATING GLOWLAB BACKEND ENV ---")
    # Update DATABASE_URL line
    cmd_update_be = f"sed -i 's|^DATABASE_URL=.*|DATABASE_URL=\"{db_url_backend}\"|' /root/glowlab_backend/.env"
    execute_command(client, cmd_update_be)
    
    print("\n--- UPDATING LASOTUVI ENV ---")
    cmd_update_tuvi = f"echo 'DATABASE_URL=\"{db_url}\"' > /root/lasotuvi/.env"
    execute_command(client, cmd_update_tuvi)
    
    print("\n--- RESTARTING SERVICES ---")
    execute_command(client, "docker restart glowlab_backend")
    execute_command(client, "docker restart lasotuvi")
    
    print("\n--- CHECKING LOGS (WAITING 10s) ---")
    time.sleep(10)
    print(">>> GlowLab Backend Logs:")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    print(">>> LasoTuvi Logs:")
    execute_command(client, "docker logs lasotuvi --tail 20")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
