# PowerShell script to deploy to Firebase Hosting

Write-Host "🚀 Deploying Mango Factory Token System..." -ForegroundColor Cyan

# Copy files to public folder
Write-Host "📁 Copying files to public folder..." -ForegroundColor Yellow
Copy-Item "index-enhanced.html" "public/index-enhanced.html" -Force
Copy-Item "index-premium.html" "public/index-premium.html" -Force
Copy-Item "index-enhanced.html" "public/index.html" -Force

Write-Host "✅ Files copied successfully!" -ForegroundColor Green

# Deploy to Firebase
Write-Host "`n🔥 Deploying to Firebase..." -ForegroundColor Yellow
firebase deploy

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Your app is now live at your Firebase hosting URL" -ForegroundColor Cyan
