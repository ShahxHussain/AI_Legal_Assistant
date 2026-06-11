# Court Companion — Frontend

Flutter mobile app for **Court Companion | AI Legal Bilingual Assistant**.

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

## Build APK

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://your-app.onrender.com
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Project structure

```text
Frontend/
├── lib/
│   ├── main.dart
│   ├── config/api_config.dart
│   ├── models/
│   ├── services/api_service.dart
│   ├── screens/chat_screen.dart
│   └── widgets/
└── android/
```

## Features (MVP)

- Chat UI for legal questions
- Calls `POST /ask` on backend
- Shows answer + source citations + disclaimer
- API health indicator in app bar
- English and Roman Urdu questions supported (backend handles language)
