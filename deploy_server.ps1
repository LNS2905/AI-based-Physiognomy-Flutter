$Server = "160.250.180.132"
$User = "root"
$Pass = "Do@nhkiet262205"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      SERVER DEPLOYMENT & RESTART TOOL    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Server: $Server" -ForegroundColor Gray
Write-Host "Services to Check:" -ForegroundColor Yellow
Write-Host "  1. GlowLab Backend (Port 3000)"
Write-Host "  2. LasoTuvi API    (Port 8000)"
Write-Host "  3. Physiognomy API (Port 8001)"
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Input the password when prompted: $Pass" -ForegroundColor Yellow
Write-Host ""

$RemoteCommand = "
    echo '--- 🔍 INITIAL SERVER STATUS ---';
    uptime;
    free -h;
    echo '';
    
    echo '--- 🐳 CHECKING CONTAINERS ---';
    docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}';
    echo '';

    function restart_service {
        PORT=\$1
        NAME_HINT=\$2
        echo \"--- 🔄 PROCESSING SERVICE ON PORT \$PORT (\$NAME_HINT) ---\";
        
        # Find container ID by port
        ID=\$(docker ps -a --filter \"publish=\$PORT\" --format \"{{.ID}}\" | head -n 1);
        
        if [ -n \"\$ID\" ]; then
            echo \"Found Container ID: \$ID\";
            echo \"Restarting...\";
            docker restart \$ID;
            echo \"Logs (last 10 lines):\";
            docker logs --tail 10 \$ID;
        else
            echo \"⚠️ Container on port \$PORT not found. Searching by name '\$NAME_HINT'...\";
            # Try finding by name
            ID_NAME=\$(docker ps -a --filter \"name=\$NAME_HINT\" --format \"{{.ID}}\" | head -n 1);
            
            if [ -n \"\$ID_NAME\" ]; then
                 echo \"Found Container ID by name: \$ID_NAME\";
                 echo \"Restarting...\";
                 docker restart \$ID_NAME;
                 echo \"Logs (last 10 lines):\";
                 docker logs --tail 10 \$ID_NAME;
            else
                 echo \"❌ FAILED: Could not find container for Port \$PORT or Name \$NAME_HINT\";
            fi
        fi
        echo '';
    }

    # Restart Sequence
    restart_service 3000 'glowlab_backend'
    restart_service 8000 'lasotuvi'
    restart_service 8001 'physiognomy'

    echo '--- ✅ FINAL STATUS ---';
    docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}';
"

# Execute SSH
ssh -t $User@$Server $RemoteCommand

Write-Host ""
Write-Host "Deployment/Restart sequence completed." -ForegroundColor Cyan
Pause
