# Court Companion — Frontend

Flutter app for **Court Companion | AI Legal Multilingual Assistant**.

## Home screen

Three entry points (in order):

| Option | Screen | Description |
|--------|--------|-------------|
| **Ask in chat** | `ChatScreen` | Text Q&A, streaming, chat history sidebar, optional PDF/TXT attach |
| **Ask by voice** | `VoiceScreen` | Mic input + spoken answers (English voice today) |
| **Court Companion Pro** | `ProScreen` | Beta product info for lawyers — full workspace coming later ([`../docs/COURT_COMPANION_PRO.md`](../docs/COURT_COMPANION_PRO.md)) |

> **Note:** Document analysis is **not** a separate home button. Users can attach PDF/TXT inside chat via the clip icon, or call `POST /analyze-document` on the API directly.

## Prerequisites

- Flutter SDK 3.6+
- Backend API running (see `../backend/README.md`)

## Run (development)

### 1. Start backend

```powershell
cd ..\backend
.venv\Scripts\uvicorn main:app --host 0.0.0.0 --port 8000
```

### 2. Run app

**Chrome / Edge (web)** — uses `http://localhost:8000` automatically:

```powershell
cd Frontend
flutter pub get
flutter run -d chrome
```

**Android emulator** — uses `http://10.0.2.2:8000` automatically:

```powershell
flutter run -d android
```

> Do **not** use `10.0.2.2` on web/Windows — that IP is Android-emulator only.

**Physical device** (use your PC's LAN IP):

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.XXX:8000
```

**Production / deployed backend:**

```powershell
flutter run --dart-define=API_BASE_URL=https://your-app.onrender.com
```

## Build Flutter Web (production)

```powershell
flutter build web --release
```

Release builds use the Render API automatically. No APK download needed for users — share a web link instead.

### Deploy from GitHub → Vercel

1. Create a **second** Vercel project (landing uses `web_frontend`).
2. Set **Root Directory** to `Frontend`.
3. Push to GitHub — Vercel runs `scripts/vercel-build.sh` via `vercel.json`.

Full steps: [`../docs/FLUTTER_WEB_DEPLOY.md`](../docs/FLUTTER_WEB_DEPLOY.md)

## Build APK

Release builds use the **Render production API** automatically (`api_config.dart`). Override only if needed:

```powershell
cd Frontend
.\scripts\build-apk.ps1
```

Or manually:

```powershell
flutter pub get
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://ai-legal-assistant-fes8.onrender.com
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

**After build:** upload the APK to Google Drive (or GitHub Releases), then update the download link in `web_frontend/src/config/site.js` (`apkUrl` / `apkViewUrl`).

| Check | Detail |
|-------|--------|
| Version | `pubspec.yaml` → `version: x.y.z+build` (Android `versionCode` = build number) |
| API | Release → `https://ai-legal-assistant-fes8.onrender.com` |
| Signing | Debug keystore (hackathon/demo). For Play Store, add a release keystore in `android/app/build.gradle`. |
| Permissions | Internet, microphone (voice), Bluetooth (some STT devices) — see `AndroidManifest.xml` |

## Project structure

```text
Frontend/
├── lib/
│   ├── main.dart
│   ├── config/api_config.dart
│   ├── models/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── assistant_stream.dart
│   │   ├── chat_session_store.dart
│   │   └── device_identity.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── voice_screen.dart
│   │   ├── pro_screen.dart
│   │   └── info_screen.dart
│   └── widgets/
└── android/
```

## Features

### Citizen (free)

- Home: Ask in chat · Ask by voice · Court Companion Pro (beta info)
- Streaming legal Q&A with source citations (`POST /ask/stream`)
- 7 reply languages (picker on home + chat)
- Chat history sidebar; **new empty chat** each time you open from home; past threads via sidebar
- Optional document attach in chat → `/analyze-document`
- API health badge

### Court Companion Pro (beta — info only)

- `ProScreen` explains the planned professional case workspace
- Case upload, agentic follow-ups, case-law RAG — see [`docs/COURT_COMPANION_PRO.md`](../docs/COURT_COMPANION_PRO.md)
- **Start a Pro case** button disabled until workspace ships
