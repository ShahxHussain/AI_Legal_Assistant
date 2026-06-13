export const SITE = {
  name: 'Court Companion',
  tagline: 'Legal rights in your language.',
  apkUrl:
    'https://drive.google.com/uc?export=download&id=1t2dTJpqPHm4YOMAs8gbkLC22IyyyV04H',
  apkViewUrl:
    'https://drive.google.com/file/d/1t2dTJpqPHm4YOMAs8gbkLC22IyyyV04H/view?usp=sharing',
  githubUrl: 'https://github.com/ShahxHussain/AI_Legal_Assistant',
  apiUrl: 'https://ai-legal-assistant-fes8.onrender.com',
  healthUrl: 'https://ai-legal-assistant-fes8.onrender.com/health',
};

export const FOUNDER = {
  name: 'Syed Shah Hussain',
  role: 'Solo builder · AI for Civic Innovation 2026',
  bio: 'Built Court Companion after a personal moment of confusion with legal sections — to give every Pakistani citizen plain-language access to PPC, CrPC, and ATA, in the language they actually speak.',
  highlights: [
    'Full-stack: FastAPI RAG backend + Flutter (Android & Web)',
    '983 statute chunks · 7-language pipeline · voice + streaming chat',
    'Deployed on Render · open repository on GitHub',
  ],
};

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
