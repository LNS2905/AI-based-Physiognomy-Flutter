$baseUrl = "160.250.180.132"
$port = 8000
$paths = @(
    "/api/v1/chat/start",
    "/chat/start",
    "/api/chat/start",
    "/v1/chat/start",
    "/tuvi/analyze",
    "/"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING DIFFERENT PATHS ON PORT $port" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($path in $paths) {
    Write-Host "[Testing $path]" -ForegroundColor Yellow
    
    try {
        $url = "http://${baseUrl}:${port}${path}"
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 3 -ErrorAction Stop
        
        Write-Host "  ✅ GET SUCCESS! Status: $($response.StatusCode)" -ForegroundColor Green
        $content = $response.Content
        if ($content.Length -gt 200) {
            $content = $content.Substring(0, 200) + "..."
        }
        Write-Host "  Response: $content" -ForegroundColor Gray
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode) {
            Write-Host "  Status: $statusCode" -ForegroundColor Yellow
        } else {
            Write-Host "  ❌ Connection failed" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
