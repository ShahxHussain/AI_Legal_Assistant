# Build Court Companion release APK (Windows PowerShell)
# Output: build/app/outputs/flutter-apk/app-release.apk

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

$ApiUrl = if ($env:API_BASE_URL) { $env:API_BASE_URL } else {
    "https://ai-legal-assistant-fes8.onrender.com"
}

Write-Host "==> Court Companion — release APK"
Write-Host "    API_BASE_URL=$ApiUrl"
Write-Host ""

flutter pub get
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter build apk --release --dart-define="API_BASE_URL=$ApiUrl"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = Join-Path (Get-Location) "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apk) {
    $size = [math]::Round((Get-Item $apk).Length / 1MB, 1)
    Write-Host ""
    Write-Host "==> Done: $apk ($size MB)"
    Write-Host "    Upload to Google Drive and update web_frontend/src/config/site.js apkUrl"
} else {
    Write-Host "Build finished but APK not found at expected path." -ForegroundColor Red
    exit 1
}
