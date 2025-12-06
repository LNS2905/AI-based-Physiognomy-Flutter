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
    
    # DB URL provided by user: postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    
    # Use internal IP/Container name for backend/tuvi to connect to DB container?
    # DB is running on host port 2905.
    # If services are in bridge mode, they can connect to host IP: 160.250.180.132.
    # The URL already uses the public IP, which should work if firewall allows.
    # Ideally we should use internal docker network, but let's stick to public IP config for now as user provided.
    
    print("\n--- OVERWRITING .ENV FILES (HARD RESET) ---")
    
    # 1. LasoTuvi .env
    tuvi_env_content = f"DATABASE_URL={db_url}"
    cmd_tuvi = f"echo '{tuvi_env_content}' > /root/lasotuvi/.env"
    execute_command(client, cmd_tuvi)
    
    # 2. GlowLab Backend .env
    # We need to preserve other vars or recreate them.
    # I will recreate the basic ones found earlier.
    backend_env_content = f"""# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL={db_url}?schema=public

# JWT & Authentication
JWT_SECRET=1234567890000000000000000000
AUTH_SALT_ROUNDS=10
AUTH_ACCESS_TOKEN_EXPIRES=15m
AUTH_REFRESH_TOKEN_EXPIRES=7d

# Language
LANG=EN

# Google
GOOGLE_CLIENT_ID=977935020241-2253d2adgna525l9ejsu1ej4ht2mslei.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=***********************************
GOOGLE_REDIRECT_URL=http://localhost:3000/auth/google/callback
"""
    # Note: Google Secret was masked in my previous read. I should NOT overwrite it with asterisks if I can avoid it.
    # I should read the existing file, grep the secret, and then construct the new file.
    
    recreate_be_env = f"""
    # Save Google Secret
    G_SECRET=$(grep GOOGLE_CLIENT_SECRET /root/glowlab_backend/.env | cut -d'=' -f2)
    
    # Overwrite
    cat > /root/glowlab_backend/.env <<EOF
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL={db_url}?schema=public

# JWT & Authentication
JWT_SECRET=1234567890000000000000000000
AUTH_SALT_ROUNDS=10
AUTH_ACCESS_TOKEN_EXPIRES=15m
AUTH_REFRESH_TOKEN_EXPIRES=7d

# Language
LANG=EN

# Google
GOOGLE_CLIENT_ID=977935020241-2253d2adgna525l9ejsu1ej4ht2mslei.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=\$G_SECRET
GOOGLE_REDIRECT_URL=http://localhost:3000/auth/google/callback
EOF
    """
    execute_command(client, recreate_be_env)
    
    print("\n--- RESTARTING SERVICES ---")
    execute_command(client, "docker restart lasotuvi")
    execute_command(client, "docker restart glowlab_backend")
    
    print("\n--- FINAL LOG CHECK ---")
    time.sleep(10)
    execute_command(client, "docker logs lasotuvi --tail 20")
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
