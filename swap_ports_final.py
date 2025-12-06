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
    
    # Problem: 
    # Physiognomy API is running on 127.0.0.1:8000->8000/tcp (locally bound, but blocks port 8000?)
    # Wait, docker ps showed: 127.0.0.1:8000->8000/tcp for physiognomy
    # This means it binds to localhost 8000.
    # LasoTuvi tried to bind to 0.0.0.0:8000 and failed.
    
    # Goal: 
    # Physiognomy -> 8001
    # LasoTuvi -> 8000
    
    print("\n--- RECONFIGURING PORTS (FINAL SWAP) ---")
    swap_script = """
    # 1. Stop everything on 8000/8001
    docker stop physiognomy-api || true
    docker stop lasotuvi || true
    docker rm physiognomy-api || true
    docker rm lasotuvi || true
    
    # 2. Start Physiognomy on 8001
    echo "Starting Physiognomy on 8001..."
    cd /root/AIPhysiognomy
    # Modify compose to use 8001
    sed -i 's/8000:8000/8001:8000/g' docker-compose.yml
    # Also ensure it binds to 0.0.0.0
    sed -i 's/127.0.0.1:8001:8000/8001:8000/g' docker-compose.yml
    
    docker-compose up -d
    
    # 3. Start LasoTuvi on 8000
    echo "Starting LasoTuvi on 8000..."
    cd /root/lasotuvi
    docker run -d --name lasotuvi \
      --restart unless-stopped \
      -p 8000:8000 \
      --env-file /root/lasotuvi/.env \
      lasotuvi-api
    """
    execute_command(client, swap_script)
    
    print("\n--- FINAL VERIFICATION ---")
    execute_command(client, "docker ps")
    execute_command(client, "netstat -tulpn | grep LISTEN")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
