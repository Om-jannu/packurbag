"use client";

import { useEffect, useRef, useState } from "react";
import HomeMock from "./HomeMock";
import TripsMock from "./TripsMock";
import NearbyMock from "./NearbyMock";
import type { NavTab } from "./PhoneNavBar";

const SEQUENCE: { tab: "home" | "trips" | "nearby"; label: string }[] = [
  { tab: "home", label: "Dashboard" },
  { tab: "trips", label: "Trips" },
  { tab: "nearby", label: "Nearby" },
];

const ADVANCE_MS = 5000;

export default function AppWalkthroughMock() {
  const [index, setIndex] = useState(0);
  const [paused, setPaused] = useState(false);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    if (paused) return;
    timerRef.current = setInterval(() => {
      setIndex((i) => (i + 1) % SEQUENCE.length);
    }, ADVANCE_MS);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [paused]);

  const jumpTo = (tab: NavTab) => {
    const target = SEQUENCE.findIndex((s) => s.tab === tab);
    if (target === -1) return;
    setIndex(target);
  };

  const active = SEQUENCE[index].tab;

  return (
    <div
      className="flex h-full flex-col"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
    >
      <div key={active} className="h-full animate-fade-in">
        {active === "home" && <HomeMock onNavigate={jumpTo} />}
        {active === "trips" && <TripsMock onNavigate={jumpTo} />}
        {active === "nearby" && <NearbyMock onNavigate={jumpTo} />}
      </div>
    </div>
  );
}
