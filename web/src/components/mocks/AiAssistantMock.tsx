"use client";

import { useState } from "react";
import { ArrowLeft, Bot, Send, ChevronDown, X } from "lucide-react";

interface Message {
  id: string;
  role: "user" | "assistant";
  text: string;
}

const FIXED_MESSAGES: Message[] = [
  { id: "m1", role: "user", text: "What should I eat in Bali?" },
  {
    id: "m2",
    role: "assistant",
    text: "Try nasi campur, babi guling, and fresh seafood in Jimbaran. Warungs are cheaper and often better than restaurants!",
  },
  { id: "m3", role: "user", text: "Any tips for getting around?" },
  {
    id: "m4",
    role: "assistant",
    text: "Grab a Gojek scooter taxi for short hops — it's the fastest and cheapest way around town.",
  },
];

const TRIP_OPTIONS = [
  "General travel advice",
  "Bali Getaway · Bali, Indonesia",
  "Kerala Backwaters · Kerala, India",
  "Tokyo Adventure · Tokyo, Japan",
];

/** Display-only — the conversation is fixed; typing and the trip picker work, sending doesn't. */
export default function AiAssistantMock() {
  const [tripFilter, setTripFilter] = useState(TRIP_OPTIONS[1]);
  const [picking, setPicking] = useState(false);
  const [draft, setDraft] = useState("");

  return (
    <div className="relative flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <ArrowLeft size={15} className="text-teal-dark" />
        <span className="text-[12px] font-extrabold text-teal-dark">Travel Assistant</span>
      </div>

      <button
        type="button"
        onClick={() => setPicking(true)}
        className="flex items-center justify-between gap-2 border-b border-black/5 px-4 py-2.5 text-left"
      >
        <span className="shrink-0 text-[9.5px] text-black/50">Ask about</span>
        <span className="flex min-w-0 items-center gap-1 text-[9.5px] font-bold text-teal-dark">
          <span className="truncate">{tripFilter.split(" · ")[0]}</span>
          <ChevronDown size={11} className="shrink-0" />
        </span>
      </button>

      <div className="flex-1 space-y-1 overflow-y-auto px-1 py-3">
        {FIXED_MESSAGES.map((m) => (
          <div key={m.id} className={`flex ${m.role === "user" ? "justify-end" : "justify-start"} px-2`}>
            {m.role === "assistant" && (
              <span className="mr-1.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-teal/10">
                <Bot size={12} className="text-teal" />
              </span>
            )}
            <span
              className={`max-w-[78%] rounded-2xl px-3 py-2 text-[9.5px] ${
                m.role === "user" ? "bg-teal/15 text-teal-dark" : "bg-black/[0.05] text-black/80"
              }`}
            >
              {m.text}
            </span>
          </div>
        ))}
      </div>

      <div className="flex items-center gap-2 border-t border-black/5 px-2.5 py-2.5">
        <input
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="Message"
          className="flex-1 rounded-full bg-black/[0.04] px-3 py-2 text-[9.5px] text-teal-dark outline-none placeholder:text-black/35"
        />
        <button
          type="button"
          className="flex h-7 w-7 items-center justify-center rounded-full bg-teal-dark text-white"
        >
          <Send size={12} />
        </button>
      </div>

      {picking && (
        <div className="absolute inset-0 z-30 flex flex-col bg-white">
          <div className="flex items-center justify-between border-b border-black/5 px-3 py-2.5">
            <span className="text-[10px] font-bold text-teal-dark">Ask about a specific trip</span>
            <button type="button" onClick={() => setPicking(false)}>
              <X size={14} className="text-black/40" />
            </button>
          </div>
          <div className="flex-1 overflow-y-auto">
            {TRIP_OPTIONS.map((option) => (
              <button
                key={option}
                type="button"
                onClick={() => {
                  setTripFilter(option);
                  setPicking(false);
                }}
                className={`flex w-full items-center px-4 py-2.5 text-left text-[10.5px] font-medium hover:bg-black/[0.03] ${
                  option === tripFilter ? "text-teal-dark" : "text-black/70"
                }`}
              >
                {option}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
