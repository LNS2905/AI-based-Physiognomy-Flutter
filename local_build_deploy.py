import os
import subprocess
import sys
from datetime import datetime

# Configuration
SERVER_IP = "160.250.180.132"
SERVER_USER = "root"
SERVER_PASS = "Do@nhkiet262205"
LOCAL_PROJECT_PATH = r"C:\Code\ai-physio-be"  # Adjust if needed
IMAGE_NAME = "glowlab-backend"
IMAGE_TAG = "latest"
TAR_FILE = "glowlab-backend.tar"

def run_command(command, cwd=None, shell=True):
    """Run a shell command and stream output."""
    print(f"\n[EXEC] {command}")
    try:
        # Update env to include Docker bin path for credential helpers
        env = os.environ.copy()
        docker_bin_path = r"C:\Program Files\Docker\Docker\resources\bin"
        if os.path.exists(docker_bin_path) and docker_bin_path not in env["PATH"]:
            env["PATH"] += os.pathsep + docker_bin_path
            
        process = subprocess.Popen(
            command,
            cwd=cwd,
            shell=shell,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env
        )
        
        for line in process.stdout:
            print(line, end='')
        
        stdout, stderr = process.communicate()
        if process.returncode != 0:
            print(f"Error: {stderr}")
            return False
        return True
    except Exception as e:
        print(f"Exception: {e}")
        return False

def find_docker_cmd():
    """Find available docker command (PATH, Absolute, or WSL)."""
    # 1. Try standard command
    try:
        subprocess.run(["docker", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return "docker"
    except:
        pass
        
    # 2. Try standard Windows installation path
    abs_path = r"C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    if os.path.exists(abs_path):
        return f'"{abs_path}"'
        
    # 3. Try WSL
    try:
        subprocess.run(["wsl", "docker", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return "wsl docker"
    except:
        pass
        
    return None

def main():
    print("=== LOCAL BUILD & DEPLOY TOOL ===")
    print(f"Target: {SERVER_IP}")
    
    DOCKER_CMD = find_docker_cmd()
    if not DOCKER_CMD:
        print("Error: Docker not found in PATH, standard locations, or WSL.")
        print("Please install Docker Desktop and ensure it is running.")
        return
        
    print(f"Using Docker command: {DOCKER_CMD}")
    
    # 1. Fix Local Dockerfile for Production
    print("\n--- 1. PREPARING DOCKERFILE ---")
    dockerfile_content = """
FROM node:18-alpine AS builder
WORKDIR /app
# Build tools needed for native modules like bcrypt
RUN apk add --no-cache python3 make g++
COPY package*.json ./
COPY prisma ./prisma/
# Dummy ENV for build
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
# Install dependencies
RUN npm ci --ignore-scripts
RUN npx prisma generate
COPY . .
# Build TypeScript
RUN npm run build

FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache dos2unix python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

# Install production dependencies and rebuild native modules
RUN npm ci --only=production --ignore-scripts
RUN npm rebuild bcrypt --build-from-source

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules # Copy built node_modules if rebuild fails, but usually we want clean prod deps

# Copy source files (needed for some runtime paths?)
COPY . .

RUN dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
"""
    # Write Dockerfile locally
    dockerfile_path = os.path.join(LOCAL_PROJECT_PATH, "Dockerfile.prod")
    with open(dockerfile_path, "w", encoding="utf-8") as f:
        f.write(dockerfile_content)
    print("Created Dockerfile.prod")

    # 2. Build Docker Image (Linux/AMD64)
    print("\n--- 2. BUILDING DOCKER IMAGE (AMD64) ---")
    # We must use --platform linux/amd64 because local might be arm64 (if M1 mac) or to be safe
    cmd_build = f"{DOCKER_CMD} build --platform linux/amd64 -f Dockerfile.prod -t {IMAGE_NAME}:{IMAGE_TAG} ."
    if not run_command(cmd_build, cwd=LOCAL_PROJECT_PATH):
        print("Build failed.")
        return

    # 3. Save Image to Tar
    print("\n--- 3. SAVING IMAGE TO FILE ---")
    cmd_save = f"{DOCKER_CMD} save -o {TAR_FILE} {IMAGE_NAME}:{IMAGE_TAG}"
    if not run_command(cmd_save, cwd=LOCAL_PROJECT_PATH):
        print("Save failed.")
        return

    # 4. Upload to Server (using scp via paramiko or system scp)
    print("\n--- 4. UPLOADING TO SERVER ---")
    # We use system scp if available (requires sshpass for password) OR we can use paramiko if installed
    try:
        import paramiko
        from scp import SCPClient
        
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(SERVER_IP, username=SERVER_USER, password=SERVER_PASS)
        
        with SCPClient(ssh.get_transport()) as scp:
            local_tar = os.path.join(LOCAL_PROJECT_PATH, TAR_FILE)
            print(f"Uploading {local_tar}...")
            scp.put(local_tar, f"/root/{TAR_FILE}")
            
        print("Upload successful.")
    except ImportError:
        print("Paramiko/SCP library missing. Trying system SCP (might ask for password)...")
        # Fallback to system scp
        cmd_scp = f"scp {os.path.join(LOCAL_PROJECT_PATH, TAR_FILE)} {SERVER_USER}@{SERVER_IP}:/root/"
        run_command(cmd_scp)

    # 5. Load and Restart on Server
    print("\n--- 5. DEPLOYING ON SERVER ---")
    remote_cmds = [
        f"docker load -i /root/{TAR_FILE}",
        f"docker stop {IMAGE_NAME} || true",
        f"docker rm {IMAGE_NAME} || true",
        # Run command with network and env mount
        f"docker run -d --name {IMAGE_NAME} --restart unless-stopped --network app_network -p 3000:3000 -v /root/glowlab_backend/.env:/app/.env {IMAGE_NAME}:{IMAGE_TAG}",
        f"rm /root/{TAR_FILE}"
    ]
    
    full_remote_cmd = " && ".join(remote_cmds)
    
    try:
        # Reuse ssh connection if valid
        stdin, stdout, stderr = ssh.exec_command(full_remote_cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
        ssh.close()
    except:
        print("Using system SSH...")
        run_command(f"ssh {SERVER_USER}@{SERVER_IP} '{full_remote_cmd}'")

    print("\n=== DEPLOYMENT COMPLETE ===")

if __name__ == "__main__":
    main()
