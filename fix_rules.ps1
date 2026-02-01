Write-Host "=== 🥭 Fixing Booking Issues ===" -ForegroundColor Yellow
Write-Host "Step 1: Logging into Firebase..." -ForegroundColor Cyan
cmd /c "firebase login"
if ($?) {
    Write-Host "Step 2: Deploying Security Rules..." -ForegroundColor Cyan
    cmd /c "firebase deploy --only firestore:rules"
    if ($?) {
        Write-Host "✅ SUCCESS! Booking is now fixed." -ForegroundColor Green
    } else {
        Write-Host "❌ Deployment failed. Please try again." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Login failed or was cancelled." -ForegroundColor Red
}
Read-Host -Prompt "Press Enter to close"
