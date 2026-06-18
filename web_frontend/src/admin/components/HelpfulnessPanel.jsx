export default function HelpfulnessPanel({ pct, up = 0, down = 0, days }) {
  const total = up + down;
  const safePct = pct != null ? pct : total > 0 ? Math.round((up / total) * 100) : null;
  const circumference = 2 * Math.PI * 42;
  const offset =
    safePct != null ? circumference - (safePct / 100) * circumference : circumference;

  return (
    <div className="admin-card flex h-full flex-col p-5 sm:p-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="label-caps">Answer quality</p>
          <h3 className="mt-2 font-display text-lg font-semibold text-dark">
            Helpfulness score
          </h3>
          <p className="mt-1 text-[12px] text-neutral-500">
            Citizen 👍 / 👎 ratings · {days}d window
          </p>
        </div>
      </div>

      <div className="mt-6 flex flex-1 flex-col items-center justify-center sm:flex-row sm:gap-8">
        <div className="relative h-32 w-32 shrink-0">
          <svg className="h-full w-full -rotate-90" viewBox="0 0 100 100">
            <circle
              cx="50"
              cy="50"
              r="42"
              fill="none"
              stroke="#ecfdf3"
              strokeWidth="10"
            />
            <circle
              cx="50"
              cy="50"
              r="42"
              fill="none"
              stroke="#0d5c2e"
              strokeWidth="10"
              strokeLinecap="round"
              strokeDasharray={circumference}
              strokeDashoffset={offset}
              className="transition-all duration-700"
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="font-display text-2xl font-bold text-primary">
              {safePct != null ? `${safePct}%` : '—'}
            </span>
            <span className="text-[10px] font-medium uppercase tracking-wider text-neutral-400">
              helpful
            </span>
          </div>
        </div>

        <div className="mt-4 w-full space-y-3 sm:mt-0 sm:w-auto">
          <div className="flex items-center justify-between gap-6 rounded-xl border border-primary/10 bg-primary-pale/40 px-4 py-3">
            <span className="text-sm font-medium text-neutral-600">Helpful</span>
            <span className="font-display text-xl font-bold text-primary">{up}</span>
          </div>
          <div className="flex items-center justify-between gap-6 rounded-xl border border-neutral-200 bg-neutral-50 px-4 py-3">
            <span className="text-sm font-medium text-neutral-600">Not helpful</span>
            <span className="font-display text-xl font-bold text-neutral-700">{down}</span>
          </div>
          <p className="text-center text-[11px] text-neutral-400 sm:text-left">
            {total === 0 ? 'No ratings yet in this period' : `${total} total ratings`}
          </p>
        </div>
      </div>
    </div>
  );
}
