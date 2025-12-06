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
    
    # `npm install` failed because postinstall (prisma migrate) ran and failed to connect to DB.
    # Fix: run npm install with --ignore-scripts
    # THEN run prisma generate manually
    # THEN run npm run build
    
    print("\n--- REBUILDING BACKEND (FIXED NPM INSTALL) ---")
    
    be_fixed_install = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++
COPY package.json ./
COPY prisma ./prisma/
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"

# Install without scripts
RUN npm install --ignore-scripts

# Manually generate client
RUN npx prisma generate

COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache dos2unix

COPY package.json ./
COPY prisma ./prisma/

# Install prod deps
RUN npm install --only=production --ignore-scripts

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

COPY . .

RUN dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    docker build -t glowlab-backend .
    docker restart glowlab_backend
    """
    execute_command(client, be_fixed_install)
    
    print("\n--- FINAL LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
