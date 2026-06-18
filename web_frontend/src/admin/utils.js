const TOPIC_LABELS = {
  fir: 'FIR & registration',
  bail: 'Bail',
  arrest_rights: 'Arrest & custody',
  theft: 'Theft',
  ppc_sections: 'PPC sections',
  fraud: 'Fraud & cheating',
  assault: 'Assault & hurt',
  terrorism: 'Anti-terrorism',
  other: 'Other legal',
};

export function formatTopicLabel(topic) {
  if (!topic) return '—';
  return TOPIC_LABELS[topic] || String(topic).replace(/_/g, ' ');
}

export function formatLanguageLabel(lang) {
  if (!lang) return '—';
  const map = {
    english: 'English',
    urdu_script: 'Urdu',
    roman_urdu: 'Roman Urdu',
    pashto: 'Pashto',
    punjabi: 'Punjabi',
    sindhi: 'Sindhi',
    balochi: 'Balochi',
  };
  return map[lang] || lang;
}

export function formatDateRangeLabel(days) {
  if (days === 7) return 'Last 7 days';
  if (days === 14) return 'Last 14 days';
  if (days === 30) return 'Last 30 days';
  if (days === 90) return 'Last 90 days';
  return `Last ${days} days`;
}

export function formatShortDate(iso) {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleDateString(undefined, {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  } catch (_) {
    return iso;
  }
}
