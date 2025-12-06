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
    
    # 1. Fix LasoTuvi .env (Remove double quotes)
    # Current: DATABASE_URL="postgres://..."
    # Error: Could not parse SQLAlchemy URL from string '"postgres://..."'
    # Fix: DATABASE_URL=postgres://...
    
    print("\n--- FIXING LASOTUVI .ENV ---")
    execute_command(client, "sed -i 's/\"//g' /root/lasotuvi/.env")
    execute_command(client, "docker restart lasotuvi")
    
    # 2. Fix Backend .env (Again, verify format)
    print("\n--- FIXING BACKEND .ENV ---")
    execute_command(client, "sed -i 's/\"//g' /root/glowlab_backend/.env")
    execute_command(client, "docker restart glowlab_backend")
    
    print("\n--- WAITING AND CHECKING LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs lasotuvi --tail 20")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
