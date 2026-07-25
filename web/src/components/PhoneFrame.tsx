import type { ReactNode } from "react";

export default function PhoneFrame({ children }: { children: ReactNode }) {
  return (
    <div className="relative mx-auto h-[560px] w-[280px] shrink-0 rounded-[2.75rem] border-[8px] border-[#0b2530] bg-[#0b2530] shadow-2xl shadow-teal/20">
      {/* Dynamic island */}
      <div className="absolute left-1/2 top-0 z-20 h-6 w-28 -translate-x-1/2 rounded-b-2xl bg-[#0b2530]" />

      <div className="relative h-full w-full overflow-hidden rounded-[2.25rem] bg-white text-left">
        {children}
      </div>

      {/* Home indicator */}
      <div className="absolute bottom-1.5 left-1/2 z-20 h-1 w-24 -translate-x-1/2 rounded-full bg-white/70" />
    </div>
  );
}
