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
    
    # The previous log showed only Dockerfile and source.zip.
    # It seems I uploaded source.zip but forgot to UNZIP it in the previous retry steps,
    # or I unzipped it but then overwrote the directory with COPY . . including the zip?
    # Wait, the previous script did: unzip -o source.zip && rm source.zip
    # But the LS output shows source.zip IS THERE and NO other files.
    # This means unzip FAILED or wasn't run correctly.
    
    print("\n--- REDEPLOYING LASOTUVI (WITH UNZIP FIX) ---")
    fix_tuvi_script = """
    cd /root/lasotuvi
    
    # Install unzip just in case
    apt-get install -y unzip
    
    # Unzip explicitly
    unzip -o source.zip
    
    # Check content
    ls -F
    
    # Create correct Dockerfile
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Expose port
EXPOSE 8000

# Start Command - Update this based on actual file found
# If 'lasotuvi' folder exists, likely: lasotuvi.api.main:app
# We will try to find the app string dynamically or default to standard
CMD ["sh", "-c", "uvicorn lasotuvi.api.main:app --host 0.0.0.0 --port 8000 || uvicorn main:app --host 0.0.0.0 --port 8000"]
EOF

    docker build -t lasotuvi-api .
    docker stop lasotuvi || true
    docker rm lasotuvi || true
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      lasotuvi-api
    """
    execute_command(client, fix_tuvi_script)
    
    print("\n--- FINAL LOGS ---")
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
