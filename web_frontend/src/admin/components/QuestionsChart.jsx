export default function QuestionsChart({ series, days }) {
  const max = Math.max(...series.map((point) => point.count), 1);
  const total = series.reduce((sum, p) => sum + p.count, 0);
  const avg = series.length ? (total / series.length).toFixed(1) : '0';

  return (
    <div className="admin-card p-5 sm:p-6">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="label-caps">Activity trend</p>
          <h3 className="mt-2 font-display text-lg font-semibold text-dark">
            Questions per day
          </h3>
        </div>
        <div className="flex gap-4 text-[12px] text-neutral-500">
          <span>
            <strong className="font-semibold text-dark">{total}</strong> total
          </span>
          <span>
            <strong className="font-semibold text-dark">{avg}</strong> avg/day
          </span>
          <span className="hidden sm:inline">{days}d range</span>
        </div>
      </div>

      <div className="mt-6 overflow-x-auto pb-1">
        <div
          className="flex h-44 min-w-[min(100%,640px)] items-end gap-1.5"
          style={{ minWidth: series.length > 20 ? `${series.length * 18}px` : undefined }}
        >
          {series.map((point) => {
            const heightPct = Math.max((point.count / max) * 100, point.count > 0 ? 6 : 2);
            return (
              <div
                key={point.date}
                className="group flex min-w-[12px] flex-1 flex-col items-center justify-end"
              >
                <div className="mb-1 hidden rounded-md bg-dark px-2 py-1 text-[10px] text-white opacity-0 transition group-hover:opacity-100 sm:block">
                  {point.count}
                </div>
                <div
                  className="w-full rounded-t-md bg-gradient-to-t from-primary to-primary-light transition-all duration-300 group-hover:from-primary-light group-hover:shadow-[0_0_12px_rgba(13,92,46,0.35)]"
                  style={{ height: `${heightPct}%`, minHeight: point.count > 0 ? '6px' : '2px' }}
                  title={`${point.date}: ${point.count} questions`}
                />
              </div>
            );
          })}
        </div>
      </div>

      <div className="mt-3 flex justify-between border-t border-neutral-100 pt-3 text-[11px] text-neutral-500">
        <span>{series[0]?.date?.slice(5) || '—'}</span>
        <span className="sm:hidden">{days}d</span>
        <span>{series[series.length - 1]?.date?.slice(5) || '—'}</span>
      </div>
    </div>
  );
}
