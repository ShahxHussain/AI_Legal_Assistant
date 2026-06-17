export default function SimpleBarList({
  title,
  items,
  labelKey = 'label',
  valueKey = 'count',
  pctKey = 'pct',
}) {
  const max = Math.max(...items.map((item) => item[valueKey] || 0), 1);

  return (
    <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4 shadow-sm sm:p-5">
      <h3 className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[#6B7280] sm:text-[11px] sm:tracking-[0.14em]">
        {title}
      </h3>
      <div className="mt-3 space-y-3 sm:mt-4">
        {items.length === 0 ? (
          <p className="text-sm text-[#6B7280]">No data yet.</p>
        ) : (
          items.map((item) => (
            <div key={item[labelKey]}>
              <div className="mb-1 flex items-center justify-between gap-2 text-xs sm:text-sm">
                <span className="min-w-0 truncate font-medium text-[#1F2937]">
                  {item[labelKey]}
                </span>
                <span className="shrink-0 text-[#6B7280]">
                  {item[pctKey] != null ? `${item[pctKey]}%` : item[valueKey]}
                </span>
              </div>
              <div className="h-2 overflow-hidden rounded-full bg-[#E8F2EE]">
                <div
                  className="h-full rounded-full bg-[#1F6F5F]"
                  style={{ width: `${((item[valueKey] || 0) / max) * 100}%` }}
                />
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
