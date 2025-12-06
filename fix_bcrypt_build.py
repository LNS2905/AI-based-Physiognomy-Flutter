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
    
    # Error: Cannot find module '/app/node_modules/bcrypt/lib/binding/napi-v3/bcrypt_lib.node'
    # Cause: bcrypt binary built on one OS (host or builder stage without python/make) might not work on Alpine, or was not built at all.
    # Fix: We need to ensure `npm rebuild bcrypt --build-from-source` runs in the final stage OR ensure the copied node_modules are compatible.
    # In our rebuild script, we ran `npm ci --only=production`. Bcrypt usually builds from source during install.
    # But Alpine requires python3/make/g++ which we didn't install in the FINAL stage (only in builder).
    # Wait, in the final stage: `FROM node:18-alpine` ... `RUN apk add --no-cache dos2unix` ... `RUN npm ci`.
    # npm ci will fail to build bcrypt if build tools are missing. It might fallback to prebuilt binaries which might not exist for musl (Alpine).
    
    # Solution: Install build tools in the final stage temporarily to install deps, then remove them? 
    # OR just keep them.
    
    print("\n--- FIXING BCRYPT BUILD ---")
    
    # We modify the Dockerfile to include build tools in the final stage for `npm ci`
    
    be_fix_bcrypt_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++
COPY package*.json ./
COPY prisma ./prisma/
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN npm ci --ignore-scripts
RUN npx prisma generate
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app

# Install runtime deps + build deps for bcrypt
RUN apk add --no-cache dos2unix python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

# Install prod deps (will compile bcrypt)
RUN npm ci --only=production --ignore-scripts

# Rebuild bcrypt specifically to be sure
RUN npm rebuild bcrypt --build-from-source

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
    execute_command(client, be_fix_bcrypt_script)
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
