$baseUrl = "http://160.250.180.132:3000"
$tuviUrl = "http://160.250.180.132:8000"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING VPS APIs" -ForegroundColor Cyan
Write-Host "Backend: $baseUrl" -ForegroundColor Cyan
Write-Host "Tuvi: $tuviUrl" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[1] Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/" -Method Get -TimeoutSec 5
    Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Register
Write-Host "[2] Register New User..." -ForegroundColor Yellow
$randomEmail = "test$(Get-Random -Minimum 1000 -Maximum 9999)@example.com"
$registerBody = @{
    username = $randomEmail  # Backend requires username to be email or phone
    password = "Test123!@#"
    confirmPassword = "Test123!@#"
    firstName = "Test"
    lastName = "User"
    email = $randomEmail
    phone = "0123456789"
    age = 25
    gender = "male"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/users/signUp" -Method Post -Body $registerBody -ContentType "application/json" -TimeoutSec 10
    Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "  Code: $($content.code)" -ForegroundColor Gray
    Write-Host "  Message: $($content.message)" -ForegroundColor Gray
    if ($content.data.accessToken) {
        Write-Host "  ✅ Got JWT Token!" -ForegroundColor Green
        $global:jwt = $content.data.accessToken
        $global:userId = $content.data.id
    }
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    $errorResponse = $_.ErrorDetails.Message
    if ($errorResponse) {
        Write-Host "  Error Details: $errorResponse" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Login
Write-Host "[3] Login Test..." -ForegroundColor Yellow
$loginBody = @{
    username = "test1234@example.com"
    password = "Test123!@#"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/auth/user" -Method Post -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "  Code: $($content.code)" -ForegroundColor Gray
    if ($content.data.accessToken) {
        Write-Host "  ✅ Login Success! Got JWT" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Failed (Expected - user may not exist)" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Get Current User (if we have JWT)
if ($global:jwt) {
    Write-Host "[4] Get Current User (Protected)..." -ForegroundColor Yellow
    try {
        $headers = @{
            "Authorization" = "Bearer $($global:jwt)"
        }
        $response = Invoke-WebRequest -Uri "$baseUrl/auth/me" -Method Get -Headers $headers -TimeoutSec 5
        Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
        $content = $response.Content | ConvertFrom-Json
        Write-Host "  User: $($content.data.email)" -ForegroundColor Gray
        Write-Host "  Credits: $($content.data.credits)" -ForegroundColor Gray
    } catch {
        Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 5: Tuvi Chart Creation
Write-Host "[5] Create Tuvi Chart..." -ForegroundColor Yellow
$chartBody = @{
    day = 15
    month = 3
    year = 1990
    hour_branch = 5
    gender = 1
    name = "Test User"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$tuviUrl/charts" -Method Post -Body $chartBody -ContentType "application/json" -TimeoutSec 15
    Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    if ($content.id) {
        Write-Host "  ✅ Chart Created! ID: $($content.id)" -ForegroundColor Green
    }
} catch {
    Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    $errorResponse = $_.ErrorDetails.Message
    if ($errorResponse) {
        Write-Host "  Error: $errorResponse" -ForegroundColor Red
    }
}
Write-Host ""

# Test 6: Facial Analysis Endpoint Check
Write-Host "[6] Facial Analysis Endpoint..." -ForegroundColor Yellow
try {
    $testBody = @{
        userId = "1"
        resultText = "Test"
        faceShape = "oval"
        harmonyScore = 85.5
        probabilities = @{}
        harmonyDetails = @{}
        metrics = @()
        annotatedImage = "base64_test"
        processedAt = (Get-Date -Format "o")
    } | ConvertTo-Json
    
    if ($global:jwt) {
        $headers = @{
            "Authorization" = "Bearer $($global:jwt)"
        }
        $response = Invoke-WebRequest -Uri "$baseUrl/facial-analysis" -Method Post -Body $testBody -ContentType "application/json" -Headers $headers -TimeoutSec 5
        Write-Host "  ✅ Endpoint works! Status: $($response.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Skipped (need JWT token)" -ForegroundColor Yellow
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "  ✅ Endpoint exists (401 Unauthorized - expected)" -ForegroundColor Green
    } else {
        Write-Host "  Status: $statusCode" -ForegroundColor Yellow
    }
}
Write-Host ""

# Test 7: Payment Packages
Write-Host "[7] Payment Packages..." -ForegroundColor Yellow
try {
    if ($global:jwt) {
        $headers = @{
            "Authorization" = "Bearer $($global:jwt)"
        }
        $response = Invoke-WebRequest -Uri "$baseUrl/payment/packages" -Method Get -Headers $headers -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
        $content = $response.Content | ConvertFrom-Json
        Write-Host "  Packages: $($content.data.Count)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠️  Skipped (need JWT token)" -ForegroundColor Yellow
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "  Status: $statusCode" -ForegroundColor Yellow
    } else {
        Write-Host "  ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend IP: 160.250.180.132" -ForegroundColor Gray
Write-Host "Auth Port: 3000" -ForegroundColor Gray
Write-Host "Tuvi Port: 8000" -ForegroundColor Gray
Write-Host ""
if ($global:jwt) {
    Write-Host "✅ JWT Token obtained - APIs authenticated" -ForegroundColor Green
    Write-Host "User ID: $($global:userId)" -ForegroundColor Gray
} else {
    Write-Host "⚠️  No JWT token - Some tests skipped" -ForegroundColor Yellow
}
