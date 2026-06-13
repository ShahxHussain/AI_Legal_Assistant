# Cursor Prompt — Court Companion Landing Page
### React.js | Full Prompt — Paste this into Cursor AI

---

## PASTE THIS INTO CURSOR

```
Build me a complete, production-ready React.js landing page for a civic tech app called "Court Companion" — an AI-powered multilingual legal assistant for Pakistani citizens.

---

## TECH STACK

- React.js (functional components + hooks)
- Tailwind CSS for styling
- Framer Motion for animations
- React Icons (ri icons preferred)
- One single file: App.jsx (or split into components folder if cleaner)
- No backend needed — all static content
- Fully responsive: mobile-first

---

## COLOR PALETTE — STRICT, DO NOT DEVIATE

Use these exact CSS custom properties defined in index.css or a :root block:

--color-primary:        #1B5E20   /* Deep Pakistan green */
--color-primary-light:  #2E7D32   /* Medium green */
--color-primary-pale:   #E8F5E9   /* Very light green background tint */
--color-blue:           #0D47A1   /* Deep blue */
--color-blue-mid:       #1565C0   /* Medium blue */
--color-blue-light:     #E3F2FD   /* Light blue background tint */
--color-gold:           #F9A825   /* Gold accent — use sparingly */
--color-gold-light:     #FFF8E1   /* Gold tint */
--color-white:          #FFFFFF
--color-dark:           #0F0F0F   /* Near black for text */
--color-grey:           #6B7280   /* Muted body text */
--color-grey-light:     #F3F4F6   /* Light section backgrounds */

Typography:
- Headings: "Inter" or "Plus Jakarta Sans" (Google Fonts) — bold, tight tracking
- Body: "Inter" — regular weight, relaxed line height
- Urdu/Arabic display text: use "Noto Nastaliq Urdu" from Google Fonts for any Urdu script shown decoratively

---

## NAVBAR

- Fixed top, blurred glass effect (backdrop-filter: blur)
- Logo: green shield icon (RiShieldLine) + bold text "Court Companion"
- Nav links: Problem | Solution | How It Works | Features | Impact | Roadmap
- Smooth scroll to each section anchor
- Right side: a solid green "Download APK" button (pill shaped)
- On mobile: hamburger menu that slides down
- Background: white with subtle green bottom border on scroll

---

## SECTION 1 — HERO

Full viewport height section.

Layout: Two columns on desktop, stacked on mobile.

LEFT COLUMN:
- Small pill badge at top: green background, white text — "🇵🇰 Built for Pakistan"
- Main headline (large, bold, dark):
  "Your Legal Rights.
   In Your Language.
   On Your Phone."
- Subtext (grey, medium):
  "Court Companion is an AI legal assistant that answers questions about Pakistani criminal law — FIR procedures, bail, PPC and CrPC sections — in plain language, across 7 languages, grounded in real statute text."
- Two buttons side by side:
  1. PRIMARY: deep green pill button with download icon — "Download APK" — links to "#download"
  2. SECONDARY: outlined green pill button — "See How It Works" — smooth scrolls to #how-it-works
- Below buttons: three small trust badges inline:
  - ⚖️ PPC · CrPC · ATA
  - 🌐 7 Languages
  - 📱 Android + Web

RIGHT COLUMN:
- A stylized phone mockup (use a simple CSS/div phone frame — black rounded rectangle with screen inside)
- Inside the screen: simulate a chat UI
  - Top bar: "Court Companion" with green dot (online)
  - One user message bubble (right, green): "ایف آئی آر کس طرح درج ہوتی ہے؟"
  - One AI reply bubble (left, white with grey border):
    "CrPC کی دفعہ 154 کے تحت، FIR درج کرنا پولیس کی قانونی ذمہ داری ہے..."
  - Below the reply: small source chip — "[Source: CrPC §154]"
  - A blinking cursor at the end of the reply to simulate streaming
- Subtle animated glow behind the phone in green

BACKGROUND:
- Very light green-white gradient top to bottom
- Subtle geometric pattern (rotated squares or hexagons) in extremely low opacity green — like a watermark
- A thin green-to-blue gradient line at the very bottom of the section

---

## SECTION 2 — THE PROBLEM

id="problem"
Background: white

- Small section label (uppercase, gold, small): "WHY THIS EXISTS"
- Heading: "The Law Is Written. But Not For Everyone."
- Subtext: "For most citizens in Pakistan, the legal system is inaccessible — not because the laws don't exist, but because understanding them requires money, connections, or a law degree."

Three problem cards in a row (stacked on mobile):
Each card has:
- Icon (large, green)
- Bold heading
- 2-line description

Card 1:
- Icon: RiFileTextLine
- Heading: "Dense Legal Language"
- Text: "PPC, CrPC, ATA — hundreds of sections written for lawyers, not citizens."

Card 2:
- Icon: RiTranslate2
- Heading: "Language Barrier"
- Text: "Most citizens speak Urdu, Pashto, or Sindhi. The law is in English."

Card 3:
- Icon: RiMoneyDollarCircleLine
- Heading: "No Affordable Help"
- Text: "Legal advice is expensive. But the need for it can happen any moment."

Below the cards — a personal quote block:
- Left thick green border
- Italic dark text: "I was stopped and cited legal sections I didn't understand. I had no idea what my rights were in that moment."
- Below: "— Solo builder, Court Companion"

---

## SECTION 3 — THE SOLUTION

id="solution"
Background: very light green (#E8F5E9)

- Small label: "THE SOLUTION"
- Heading: "Meet Court Companion"
- Subtext: "Ask a legal question. Get a real answer. In your language."

Layout: Two columns

LEFT: Feature list
Each item: green checkmark icon + bold label + short description

✅ Grounded in Real Law
"Every answer is pulled from actual PPC, CrPC, and ATA statute text — 983 indexed chunks. Not hallucinated."

✅ 7 Languages
"English, Urdu (script), Roman Urdu, Pashto, Punjabi, Sindhi, Balochi."

✅ Text + Voice
"Type your question or speak it. Hear the answer read back to you."

✅ Android + Web
"Works on any Android phone and in Chrome. No login required."

✅ Source Citations
"Every answer shows which statute section it came from."

RIGHT: A language showcase card
- Heading: "Ask in any language"
- Show 4 example question pills, each in a different language with a flag/label:
  - 🇵🇰 Urdu: "ضمانت کیسے ملتی ہے؟"
  - Roman Urdu: "Chori ki saza kya hai?"
  - 🏔️ Pashto: "د FIR ثبتول څنګه کیږي؟"
  - 🇬🇧 English: "What is PPC Section 302?"
- Below: "→ All answered in the user's chosen language"

---

## SECTION 4 — HOW IT WORKS

id="how-it-works"
Background: white

- Small label: "UNDER THE HOOD"
- Heading: "Two Pipelines. One Goal."
- Subtext: "The legal database is in English. Your answer doesn't have to be."

Three step cards horizontal (or vertical on mobile), connected by animated dashed arrow line:

STEP 1 — "You Ask"
- Icon: RiMicLine (blue)
- Description: "Type or speak your question in any of 7 languages — Urdu, Pashto, Sindhi, or English."

STEP 2 — "System Searches"
- Icon: RiSearchLine (green)
- Description: "Your question is translated to English only for search. FAISS retrieves the most relevant PPC, CrPC, or ATA sections from 983 indexed chunks."

STEP 3 — "You Get an Answer"
- Icon: RiChatCheckLine (gold)
- Description: "The AI explains the retrieved statute in your chosen language — with source citations, streamed in real time."

Below the steps — a callout box (light blue background, blue left border):
Bold: "Search speaks English. Answer speaks your language."
Sub: "These are two completely separate processes. No machine-translated output."

Then a tech stack row (small logos/text pills):
RAG Pipeline | FAISS Vector Search | Gemma 4 31B | Llama 8B Translation | Flutter | FastAPI

---

## SECTION 5 — FEATURES

id="features"
Background: light grey (#F3F4F6)

- Small label: "FEATURES"
- Heading: "Everything You Need to Know Your Rights"

6 feature cards in a 3x2 grid (2x3 on mobile):

Each card: white background, rounded-xl, subtle shadow, hover: lift + green border

1. RiChat3Line — "Streaming Chat" — "Answers appear token by token, like a real conversation. No waiting for the full response."

2. RiMicLine — "Voice Input + Output" — "Speak your question. Hear the answer read aloud, phrase by phrase, as it streams."

3. RiGlobalLine — "7 Languages" — "Urdu script, Roman Urdu, Pashto, Punjabi, Sindhi, Balochi, English — with more planned."

4. RiFileSearchLine — "Source Citations" — "Every answer shows exactly which statute section it pulled from. Transparent and trustworthy."

5. RiUploadLine — "Document Upload" — "Upload a legal PDF or TXT file and ask questions about it directly."

6. RiWifiOffLine — "API Status Badge" — "Live online/offline indicator so you always know if the backend is reachable."

---

## SECTION 6 — IMPACT

id="impact"
Background: deep green (#1B5E20)

All text: white

- Small label (gold): "CIVIC IMPACT"
- Heading (white): "Built for the People Who Need It Most"
- Subtext (light green tint): "Not for lawyers. For the person who just got an FIR filed against them and doesn't know what that means."

Four large stat boxes in a row (2x2 on mobile):
Each: white number (very large, bold) + gold label underneath

- 983 — Statute Chunks Indexed
- 7 — Languages Supported
- 3 — Laws Covered (PPC, CrPC, ATA)
- 2 — Platforms (Android + Web)

Below stats — three persona cards (dark green background, slightly lighter):
Each: icon + title + one line

👨‍🌾 Rural Citizen — "No lawyer. No English. Needs to know their rights."
👩 FIR Filer — "First time dealing with police. Confused and scared."
🧑‍⚖️ Ordinary Person — "Stopped on the street. Cited legal sections. No idea what they mean."

---

## SECTION 7 — ROADMAP

id="roadmap"
Background: white

- Small label: "WHAT'S NEXT"
- Heading: "Working Prototype. Clear Path Forward."

Two column layout:

LEFT COLUMN — "✅ Built & Working" (green header)
List with green checkmarks:
- Text chat with streaming answers
- 7 text languages (Urdu, Pashto, Sindhi + more)
- Voice input + output (English)
- Document upload (PDF/TXT)
- RAG pipeline over 983 legal chunks
- Android APK + Web deployment
- Source citations per answer
- API online/offline status badge

RIGHT COLUMN — "🔜 Coming Next" (blue header)
List with blue arrow icons:
- Conversation memory (context across turns)
- Agentic follow-up questions
- Full voice in all 7 languages
- Admin analytics dashboard
- 👍 / 👎 feedback per answer
- User accounts + saved history
- Open source release
- Offline FAQ cache for low-connectivity areas

Below columns — a bottom CTA strip (light green background):
"This is a solo hackathon prototype. The problem is real. The path is clear."
+ big green "Download APK" button

---

## SECTION 8 — DOWNLOAD / CTA

id="download"
Background: deep blue (#0D47A1)

All text: white

- Heading: "Download Court Companion"
- Subtext: "Free. No login. Works on Android 7 and above."
- Large green pill button with download icon: "⬇ Download APK"
  - href="#" (placeholder — I'll add the real link)
- Below: small note in light blue: "Web version also available in Chrome — no install needed."
- Disclaimer box (white, semi-transparent, small text):
  "⚖️ Court Companion provides legal information only. It does not replace a qualified lawyer. Always consult a licensed legal professional for your specific situation."

---

## FOOTER

Background: #0F0F0F (near black)

Three columns:

LEFT:
- Logo: RiShieldLine icon + "Court Companion" in white bold
- Tagline: "Legal rights in your language."
- Small: "Built solo for AI for Civic Innovation Hackathon 2026"

CENTER:
- Heading: "Quick Links"
- Links: Problem | Solution | How It Works | Features | Roadmap | Download

RIGHT:
- Heading: "Tech Stack"
- Text list: FastAPI · Flutter · FAISS · RAG · Together.ai · Render
- GitHub placeholder link: "View Source →"

Bottom bar:
- Left: "© 2026 Court Companion. Solo project."
- Right: "Disclaimer: Legal information only. Not legal advice."
- Thin gold line above the bottom bar

---

## ANIMATIONS (use Framer Motion)

- Navbar: fade in from top on load
- Hero headline: staggered word-by-word fade-up
- Section headings: fade up when scrolled into view (use whileInView)
- Cards: staggered fade-up with slight scale (0.95 → 1)
- Step arrows in How It Works: draw in left to right
- Stats in Impact: count up from 0 when scrolled into view
- Phone mockup in Hero: subtle floating animation (up/down loop)
- Cursor blink in phone chat: CSS blink animation

---

## ADDITIONAL INSTRUCTIONS

- Add smooth scroll behavior globally (html { scroll-behavior: smooth })
- Each section must have a proper id attribute for navbar links
- Mobile breakpoints: everything stacks cleanly at < 768px
- No external UI libraries (no MUI, no Chakra) — only Tailwind + Framer Motion
- Use semantic HTML: section, nav, header, main, footer
- Add a subtle scrolled class to navbar via useEffect + scroll listener
- Keep all placeholder links as href="#" — I'll update them
- The Urdu script text in the phone mockup and language pills must use font-family: 'Noto Nastaliq Urdu' loaded from Google Fonts
- Add a small Pakistani flag emoji 🇵🇰 next to the hero badge only — nowhere else
- Console log nothing in production
- Export App as default export
```

---

## AFTER CURSOR GENERATES — CHECKLIST

Go through these before showing anyone:

- [ ] Replace all `href="#"` APK button links with your real APK download URL
- [ ] Add your real GitHub URL in the footer "View Source →" link
- [ ] Replace the backend health URL placeholder with `https://ai-legal-assistant-fes8.onrender.com/health`
- [ ] Test on mobile — check Urdu script renders correctly in the phone mockup
- [ ] Check all 6 section anchor links in the navbar work with smooth scroll
- [ ] If Framer Motion install is needed: `npm install framer-motion react-icons`
- [ ] Google Fonts to add in index.html:
  ```
  Inter, Plus Jakarta Sans, Noto Nastaliq Urdu
  ```

---

*Court Companion | Landing Page Prompt | June 2026*