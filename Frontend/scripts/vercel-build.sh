#!/usr/bin/env bash
# Vercel build: install Flutter SDK (cached in .flutter/) and compile web release.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.29.3}"
FLUTTER_DIR="${FLUTTER_DIR:-$ROOT_DIR/.flutter}"
API_URL="${API_BASE_URL:-https://ai-legal-assistant-fes8.onrender.com}"

echo "==> Court Companion Flutter web build"
echo "    API_BASE_URL=$API_URL"

if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
  echo "==> Installing Flutter ($FLUTTER_VERSION) into $FLUTTER_DIR"
  rm -rf "$FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export CI=true
export PUB_CACHE="${PUB_CACHE:-$ROOT_DIR/.pub-cache}"

flutter --version
flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get
echo "==> Compiling web release (2–5 min)..."
flutter build web --release --dart-define="API_BASE_URL=$API_URL"

if [[ ! -f build/web/index.html ]]; then
  echo "==> ERROR: build/web/index.html missing — flutter build web failed"
  exit 1
fi

echo "==> Build complete. Output:"
ls -la build/web | head -20
