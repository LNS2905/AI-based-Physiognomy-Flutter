$baseUrl = "160.250.180.132"
$ports = @(3000, 3001, 5000, 8000, 8080, 4000)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING CHATBOT API ON DIFFERENT PORTS" -ForegroundColor Cyan
Write-Host "Server: $baseUrl" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($port in $ports) {
    Write-Host "[Testing Port $port]" -ForegroundColor Yellow
    
    try {
        $url = "http://${baseUrl}:${port}/api/v1/chat/start"
        Write-Host "  URL: $url" -ForegroundColor Gray
        
        $body = @{
            user_id = 1
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri $url -Method Post -Body $body -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        
        Write-Host "  ✅ SUCCESS! Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  Response: $($response.Content)" -ForegroundColor Green
        Write-Host ""
        
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "Unable to connect" -or $errorMsg -match "ConnectFailure" -or $errorMsg -match "timed out") {
            Write-Host "  ❌ Port closed or timeout" -ForegroundColor Red
        } elseif ($errorMsg -match "404") {
            Write-Host "  ⚠️  Port open but endpoint not found (404)" -ForegroundColor Yellow
        } elseif ($errorMsg -match "500") {
            Write-Host "  ⚠️  Port open, endpoint exists but server error (500)" -ForegroundColor Yellow
        } else {
            Write-Host "  ⚠️  Response: $errorMsg" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
