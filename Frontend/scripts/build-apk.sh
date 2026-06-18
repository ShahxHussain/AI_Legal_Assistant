#!/usr/bin/env bash
# Build Court Companion release APK (Linux / macOS / Git Bash)
# Output: build/app/outputs/flutter-apk/app-release.apk

set -euo pipefail
cd "$(dirname "$0")/.."

API_URL="${API_BASE_URL:-https://ai-legal-assistant-fes8.onrender.com}"

echo "==> Court Companion — release APK"
echo "    API_BASE_URL=$API_URL"
echo

flutter pub get
flutter test
flutter build apk --release --dart-define="API_BASE_URL=$API_URL"

APK="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK" ]]; then
  SIZE=$(du -h "$APK" | cut -f1)
  echo
  echo "==> Done: $APK ($SIZE)"
  echo "    Upload to Google Drive and update web_frontend/src/config/site.js apkUrl"
else
  echo "Build finished but APK not found." >&2
  exit 1
fi
