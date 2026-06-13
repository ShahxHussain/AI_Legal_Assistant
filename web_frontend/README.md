# Court Companion — Landing Page

Marketing site for Court Companion (React + Vite + Tailwind + Framer Motion).

Based on `Web_frontend.md` in the repo root.

## Quick start

```bash
cd web_frontend
npm install
npm run dev
```

Open http://localhost:5173

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

- **APK:** [Google Drive](https://drive.google.com/file/d/1t2dTJpqPHm4YOMAs8gbkLC22IyyyV04H/view?usp=sharing)
- **GitHub:** [ShahxHussain/AI_Legal_Assistant](https://github.com/ShahxHussain/AI_Legal_Assistant)
- **API:** https://ai-legal-assistant-fes8.onrender.com

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
│   ├── components/   # Navbar, Hero, sections, Footer
│   ├── utils/        # motion helpers
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css     # color palette + global styles
├── index.html
└── package.json
```
