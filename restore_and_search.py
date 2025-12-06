import paramiko
import sys
import time

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command, stream_output=True):
    print(f"\n[REMOTE] Executing: {command}")
    stdin, stdout, stderr = ssh.exec_command(command)
    
    full_output = ""
    if stream_output:
        while not stdout.channel.exit_status_ready():
            if stdout.channel.recv_ready():
                line = stdout.channel.recv(1024).decode('utf-8', errors='replace')
                sys.stdout.write(line)
                full_output += line
            if stderr.channel.recv_ready():
                line = stderr.channel.recv(1024).decode('utf-8', errors='replace')
                sys.stderr.write(line)
    
    exit_status = stdout.channel.recv_exit_status()
    if not stream_output:
        output = stdout.read().decode('utf-8', errors='replace').strip()
        error = stderr.read().decode('utf-8', errors='replace').strip()
        if output: print(output)
        if error: print(error)
        return output
    return full_output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    # 1. INSTALL DOCKER
    print("\n--- INSTALLING DOCKER ---")
    install_cmd = """
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        echo "Docker installed."
    else
        echo "Docker already installed."
    fi
    """
    execute_command(client, install_cmd)
    
    # 2. FIND GIT REPOS
    print("\n--- SEARCHING FOR GIT REPOSITORIES ---")
    # Search in typical locations first to be fast, then full search if needed
    # limit depth to avoid hanging on huge FS
    execute_command(client, "find /root /home /opt /var -maxdepth 5 -name .git -type d 2>/dev/null")

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
