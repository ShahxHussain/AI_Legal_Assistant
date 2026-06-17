export const SITE = {
  name: 'Court Companion',
  tagline: 'Legal rights in your language.',
  /** Flutter web app — primary way to use Court Companion */
  webAppUrl: 'https://ai-legal-assistant-two.vercel.app/',
  landingUrl: 'https://ai-legal-assistant-seven.vercel.app/',
  apkUrl:
    'https://drive.google.com/uc?export=download&id=1t2dTJpqPHm4YOMAs8gbkLC22IyyyV04H',
  apkViewUrl:
    'https://drive.google.com/file/d/1t2dTJpqPHm4YOMAs8gbkLC22IyyyV04H/view?usp=sharing',
  githubUrl: 'https://github.com/ShahxHussain/AI_Legal_Assistant',
  proDocUrl:
    'https://github.com/ShahxHussain/AI_Legal_Assistant/blob/main/docs/COURT_COMPANION_PRO.md',
  apiUrl: 'https://ai-legal-assistant-fes8.onrender.com',
  healthUrl: 'https://ai-legal-assistant-fes8.onrender.com/health',
  adminPath: '/admin',
};

export const FOUNDER = {
  name: 'Syed Shah Hussain',
  role: 'Solo builder · AI for Civic Innovation 2026',
  bio: 'Built Court Companion after a personal moment of confusion with legal sections — to give every Pakistani citizen plain-language access to PPC, CrPC, and ATA, in the language they actually speak.',
  highlights: [
    'Full-stack: FastAPI RAG backend + Flutter (Android & Web)',
    '983 statute chunks · 7 text languages · English & Urdu voice',
    'Chat history, admin dashboard, Court Companion Pro (beta)',
    'Deployed on Render + Vercel · open repository on GitHub',
  ],
};

export const PRO_FEATURES = [
  {
    title: 'Agentic follow-up questions',
    text: 'AI asks for missing facts before citing the wrong PPC section — e.g. theft vs snatching.',
  },
  {
    title: 'Full case workspace',
    text: 'Upload FIR, pleadings, and orders — one case keeps complete context throughout.',
  },
  {
    title: 'Case-law retrieval',
    text: 'Public judgments from Supreme, High, and Sessions courts alongside statutes.',
  },
  {
    title: 'Gap & procedural flags',
    text: 'Surfaces limitation, bail category, and evidence gaps for counsel to verify.',
  },
];

export const MODELS = [
  {
    name: 'Meta Llama 3.3 70B Instruct Turbo',
    provider: 'Together.ai',
    role: 'Primary legal answers & regional languages',
  },
  {
    name: 'Meta Llama 3 8B Instruct Lite',
    provider: 'Together.ai',
    role: 'Fast answers · query translation for search',
  },
  {
    name: 'all-MiniLM-L6-v2',
    provider: 'sentence-transformers',
    role: 'FAISS embeddings over 983 legal chunks',
  },
];
