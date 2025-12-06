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
    
    # --- FIX 3: GLOWLAB BACKEND PRISMA ISSUE ---
    # Error: "Checked following paths: schema.prisma: file not found, prisma/schema.prisma: file not found"
    # Reason: 'COPY package*.json ./' -> 'RUN npm ci' runs 'postinstall' which calls prisma. 
    # But 'COPY . .' happens LATER. So prisma folder is missing during 'npm ci'.
    
    print("\n=== FIXING GLOWLAB BACKEND (PRISMA) ===")
    fix_be_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app

# 1. Copy package files
COPY package*.json ./

# 2. Copy prisma schema BEFORE install because postinstall needs it
COPY prisma ./prisma/

# 3. Install dependencies (runs postinstall -> prisma generate)
RUN npm ci --only=production

# 4. Copy the rest of the source
COPY . .

# 5. Fix line endings
RUN apk add --no-cache dos2unix && dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    docker build -t glowlab-backend .
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      -p 3000:3000 \
      --env-file .env \
      glowlab-backend
    """
    execute_command(client, fix_be_script)
    
    print("\n--- FINAL STATUS ---")
    execute_command(client, "docker ps")
    execute_command(client, "netstat -tulpn | grep LISTEN")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
