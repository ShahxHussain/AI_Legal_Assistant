# Deploy Court Companion — Flutter Web

Use the **same Flutter app** as the APK in the browser — no install, works on iPhone, Android, and desktop. Users open a link instead of downloading an APK.

| Site | What |
|------|------|
| `ai-legal-assistant-seven.vercel.app` | React **landing** + `/admin` (root: `web_frontend`) |
| **New Vercel project** (below) | Flutter **web app** (root: `Frontend`) |

---

## Deploy from GitHub repo → Vercel (recommended)

Each push to the connected branch rebuilds and deploys automatically.

### One-time setup

1. Push this repo to GitHub (include `Frontend/scripts/vercel-build.sh` and `Frontend/vercel.json`).

2. [vercel.com](https://vercel.com) → **Add New** → **Project** → import your repo.

3. **Important:** This must be a **second** Vercel project (separate from the landing page).

4. **Project settings:**

   | Setting | Value |
   |---------|--------|
   | **Root Directory** | `Frontend` |
   | **Framework Preset** | Other |
   | **Build Command** | *(leave empty — uses `vercel.json`)* |
   | **Output Directory** | *(leave empty — uses `vercel.json`)* |
   | **Install Command** | *(leave empty — uses `vercel.json`)* |

5. **Environment variables** (optional — default is Render production API):

   | Name | Value |
   |------|--------|
   | `API_BASE_URL` | `https://ai-legal-assistant-fes8.onrender.com` |

6. Click **Deploy**. First build takes ~5–8 minutes (downloads Flutter SDK). Later builds are faster if Vercel caches `.flutter/`.

7. Copy the deployment URL (e.g. `https://court-companion-app.vercel.app`) and add **Open App** on the landing page.

### How the repo build works

`Frontend/vercel.json` runs `scripts/vercel-build.sh`, which:

1. Clones Flutter `stable` into `Frontend/.flutter/` (cached between builds when possible)
2. Runs `flutter build web --release` with your `API_BASE_URL`
3. Outputs static files to `Frontend/build/web/`

### Troubleshooting

| Issue | Fix |
|-------|-----|
| `bash: scripts/vercel-build.sh: Permission denied` | Script must be executable in git: `git update-index --chmod=+x Frontend/scripts/vercel-build.sh` |
| Build fails on `google_fonts` / `FontWeight` | Vercel uses pinned Flutter **3.29.3** in `vercel-build.sh` — do not set `FLUTTER_VERSION=stable` unless you upgrade `google_fonts` for Dart 3.12+ |
| API offline in browser | Set `API_BASE_URL` env var; wake Render with `/health` first |
| Wrong root directory | Must be **`Frontend`**, not repo root |

---

## Build locally (optional)

```powershell
cd Frontend
flutter pub get
flutter build web --release
```

Release builds use Render API automatically (`api_config.dart`).

Output: **`Frontend/build/web/`**

Test:

```powershell
cd build\web
python -m http.server 8080
```

---

## Manual deploy (CLI)

After a local build:

```powershell
cd Frontend\build\web
npx vercel --prod
```

---

## Other hosts

### Netlify (drag & drop)

Upload **`Frontend/build/web`** after `flutter build web --release`.

### Firebase Hosting

```powershell
cd Frontend
flutter build web --release
firebase deploy --only hosting
```

(`public` directory: `build/web`)

---

## Link from landing page

In `web_frontend`, point **Open Court Companion** to your Flutter web Vercel URL.

Keep APK as secondary download for users who prefer installable Android app.

---

## Backend / CORS

Render API allows browser origins (`allow_origins=["*"]` in `main.py`). No change needed for a new web domain.

**Cold start:** First request after idle may take ~30–50s on Render free tier.

---

## Web vs APK

| | **Flutter Web** | **APK** |
|---|-----------------|---------|
| Install | None — open link | Download + install |
| iPhone | ✅ Safari | ❌ |
| Demo / judges | ✅ QR → instant | Download wait |
| Mic / Urdu voice | ✅ (browser permission) | ✅ |

---

## Quick checklist

- [ ] Second Vercel project, root directory **`Frontend`**
- [ ] `API_BASE_URL` env var set (optional)
- [ ] Deploy succeeds → test chat + voice in browser
- [ ] Landing page **Open App** link updated
- [ ] URL in Devpost / `SUBMISSION_FinalRound.md`
