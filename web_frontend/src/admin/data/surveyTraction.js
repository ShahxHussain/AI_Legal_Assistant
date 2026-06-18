/** Snapshot from Google Form — update counts when new responses arrive. */
export const SURVEY_FORM = {
  title: 'Quick Survey: Legal Awareness in Pakistan',
  viewUrl:
    'https://docs.google.com/forms/d/12fl8A47WUx_E8mPSqK0p1Q18nnjjwYvsq1i9mKbmOis/viewform',
  editUrl:
    'https://docs.google.com/forms/d/12fl8A47WUx_E8mPSqK0p1Q18nnjjwYvsq1i9mKbmOis/edit',
  responseCount: 7,
  updatedAt: '2026-06-17',
};

export const SURVEY_HIGHLIGHTS = [
  {
    label: 'Faced legal confusion',
    value: '86%',
    hint: '6 of 7 did not understand FIR, notice, or procedure',
  },
  {
    label: 'Would use the app',
    value: '100%',
    hint: '5 Yes · 2 Maybe · 0 No',
  },
  {
    label: 'Smartphone + internet',
    value: '100%',
    hint: 'All respondents — mobile-first validated',
  },
  {
    label: 'Trust via law citations',
    value: '86%',
    hint: 'Want exact statute quotes (alone or with lawyer review)',
  },
];

export const SURVEY_SECTIONS = [
  {
    id: 'confusion',
    question:
      "Have you ever faced a situation where you didn't understand a legal term, FIR, notice, or police procedure?",
    type: 'single',
    total: 7,
    options: [
      { label: 'Yes', count: 6, pct: 85.7 },
      { label: 'No', count: 1, pct: 14.3 },
    ],
  },
  {
    id: 'action',
    question: 'What did you do in that situation?',
    type: 'multi',
    note: 'Respondents could select multiple options',
    total: 7,
    options: [
      { label: 'Asked a lawyer', count: 2, pct: 28.6 },
      { label: 'Asked family or friends', count: 5, pct: 71.4 },
      { label: 'Searched online', count: 5, pct: 71.4 },
      { label: 'Did nothing', count: 0, pct: 0 },
    ],
  },
  {
    id: 'language',
    question: 'Which language would you prefer a legal explanation in?',
    type: 'multi',
    note: 'Multi-select — validates 7-language product direction',
    total: 7,
    options: [
      { label: 'Urdu (اردو)', count: 6, pct: 85.7 },
      { label: 'Roman Urdu', count: 2, pct: 28.6 },
      { label: 'English', count: 3, pct: 42.9 },
      { label: 'Pashto', count: 3, pct: 42.9 },
      { label: 'Punjabi', count: 0, pct: 0 },
      { label: 'Sindhi', count: 0, pct: 0 },
      { label: 'Balochi', count: 0, pct: 0 },
    ],
  },
  {
    id: 'legalese',
    question: 'Comfort reading dense legal language (1 = not at all, 5 = very)',
    type: 'scale',
    total: 7,
    options: [
      { label: '1 — Not comfortable', count: 2, pct: 28.6 },
      { label: '2', count: 1, pct: 14.3 },
      { label: '3', count: 3, pct: 42.9 },
      { label: '4', count: 1, pct: 14.3 },
      { label: '5 — Very comfortable', count: 0, pct: 0 },
    ],
  },
  {
    id: 'smartphone',
    question: 'Do you have access to a smartphone with internet?',
    type: 'single',
    total: 7,
    options: [
      { label: 'Yes', count: 7, pct: 100 },
      { label: 'No', count: 0, pct: 0 },
      { label: 'Sometimes', count: 0, pct: 0 },
    ],
  },
  {
    id: 'would_use',
    question:
      'Would you use a free app that explains your legal rights in plain language, in your own language?',
    type: 'single',
    total: 7,
    options: [
      { label: 'Yes', count: 5, pct: 71.4 },
      { label: 'Maybe', count: 2, pct: 28.6 },
      { label: 'No', count: 0, pct: 0 },
    ],
  },
  {
    id: 'trust',
    question: 'What would make you trust an AI giving legal information?',
    type: 'multi',
    total: 7,
    options: [
      { label: 'Shows exact law it quotes from', count: 2, pct: 28.6 },
      { label: 'Real lawyer has checked it', count: 1, pct: 14.3 },
      { label: 'Both of the above', count: 6, pct: 85.7 },
      { label: "I'd never fully trust AI", count: 0, pct: 0 },
    ],
  },
];
