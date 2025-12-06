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
    
    print("\n--- FIXING CODE TO STRIP QUOTES ---")
    
    # 1. Fix LasoTuvi: database_pg.py
    # Current:
    # DATABASE_URL = os.getenv(...)
    # engine = create_engine(DATABASE_URL, ...)
    
    # New:
    # DATABASE_URL = os.getenv(...).replace('"', '').replace("'", "")
    
    # We'll use a small Python script to patch the file in place inside the container context
    # Actually, we can sed the source code on disk.
    
    sed_cmd = """
    sed -i 's/DATABASE_URL = os.getenv(/DATABASE_URL = os.getenv(/g' /root/lasotuvi/lasotuvi/api/database_pg.py
    # Append .replace('"', '') to the getenv call?
    # It's risky with regex.
    
    # Better: Insert a line after load_dotenv() to sanitize DATABASE_URL if it was loaded from env
    # Pattern:
    # load_dotenv()
    # <insert> if os.environ.get("DATABASE_URL"): os.environ["DATABASE_URL"] = os.environ["DATABASE_URL"].replace('"', '').replace("'", "")
    
    sed -i '/load_dotenv()/a if os.environ.get("DATABASE_URL"): os.environ["DATABASE_URL"] = os.environ["DATABASE_URL"].replace("\\"", "").replace("\\x27", "")' /root/lasotuvi/lasotuvi/api/database_pg.py
    """
    execute_command(client, sed_cmd)
    
    # Verify the change
    execute_command(client, "grep -A 2 'load_dotenv()' /root/lasotuvi/lasotuvi/api/database_pg.py")
    
    print("\n--- REBUILDING LASOTUVI ---")
    # Rebuild to bake changes into image
    rebuild_script = """
    cd /root/lasotuvi
    docker build -t lasotuvi-api .
    docker restart lasotuvi
    """
    execute_command(client, rebuild_script)
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(5)
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
