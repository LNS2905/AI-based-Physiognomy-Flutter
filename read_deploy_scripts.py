import paramiko
import sys

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n[REMOTE] Executing: {command}")
    stdin, stdout, stderr = ssh.exec_command(command)
    output = stdout.read().decode('utf-8', errors='replace').strip()
    return output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)

    print("\n--- READING install-docker-vps.sh ---")
    print(execute_command(client, "cat /root/AIPhysiognomy/install-docker-vps.sh"))

    print("\n--- READING deploy-vps.sh ---")
    print(execute_command(client, "cat /root/AIPhysiognomy/deploy-vps.sh"))

    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
