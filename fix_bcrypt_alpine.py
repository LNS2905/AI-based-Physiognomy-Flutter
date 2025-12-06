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
    
    # Stream output
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
    
    print("\n--- FIXING BCRYPT BUILD ON SERVER ---")
    
    be_fix_bcrypt_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app
# Build tools for compilation
RUN apk add --no-cache python3 make g++
COPY package*.json ./
COPY prisma ./prisma/
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
# Install all deps (including dev) for building
RUN npm ci --ignore-scripts
# Generate client
RUN npx prisma generate
COPY . .
# Build TS
RUN npm run build

FROM node:18-alpine
WORKDIR /app

# Install runtime deps AND build tools for bcrypt (needed for npm rebuild)
RUN apk add --no-cache dos2unix python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

# Install production deps
RUN npm ci --only=production --ignore-scripts

# Rebuild bcrypt from source for Alpine
RUN npm rebuild bcrypt --build-from-source

COPY --from=builder /app/dist ./dist
# Do NOT copy node_modules from builder, we use fresh prod modules above
# COPY --from=builder /app/node_modules ./node_modules

COPY . .

RUN dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    docker build -t glowlab-backend .
    docker restart glowlab_backend
    """
    execute_command(client, be_fix_bcrypt_script)
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
