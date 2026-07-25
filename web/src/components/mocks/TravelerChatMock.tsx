"use client";

import { useState } from "react";
import { ArrowLeft, Send } from "lucide-react";

interface ChatMessage {
  id: string;
  text: string;
  fromMe: boolean;
}

const FIXED_MESSAGES: ChatMessage[] = [
  { id: "m1", text: "Hey! Are you around Ubud this week too?", fromMe: false },
  { id: "m2", text: "Yes! Just got in yesterday 🙂", fromMe: true },
  { id: "m3", text: "Nice, have you tried the night market yet?", fromMe: false },
];

/** Display-only — the conversation is fixed; typing works, sending doesn't append anything. */
export default function TravelerChatMock({
  name,
  onBack,
}: {
  name: string;
  onBack: () => void;
}) {
  const [draft, setDraft] = useState("");

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-3 pb-2.5 pt-9">
        <button type="button" onClick={onBack} className="flex h-6 w-6 items-center justify-center">
          <ArrowLeft size={15} className="text-teal-dark" />
        </button>
        <span className="text-[12px] font-extrabold text-teal-dark">{name}</span>
      </div>

      <div className="flex-1 space-y-2 overflow-y-auto px-3 py-3">
        {FIXED_MESSAGES.map((m) => (
          <div key={m.id} className={`flex ${m.fromMe ? "justify-end" : "justify-start"}`}>
            <span
              className={`max-w-[75%] rounded-2xl px-3 py-1.5 text-[9.5px] ${
                m.fromMe ? "bg-teal/15 text-teal-dark" : "bg-black/[0.05] text-black/80"
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
    </div>
  );
}
