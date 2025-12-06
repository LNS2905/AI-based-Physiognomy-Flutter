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
    
    # The issue persists: ArgumentError ... from string '"postgresql://..."'
    # This means the variable still contains double quotes.
    # This happens if:
    # 1. load_dotenv() reads from .env and the .env file has quotes.
    # 2. OR our hardcoding failed (didn't actually overwrite the file or rebuild didn't pick it up).
    # Note: `docker build` uses the file context. If we modified the file on disk, build should pick it up.
    # BUT `load_dotenv()` overwrites variables if they exist in .env? 
    # By default load_dotenv(override=False). So if env var is set, it keeps it.
    # However, in the code: DATABASE_URL = os.getenv("DATABASE_URL", default)
    # Wait, in my hardcode script I replaced `DATABASE_URL = os.getenv(...)` with `DATABASE_URL = "..."`
    # So load_dotenv() shouldn't matter unless I'm using os.getenv later?
    # Ah, I checked the logs: `File "/app/lasotuvi/api/database_pg.py", line 21, in <module> engine = create_engine(DATABASE_URL, ...)`
    # This means my hardcode script DID NOT WORK or the file content is not what I think.
    
    # Let's check the file content on server.
    print("\n--- CHECKING FILE CONTENT ---")
    execute_command(client, "cat /root/lasotuvi/lasotuvi/api/database_pg.py | grep DATABASE_URL")
    
    # If it still has os.getenv, my hardcode script failed silently or I edited the wrong file?
    # /root/lasotuvi/lasotuvi/api/database_pg.py vs /root/lasotuvi/api/database_pg.py?
    # The error log says: `/app/lasotuvi/api/database_pg.py`
    # In container: `/app` is `/root/lasotuvi` content.
    # So `/root/lasotuvi/lasotuvi/api/database_pg.py` matches.
    
    # Maybe I should delete the .env file entirely to be sure?
    print("\n--- DELETING .ENV ---")
    execute_command(client, "rm /root/lasotuvi/.env")
    
    # Try to patch again with a simpler approach: SED replace line 21
    # The line usually is: DATABASE_URL = os.getenv(
    print("\n--- PATCHING WITH SED ---")
    # Replace everything from DATABASE_URL = ... to the closing parenthesis or end of line
    # Just replace the whole line.
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    cmd = f"sed -i 's|^DATABASE_URL = .*|DATABASE_URL = \"{db_url}\"|' /root/lasotuvi/lasotuvi/api/database_pg.py"
    execute_command(client, cmd)
    
    # Check again
    print("\n--- VERIFYING PATCH ---")
    execute_command(client, "grep 'DATABASE_URL =' /root/lasotuvi/lasotuvi/api/database_pg.py")
    
    print("\n--- REBUILDING ---")
    execute_command(client, "cd /root/lasotuvi && docker build -t lasotuvi-api . && docker restart lasotuvi")
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(5)
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
