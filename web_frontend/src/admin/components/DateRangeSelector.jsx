const RANGES = [
  { days: 7, label: '7d' },
  { days: 14, label: '14d' },
  { days: 30, label: '30d' },
  { days: 90, label: '90d' },
];

export default function DateRangeSelector({ value, onChange, disabled }) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="label-caps hidden sm:inline">Period</span>
      <div className="inline-flex rounded-xl border border-neutral-200 bg-white/80 p-1 shadow-sm">
        {RANGES.map(({ days, label }) => {
          const active = value === days;
          return (
            <button
              key={days}
              type="button"
              disabled={disabled}
              onClick={() => onChange(days)}
              className={`rounded-lg px-3.5 py-1.5 text-[13px] font-semibold transition-all duration-200 disabled:opacity-50 ${
                active ? 'admin-pill-active border' : 'admin-pill-idle border border-transparent'
              }`}
            >
              {label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
