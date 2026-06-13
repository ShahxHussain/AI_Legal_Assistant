import { useEffect, useRef, useState } from 'react';
import { useInView } from 'framer-motion';

export function useCountUp(end, duration = 1.8) {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: '-60px' });
  const [value, setValue] = useState(0);

  useEffect(() => {
    if (!inView) return;
    const startTime = performance.now();
    const tick = (now) => {
      const p = Math.min((now - startTime) / (duration * 1000), 1);
      const eased = 1 - (1 - p) ** 3;
      setValue(Math.round(eased * end));
      if (p < 1) requestAnimationFrame(tick);
    };
    const id = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(id);
  }, [inView, end, duration]);

  return { ref, value };
}
