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
    
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode('utf-8', errors='replace'), end='')
        if stderr.channel.recv_ready():
            print(stderr.channel.recv(1024).decode('utf-8', errors='replace'), end='')
        time.sleep(0.1)
        
    exit_status = stdout.channel.recv_exit_status()
    return exit_status

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    # --- FIX 4: GLOWLAB BACKEND PRISMA ENV ISSUE ---
    # Prisma migrate needs DATABASE_URL, which is not in env during build.
    # Fix: Use --ignore-scripts for install, then run generate manually.
    
    print("\n=== FIXING GLOWLAB BACKEND (ENV BYPASS) ===")
    fix_env_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app

# 1. Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# 2. Install dependencies WITHOUT scripts (avoids postinstall crash)
RUN npm ci --only=production --ignore-scripts

# 3. Manually generate client (doesn't need DB url)
RUN npx prisma generate

# 4. Copy source
COPY . .

# 5. Fix line endings
RUN apk add --no-cache dos2unix && dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    # Also need to update docker-entrypoint.sh to run migration at runtime
    # But first let's build successfully.
    
    docker build -t glowlab-backend .
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      --env-file .env \
      glowlab-backend
    """
    execute_command(client, fix_env_script)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
