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
    
    # Fix: npm ci --ignore-scripts in builder stage too
    # Because postinstall runs prisma migrate which tries to connect to DB.
    # We don't need migration during build, we just need 'prisma generate' for types.
    
    print("\n--- REBUILDING BACKEND (FINAL FIX) ---")
    
    be_final_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app

# Install build tools
RUN apk add --no-cache python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

# Install deps IGNORING SCRIPTS (skips postinstall migration)
RUN npm ci --ignore-scripts

# Generate Prisma Client manually (does not need DB connection)
RUN npx prisma generate

COPY . .

# Build TypeScript
RUN npm run build

# Production Stage
FROM node:18-alpine
WORKDIR /app

# Install runtime deps
RUN apk add --no-cache dos2unix

COPY package*.json ./
COPY prisma ./prisma/

# Install prod deps
RUN npm ci --only=production --ignore-scripts

# Copy built files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Copy other needed files
COPY . .

# Fix entrypoint
RUN dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
EOF

    docker build -t glowlab-backend .
    
    # Start with network
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      --network app_network \
      -p 3000:3000 \
      -v /root/glowlab_backend/.env:/app/.env \
      glowlab-backend
    """
    execute_command(client, be_final_script)
    
    print("\n--- FINAL BACKEND CHECK ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
