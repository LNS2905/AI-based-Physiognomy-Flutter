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
    
    # Update Google Secret
    secret = "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"
    
    print("\n--- UPDATING GOOGLE SECRET ---")
    cmd_update = f"sed -i 's/REPLACE_WITH_REAL_SECRET/{secret}/g' /root/glowlab_backend/.env"
    execute_command(client, cmd_update)
    
    # Fix server.ts: ensure dotenv is at the very top
    # Current grep showed dotenv imported at line 12.
    # If prisma is imported before that, env vars are undefined.
    # We need to inject `import dotenv from "dotenv"; dotenv.config();` at the VERY TOP of server.ts (after compilation usually dist/server.js)
    # But we are running `node dist/server.js`.
    # If we fix `src/server.ts` we need to rebuild.
    # Rebuilding takes time.
    # Can we patch `dist/server.js` directly?
    # It's JS.
    
    print("\n--- PATCHING DIST/SERVER.JS ---")
    # Check content of dist/server.js first few lines
    execute_command(client, "head -n 10 /root/glowlab_backend/dist/server.js")
    
    # Inject dotenv config at the top of dist/server.js
    # `require('dotenv').config();`
    patch_js = """
    sed -i '1s/^/require("dotenv").config();\\n/' /root/glowlab_backend/dist/server.js
    """
    execute_command(client, patch_js)
    
    print("\n--- RESTARTING BACKEND ---")
    # Mount the patched dist folder?
    # No, we modified the file ON THE HOST volume /root/glowlab_backend/dist ?
    # Wait, previous docker run mounted: -v /root/glowlab_backend/.env:/app/.env
    # It DID NOT mount the code. The code is inside the image.
    # So modifying /root/glowlab_backend/dist/server.js does NOTHING unless we mount it or rebuild.
    
    # We must Rebuild or Mount.
    # Rebuild is safer but slow. Mount is fast.
    # Let's Mount `dist/server.js` as well for now.
    # /root/glowlab_backend/dist must exist on host?
    # Let's check if dist exists on host.
    execute_command(client, "ls -F /root/glowlab_backend/dist")
    
    # If dist exists on host (from previous unzip), we can patch it and mount it.
    # If not, we must extract it from image or rebuild.
    # Previous unzip: "unzip -o source.zip" -> src folder exists. dist might NOT exist if we didn't build on host.
    # We built IN DOCKER.
    
    # Solution: Rebuild is the clean way.
    # Or: Copy file out of container, patch, and mount back?
    # docker cp glowlab_backend:/app/dist/server.js /root/glowlab_backend/server.js
    # patch
    # docker run ... -v .../server.js:/app/dist/server.js
    
    print("\n--- EXTRACTING AND PATCHING SERVER.JS ---")
    execute_command(client, "docker cp glowlab_backend:/app/dist/server.js /root/glowlab_backend/server.js")
    execute_command(client, "sed -i '1s/^/require(\"dotenv\").config();\\n/' /root/glowlab_backend/server.js")
    
    print("\n--- RESTARTING WITH PATCHED FILE ---")
    cmd_restart = """
    docker stop glowlab_backend || true
    docker rm glowlab_backend || true
    
    docker run -d --name glowlab_backend \
      --restart unless-stopped \
      --network app_network \
      -p 3000:3000 \
      -v /root/glowlab_backend/.env:/app/.env \
      -v /root/glowlab_backend/server.js:/app/dist/server.js \
      glowlab-backend
    """
    execute_command(client, cmd_restart)
    
    print("\n--- FINAL LOG CHECK ---")
    time.sleep(5)
    execute_command(client, "docker logs glowlab_backend --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
