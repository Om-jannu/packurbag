"use client";

import { useState } from "react";
import { ChevronRight, MapPinOff } from "lucide-react";
import PhoneNavBar, { type NavTab } from "./PhoneNavBar";
import TravelerChatMock from "./TravelerChatMock";

const travelers = [
  { name: "Aisha", distance: "0.6 km away", color: "bg-coral" },
  { name: "Marco", distance: "1.2 km away", color: "bg-amber" },
  { name: "Priya", distance: "2.4 km away", color: "bg-teal" },
  { name: "Kenji", distance: "3.1 km away", color: "bg-coral" },
];

interface NearbyMockProps {
  onNavigate?: (tab: NavTab) => void;
}

export default function NearbyMock({ onNavigate }: NearbyMockProps) {
  const [sharing, setSharing] = useState(true);
  const [openChatWith, setOpenChatWith] = useState<string | null>(null);

  if (openChatWith) {
    return <TravelerChatMock name={openChatWith} onBack={() => setOpenChatWith(null)} />;
  }

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="border-b border-black/5 px-4 pb-3 pt-9">
        <span className="text-[13px] font-extrabold text-teal-dark">Nearby Travelers</span>
      </div>

      <button
        type="button"
        onClick={() => setSharing((s) => !s)}
        className="flex w-full items-center justify-between border-b border-black/5 px-4 py-3 text-left"
      >
        <div>
          <p className="text-[10px] font-semibold text-teal-dark">Share my location</p>
          <p className="text-[8px] text-black/40">
            {sharing ? "Other nearby travelers can see and message you" : "Turn on to find travelers near you"}
          </p>
        </div>
        <div
          className={`flex h-4 w-8 shrink-0 items-center rounded-full p-0.5 transition-colors ${
            sharing ? "bg-teal" : "bg-black/15"
          }`}
        >
          <div
            className={`h-3 w-3 rounded-full bg-white transition-transform ${
              sharing ? "translate-x-4" : "translate-x-0"
            }`}
          />
        </div>
      </button>

      {sharing ? (
        <div className="flex-1 space-y-1 overflow-y-auto px-2 pt-2">
          {travelers.map((t) => (
            <button
              key={t.name}
              type="button"
              onClick={() => setOpenChatWith(t.name)}
              className="flex w-full items-center gap-2.5 rounded-xl px-2 py-2 text-left transition hover:bg-black/[0.02]"
            >
              <div
                className={`flex h-8 w-8 items-center justify-center rounded-full ${t.color} text-[10px] font-bold text-white`}
              >
                {t.name[0]}
              </div>
              <div className="flex-1">
                <p className="text-[10px] font-bold text-teal-dark">{t.name}</p>
                <p className="text-[8px] text-black/40">{t.distance}</p>
              </div>
              <ChevronRight size={13} className="text-black/30" />
            </button>
          ))}
        </div>
      ) : (
        <div className="flex flex-1 flex-col items-center justify-center gap-2 px-6 text-center">
          <MapPinOff size={22} className="text-black/20" />
          <p className="text-[9px] text-black/40">Discovery is off</p>
          <p className="text-[8px] text-black/30">
            Turn on location sharing above to see travelers near you and start chatting.
          </p>
        </div>
      )}

      <PhoneNavBar active="nearby" enabled={onNavigate ? ["home", "trips"] : []} onSelect={onNavigate} />
    </div>
  );
}
