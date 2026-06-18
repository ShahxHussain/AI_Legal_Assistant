export default function SimpleBarList({
  title,
  subtitle,
  items,
  labelKey = 'label',
  valueKey = 'count',
  pctKey = 'pct',
  formatLabel,
}) {
  const max = Math.max(...items.map((item) => item[valueKey] || 0), 1);

  return (
    <div className="admin-card flex h-full flex-col p-5 sm:p-6">
      <div>
        <p className="label-caps">Breakdown</p>
        <h3 className="mt-2 font-display text-lg font-semibold text-dark">{title}</h3>
        {subtitle ? (
          <p className="mt-1 text-[12px] text-neutral-500">{subtitle}</p>
        ) : null}
      </div>

      <div className="mt-5 flex-1 space-y-3.5">
        {items.length === 0 ? (
          <p className="rounded-xl border border-dashed border-neutral-200 bg-neutral-50/80 px-4 py-8 text-center text-sm text-neutral-500">
            No data in this period yet.
          </p>
        ) : (
          items.map((item, index) => {
            const rawLabel = item[labelKey];
            const label = formatLabel ? formatLabel(rawLabel) : rawLabel;
            return (
              <div key={`${rawLabel}-${index}`}>
                <div className="mb-1.5 flex items-center justify-between gap-2 text-[13px]">
                  <span className="min-w-0 truncate font-medium text-dark">{label}</span>
                  <span className="shrink-0 tabular-nums text-neutral-500">
                    {item[valueKey]}
                    {item[pctKey] != null ? (
                      <span className="ml-1 text-neutral-400">({item[pctKey]}%)</span>
                    ) : null}
                  </span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-primary-pale">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-primary to-primary-light transition-all duration-500"
                    style={{ width: `${((item[valueKey] || 0) / max) * 100}%` }}
                  />
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
