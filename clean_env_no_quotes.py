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
    
    # Manually create files without ANY quotes using printf or echo
    # LasoTuvi Log Error: Could not parse SQLAlchemy URL from string '"postgres://..."'
    # This confirms the value has extra quotes inside the file OR the reader adds them.
    # If I echo 'DATABASE_URL=url', it should be fine.
    
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    
    print("\n--- CLEANING ENV FILES ---")
    
    # 1. LasoTuvi
    cmd_tuvi = f"printf 'DATABASE_URL={db_url}\\n' > /root/lasotuvi/.env"
    execute_command(client, cmd_tuvi)
    
    # 2. Backend
    # Get secret first
    execute_command(client, "G_SECRET=$(grep GOOGLE_CLIENT_SECRET /root/glowlab_backend/.env | cut -d'=' -f2 | tr -d '\"'); echo $G_SECRET > /tmp/g_secret")
    
    be_script = f"""
    SECRET=$(cat /tmp/g_secret)
    rm /root/glowlab_backend/.env
    touch /root/glowlab_backend/.env
    echo "NODE_ENV=development" >> /root/glowlab_backend/.env
    echo "PORT=3000" >> /root/glowlab_backend/.env
    echo "DATABASE_URL={db_url}?schema=public" >> /root/glowlab_backend/.env
    echo "JWT_SECRET=1234567890000000000000000000" >> /root/glowlab_backend/.env
    echo "AUTH_SALT_ROUNDS=10" >> /root/glowlab_backend/.env
    echo "AUTH_ACCESS_TOKEN_EXPIRES=15m" >> /root/glowlab_backend/.env
    echo "AUTH_REFRESH_TOKEN_EXPIRES=7d" >> /root/glowlab_backend/.env
    echo "LANG=EN" >> /root/glowlab_backend/.env
    echo "GOOGLE_CLIENT_ID=977935020241-2253d2adgna525l9ejsu1ej4ht2mslei.apps.googleusercontent.com" >> /root/glowlab_backend/.env
    echo "GOOGLE_CLIENT_SECRET=\$SECRET" >> /root/glowlab_backend/.env
    echo "GOOGLE_REDIRECT_URL=http://localhost:3000/auth/google/callback" >> /root/glowlab_backend/.env
    """
    execute_command(client, be_script)
    
    print("\n--- VERIFYING CONTENT ---")
    execute_command(client, "cat /root/lasotuvi/.env")
    execute_command(client, "cat /root/glowlab_backend/.env")
    
    print("\n--- RESTARTING ---")
    execute_command(client, "docker restart lasotuvi")
    execute_command(client, "docker restart glowlab_backend")
    
    time.sleep(10)
    execute_command(client, "docker logs lasotuvi --tail 20")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
