$Server = "160.250.180.132"
$User = "root"
$Pass = "Do@nhkiet262205"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AUTO-RESTART SERVER SERVICES SCRIPT    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Target: $Server ($User)" -ForegroundColor Gray
Write-Host "Password: $Pass" -ForegroundColor Yellow
Write-Host "Action: Restarting containers on Port 3000 (Backend) & 8000 (Tuvi)" -ForegroundColor Gray
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. The script will trigger SSH." -ForegroundColor White
Write-Host "2. When prompted, type the password above and press Enter." -ForegroundColor White
Write-Host "   (Note: Password characters might not appear on screen)" -ForegroundColor White
Write-Host ""
Write-Host "Connecting..." -ForegroundColor Green

# Command to execute on the VPS
# Using bash logic to find containers by port or name and restart them
$RemoteCommand = "
    echo '--- 🔍 CHECKING RUNNING CONTAINERS ---';
    docker ps -a;
    echo '';

    echo '--- 🔄 RESTARTING AI-PHYSIO-BE (Port 3000) ---';
    # Try to find ID by port 3000
    ID_BE=`docker ps -a --filter 'publish=3000' --format '{{.ID}}' | head -n 1`;
    
    if [ -n '$ID_BE' ]; then
        echo 'Found Backend Container ID: '$ID_BE;
        docker restart $ID_BE;
    else
        echo '⚠️ Port 3000 container not found. Trying name glowlab_backend...';
        docker restart glowlab_backend || echo '❌ Failed to restart glowlab_backend';
    fi
    echo '';

    echo '--- 🔄 RESTARTING LASOTUVI (Port 8000) ---';
    # Try to find ID by port 8000
    ID_TUVI=`docker ps -a --filter 'publish=8000' --format '{{.ID}}' | head -n 1`;
    
    if [ -n '$ID_TUVI' ]; then
        echo 'Found Tuvi Container ID: '$ID_TUVI;
        docker restart $ID_TUVI;
    else
        echo '⚠️ Port 8000 container not found. Trying name lasotuvi...';
        docker restart lasotuvi || echo '❌ Failed to restart lasotuvi';
    fi
    echo '';

    echo '--- ✅ STATUS AFTER RESTART ---';
    docker ps;
"

# Execute SSH command
# -t forces pseudo-tty allocation which helps with some interactive commands if needed, 
# but mainly we just pass the command string.
ssh -t $User@$Server $RemoteCommand

Write-Host ""
Write-Host "Done. If services are running in 'docker ps' above, the server is fixed." -ForegroundColor Cyan
Pause
