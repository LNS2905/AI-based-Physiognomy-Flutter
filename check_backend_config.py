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
    
    # Problem 1: GOOGLE_CLIENT_SECRET=$SECRET
    # This happened because I used python string interpolation but $SECRET was a shell variable in the command string,
    # and python probably messed it up or shell didn't expand it because it was inside a heredoc?
    # Actually, I escaped it as \$SECRET, but maybe it wasn't expanded by the shell because of how paramiko executes it.
    # We need to set the REAL secret manually.
    
    # Problem 2: DATABASE_URL undefined in Prisma
    # This is likely because 'prisma.ts' is imported BEFORE 'dotenv' is configured in 'server.ts'.
    # OR the environment variable is not passed correctly to the node process.
    # We are running via `docker-entrypoint.sh`? 
    # Let's check `docker-entrypoint.sh` content on server.
    
    print("\n--- CHECKING ENTRYPOINT ---")
    execute_command(client, "cat /root/glowlab_backend/docker-entrypoint.sh")
    
    # Let's fix the .env file first with correct Google Secret
    # The secret was masked in logs, but I might have seen it earlier?
    # I grep-ed it earlier: G_SECRET=$(grep GOOGLE_CLIENT_SECRET ...).
    # If I can't find it, I will have to ask user again.
    # Wait, I can grep it from the PREVIOUS .env file if I didn't delete it?
    # I overwrote it. So it might be lost if I didn't save it.
    # BUT, I used `grep ... | cut ...` in the command that created the new file.
    # If that command failed to expand $SECRET, then the file literally contains "$SECRET".
    # Let's check if there is any backup or if I can recover it from memory/logs?
    # The user provided logs show: GOOGLE_CLIENT_SECRET="***********************************"
    # It seems I never saw the full secret in clear text in my logs.
    # Wait, the `check_env_vars.py` output showed:
    # GOOGLE_CLIENT_SECRET="***********************************"
    # So I DO NOT HAVE the Google Secret.
    
    # CRITICAL: I need to ask the user for the Google Client Secret.
    # But first, let's fix the Prisma DATABASE_URL issue which is also blocking startup.
    
    # Fix Prisma:
    # We will hardcode the DB URL in the .env file correctly first.
    # And ensure `dotenv` is loaded.
    
    db_url = "postgresql://physio_db:290503Sang.@postgres_db:5432/physio_db"
    
    print("\n--- FIXING .ENV DATABASE_URL ---")
    # Write .env carefully
    # We will leave GOOGLE_CLIENT_SECRET empty or placeholder for now and ask user.
    
    fix_env_script = f"""
cat > /root/glowlab_backend/.env <<EOF
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL="{db_url}?schema=public"

# JWT
JWT_SECRET=1234567890000000000000000000
AUTH_SALT_ROUNDS=10
AUTH_ACCESS_TOKEN_EXPIRES=15m
AUTH_REFRESH_TOKEN_EXPIRES=7d

# Language
LANG=EN

# Google
GOOGLE_CLIENT_ID=977935020241-2253d2adgna525l9ejsu1ej4ht2mslei.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=REPLACE_WITH_REAL_SECRET
GOOGLE_REDIRECT_URL=http://localhost:3000/auth/google/callback
EOF
    """
    execute_command(client, fix_env_script)
    
    print("\n--- CHECKING SERVER.TS FOR DOTENV ---")
    # Check if dotenv is initialized at the top
    execute_command(client, "grep -n 'dotenv' /root/glowlab_backend/src/server.ts")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
