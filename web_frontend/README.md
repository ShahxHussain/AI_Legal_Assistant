# Court Companion — Landing Page

Marketing site for Court Companion (React + Vite + Tailwind + Framer Motion).

Based on `Web_frontend.md` in the repo root.

## Flutter app (citizen)

- **Home:** Ask in chat · Ask by voice · Court Companion Pro (beta info)
- Document analysis: optional attach inside chat — not a separate home entry

**Court Companion Pro** (lawyers) — full design: [`docs/COURT_COMPANION_PRO.md`](../docs/COURT_COMPANION_PRO.md)

## Quick start

```bash
cd web_frontend
npm install
npm run dev
```

Open http://localhost:5173

## Admin dashboard (React)

Organizer-only impact analytics — **not** in the Flutter app.

| URL | Purpose |
|-----|---------|
| http://localhost:5173/admin | Login + KPIs, charts, recent feedback |

1. Ensure backend is running with `ADMIN_API_KEY` and Supabase configured in `backend/.env`
2. Open `/admin` and paste the same `ADMIN_API_KEY`
3. Key is stored in `sessionStorage` for the browser tab only

Optional: set `VITE_API_BASE_URL` in `web_frontend/.env` if the API is not on `http://127.0.0.1:8000`.

## Build for production

```bash
npm run build
npm run preview
```

Output: `dist/` — deploy to Netlify, Vercel, GitHub Pages, or Render static site.

## Deploy to Vercel

### Option A — GitHub (recommended)

1. Commit and push `web_frontend/` to [GitHub](https://github.com/ShahxHussain/AI_Legal_Assistant).
2. Go to [vercel.com](https://vercel.com) → **Add New** → **Project**.
3. Import **AI_Legal_Assistant**.
4. Set **Root Directory** → `web_frontend` (Edit → type `web_frontend` → Continue).
5. Framework: **Vite** (auto-detected). Build: `npm run build`. Output: `dist`.
6. Click **Deploy**. Live URL in ~1–2 minutes.

### Option B — Vercel CLI (no git push)

```bash
cd web_frontend
npx vercel login
npx vercel
npx vercel --prod
```

## Links (configured)

| Resource | URL |
|----------|-----|
| **Web app (Flutter)** | https://ai-legal-assistant-two.vercel.app/ |
| **Landing page** | https://ai-legal-assistant-seven.vercel.app/ |
| **APK** | [Google Drive](https://drive.google.com/file/d/11kjhu_RQ4olDE5OpseV8hcw6jIq4YkG-/view?usp=sharing) |
| **GitHub** | [ShahxHussain/AI_Legal_Assistant](https://github.com/ShahxHussain/AI_Legal_Assistant) |
| **API** | https://ai-legal-assistant-fes8.onrender.com |

Edit `src/config/site.js` to update URLs.

## Stack

- React 18
- Vite 6
- Tailwind CSS 3
- Framer Motion
- React Icons (Remix)

## Project structure

```
web_frontend/
├── public/
├── src/
│   ├── admin/        # /admin dashboard (login, KPIs, charts)
│   ├── api/          # adminClient.js
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css     # color palette + global styles
├── index.html
└── package.json
```
