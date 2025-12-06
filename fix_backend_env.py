import paramiko
import sys

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
    
    # Fix .env: Remove quotes from DATABASE_URL line
    print("\n--- FIXING .ENV FILE ---")
    # Use sed to remove double quotes from the value part
    # Match DATABASE_URL="value" -> DATABASE_URL=value
    fix_cmd = "sed -i 's/DATABASE_URL=\"/DATABASE_URL=/g' /root/glowlab_backend/.env && sed -i 's/\"$//g' /root/glowlab_backend/.env"
    # Better sed: replace 'DATABASE_URL="...' with 'DATABASE_URL=...' and remove trailing quote
    # Actually, safer is to just strip all quotes from that line?
    # Let's try: sed -i '/DATABASE_URL/s/"//g' /root/glowlab_backend/.env
    execute_command(client, "sed -i '/DATABASE_URL/s/\"//g' /root/glowlab_backend/.env")
    
    print("\n--- VERIFYING .ENV ---")
    execute_command(client, "grep DATABASE_URL /root/glowlab_backend/.env")
    
    print("\n--- RESTARTING BACKEND ---")
    execute_command(client, "docker restart glowlab_backend")
    
    print("\n--- CHECKING LOGS ---")
    execute_command(client, "sleep 5 && docker logs glowlab_backend --tail 20")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
