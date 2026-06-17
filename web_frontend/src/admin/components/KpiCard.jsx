export default function KpiCard({ label, value, hint }) {
  return (
    <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4 shadow-sm sm:p-5">
      <p className="text-[10px] font-semibold uppercase leading-snug tracking-[0.12em] text-[#6B7280] sm:text-[11px] sm:tracking-[0.14em]">
        {label}
      </p>
      <p className="mt-1.5 font-display text-2xl font-bold text-[#1F6F5F] sm:mt-2 sm:text-3xl">
        {value}
      </p>
      {hint ? (
        <p className="mt-1 text-[11px] leading-relaxed text-[#6B7280] sm:text-xs">{hint}</p>
      ) : null}
    </div>
  );
}
