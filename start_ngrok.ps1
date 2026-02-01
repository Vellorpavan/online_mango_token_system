# Start Local Server and Ngrok

$port = 8085

# Kill any existing python servers on this port (optional, but good for cleanup)
# Stop-Process -Name "python" -ErrorAction SilentlyContinue

Write-Host "🚀 Starting Local Server on port $port..." -ForegroundColor Cyan
Start-Process "python" -ArgumentList "-m http.server $port" -WindowStyle Minimized

Write-Host "Waiting for server to start..."
Start-Sleep -Seconds 2

Write-Host "🌍 Starting Ngrok Tunnel..." -ForegroundColor Green
# Start ngrok and keep the window open so the user can see the URL
Start-Process ".\ngrok.exe" -ArgumentList "http $port"

Write-Host "`n✅ Application is running!" -ForegroundColor Yellow
Write-Host "1. Check the new Ngrok window for your public URL (e.g., https://xyz.ngrok-free.app)"
Write-Host "2. Add /index-enhanced.html to the end of that URL to see the app"
