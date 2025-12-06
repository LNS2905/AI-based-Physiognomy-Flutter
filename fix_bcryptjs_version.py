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
    
    print("\n--- FIXING BCRYPTJS VERSION ---")
    
    # bcrypt was likely version ^5.1.1. bcryptjs latest is around 2.4.3.
    # We need to replace the version too.
    # Using sed to replace the line "bcryptjs": "^5.1.1" with "bcryptjs": "^2.4.3"
    
    # Check package.json content first
    execute_command(client, "grep bcryptjs /root/glowlab_backend/package.json")
    
    # Replace version. Regex: "bcryptjs": ".*" -> "bcryptjs": "^2.4.3"
    execute_command(client, "sed -i 's/\"bcryptjs\": \".*\"/\"bcryptjs\": \"^2.4.3\"/g' /root/glowlab_backend/package.json")
    
    # Also need to update package-lock.json or just delete it to force new resolution?
    # Deleting package-lock.json is risky but easier here since we run npm ci.
    # Wait, npm ci REQUIRES package-lock.json.
    # So we must run `npm install` instead of `npm ci` to generate lock file, OR update lock file?
    # Updating lock file is hard without running npm install.
    # We can change `npm ci` to `npm install` in Dockerfile!
    
    print("\n--- REBUILDING WITH NPM INSTALL (NO LOCK) ---")
    
    be_final_build = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app
# Build tools still needed for other native deps if any
RUN apk add --no-cache python3 make g++
COPY package.json ./
# Skip lock file copy if we want to regenerate it
# COPY package-lock.json ./ 
COPY prisma ./prisma/
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"

# Use install instead of ci to regenerate lock
RUN npm install

RUN npx prisma generate
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache dos2unix

COPY package.json ./
COPY prisma ./prisma/

# Install prod deps
RUN npm install --only=production

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
    execute_command(client, be_final_build)
    
    print("\n--- FINAL LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
