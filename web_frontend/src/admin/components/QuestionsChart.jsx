export default function QuestionsChart({ series }) {
  const max = Math.max(...series.map((point) => point.count), 1);
  const visible = series.length > 14 ? series.slice(-14) : series;

  return (
    <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4 shadow-sm sm:p-5">
      <h3 className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[#6B7280] sm:text-[11px] sm:tracking-[0.14em]">
        Questions per day
      </h3>
      <p className="mt-1 text-[11px] text-[#9CA3AF] sm:hidden">
        Last {visible.length} days · swipe to see chart
      </p>

      <div className="-mx-1 mt-4 overflow-x-auto pb-1 sm:mx-0 sm:mt-5">
        <div className="flex h-36 min-w-[280px] items-end gap-1 px-1 sm:h-44 sm:min-w-0 sm:px-0">
          {visible.map((point) => (
            <div
              key={point.date}
              className="group flex min-w-[16px] flex-1 flex-col items-center justify-end sm:min-w-0"
            >
              <div
                className="w-full rounded-t-md bg-[#1F6F5F] transition-opacity group-hover:opacity-80"
                style={{
                  height: `${Math.max((point.count / max) * 100, point.count > 0 ? 8 : 2)}%`,
                  minHeight: point.count > 0 ? '8px' : '2px',
                }}
                title={`${point.date}: ${point.count}`}
              />
            </div>
          ))}
        </div>
      </div>

      <div className="mt-2 flex justify-between text-[10px] text-[#6B7280] sm:mt-3">
        <span>{visible[0]?.date?.slice(5)}</span>
        <span>{visible[visible.length - 1]?.date?.slice(5)}</span>
      </div>
    </div>
  );
}
