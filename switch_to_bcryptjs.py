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
    
    # Switching to bcryptjs avoids compilation issues entirely.
    # We need to:
    # 1. Uninstall bcrypt
    # 2. Install bcryptjs
    # 3. Replace imports in code (dist/utils/password/password.util.js)
    # BUT modifying dist JS is messy.
    # Better: Modify source and rebuild.
    # But we don't want to edit source code on server manually via sed everywhere.
    
    # Alternative: Keep bcrypt but try to fix the build.
    # The build failed because `npm rebuild` in the Dockerfile might have run BEFORE `npm ci` finished or in wrong layer?
    # Or because `npm ci --only=production` removed the build tools?
    # Wait, I installed build tools in the final stage: `RUN apk add ... make g++`
    # AND then `RUN npm rebuild bcrypt --build-from-source`
    # It SHOULD have worked.
    
    # Maybe the issue is that `npm ci` installs prebuilt binary for musl but it's missing?
    # Or `npm rebuild` failed silently?
    
    # Let's try `bcryptjs` approach. It's safer.
    # I will modify `package.json` to use `bcryptjs` instead of `bcrypt`.
    # And then I need to find where bcrypt is used in code.
    # `src/utils/password/password.util.ts`
    
    print("\n--- SWITCHING TO BCRYPTJS ---")
    
    # 1. Replace bcrypt with bcryptjs in package.json
    execute_command(client, "sed -i 's/\"bcrypt\":/\"bcryptjs\":/g' /root/glowlab_backend/package.json")
    
    # 2. Replace import in source code
    # Find files using bcrypt
    execute_command(client, "grep -r 'bcrypt' /root/glowlab_backend/src")
    
    # Replace in password.util.ts
    # import * as bcrypt from "bcrypt"; -> import * as bcrypt from "bcryptjs";
    execute_command(client, "sed -i 's/\"bcrypt\"/\"bcryptjs\"/g' /root/glowlab_backend/src/utils/password/password.util.ts")
    
    # Rebuild
    print("\n--- REBUILDING WITH BCRYPTJS ---")
    # We can reuse the previous Dockerfile but remove the rebuild step which is now useless
    # And we don't need python/make/g++ in final stage anymore!
    
    be_bcryptjs_script = """
    cd /root/glowlab_backend
    
    cat > Dockerfile <<EOF
FROM node:18-alpine AS builder
WORKDIR /app
# Build tools still needed for other native deps if any, but bcryptjs is pure JS
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
RUN apk add --no-cache dos2unix

COPY package*.json ./
COPY prisma ./prisma/

# Install prod deps
RUN npm ci --only=production --ignore-scripts

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
    execute_command(client, be_bcryptjs_script)
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(10)
    execute_command(client, "docker logs glowlab_backend --tail 50")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
