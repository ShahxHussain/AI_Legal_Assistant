function formatTime(value) {
  if (!value) return '—';
  try {
    return new Date(value).toLocaleString(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch (_) {
    return value;
  }
}

function RatingBadge({ rating }) {
  const helpful = rating === 'up';
  return (
    <span
      className={
        helpful
          ? 'inline-flex rounded-full bg-[#D4EDE4] px-2.5 py-1 text-[11px] font-semibold text-[#1F6F5F]'
          : 'inline-flex rounded-full bg-red-50 px-2.5 py-1 text-[11px] font-semibold text-red-600'
      }
    >
      {helpful ? 'Helpful' : 'Not helpful'}
    </span>
  );
}

function FeedbackCard({ row }) {
  return (
    <article className="rounded-xl border border-[#E5E7EB] bg-[#FAFBFC] p-3.5">
      <div className="flex items-start justify-between gap-2">
        <time className="text-xs text-[#6B7280]">{formatTime(row.created_at)}</time>
        <RatingBadge rating={row.rating} />
      </div>
      <div className="mt-2 flex flex-wrap gap-2 text-xs text-[#1F2937]">
        <span className="rounded-md bg-white px-2 py-1 ring-1 ring-[#E5E7EB]">
          {row.language || '—'}
        </span>
        <span className="rounded-md bg-white px-2 py-1 ring-1 ring-[#E5E7EB]">
          {row.channel || 'chat'}
        </span>
      </div>
      {row.comment ? (
        <p className="mt-2 text-sm leading-relaxed text-[#6B7280]">{row.comment}</p>
      ) : null}
    </article>
  );
}

export default function RecentFeedbackTable({ rows }) {
  return (
    <div className="rounded-2xl border border-[#E5E7EB] bg-white p-4 shadow-sm sm:p-5">
      <h3 className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[#6B7280] sm:text-[11px] sm:tracking-[0.14em]">
        Recent feedback
      </h3>

      {rows.length === 0 ? (
        <p className="mt-4 text-sm text-[#6B7280]">No feedback submitted yet.</p>
      ) : (
        <>
          <div className="mt-4 space-y-3 md:hidden">
            {rows.map((row) => (
              <FeedbackCard key={row.id} row={row} />
            ))}
          </div>

          <div className="mt-4 hidden overflow-x-auto md:block">
            <table className="min-w-full text-left text-sm">
              <thead>
                <tr className="border-b border-[#E5E7EB] text-[11px] uppercase tracking-wide text-[#6B7280]">
                  <th className="px-2 py-2 font-semibold">Time</th>
                  <th className="px-2 py-2 font-semibold">Rating</th>
                  <th className="px-2 py-2 font-semibold">Language</th>
                  <th className="px-2 py-2 font-semibold">Channel</th>
                  <th className="px-2 py-2 font-semibold">Comment</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} className="border-b border-[#F3F4F6]">
                    <td className="whitespace-nowrap px-2 py-3 text-[#6B7280]">
                      {formatTime(row.created_at)}
                    </td>
                    <td className="px-2 py-3">
                      <RatingBadge rating={row.rating} />
                    </td>
                    <td className="px-2 py-3 text-[#1F2937]">{row.language || '—'}</td>
                    <td className="px-2 py-3 text-[#1F2937]">{row.channel || 'chat'}</td>
                    <td className="max-w-xs truncate px-2 py-3 text-[#6B7280]">
                      {row.comment || '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
