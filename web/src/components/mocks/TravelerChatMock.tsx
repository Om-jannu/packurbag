"use client";

import { useState } from "react";
import { ArrowLeft, Send } from "lucide-react";

interface ChatMessage {
  id: string;
  text: string;
  fromMe: boolean;
}

const AUTO_REPLIES = [
  "Hey! Yes, staying near the old town 🙂",
  "Have you tried the night market yet?",
  "Nice! Let's grab coffee sometime this week.",
];

export default function TravelerChatMock({
  name,
  onBack,
}: {
  name: string;
  onBack: () => void;
}) {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [draft, setDraft] = useState("");
  const [replyIndex, setReplyIndex] = useState(0);

  const send = () => {
    const text = draft.trim();
    if (!text) return;
    const id = `${Date.now()}-${messages.length}`;
    setMessages((prev) => [...prev, { id, text, fromMe: true }]);
    setDraft("");

    const reply = AUTO_REPLIES[replyIndex % AUTO_REPLIES.length];
    setReplyIndex((i) => i + 1);
    setTimeout(() => {
      setMessages((prev) => [...prev, { id: `${id}-reply`, text: reply, fromMe: false }]);
    }, 1000);
  };

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-3 pb-2.5 pt-9">
        <button type="button" onClick={onBack} className="flex h-6 w-6 items-center justify-center">
          <ArrowLeft size={15} className="text-teal-dark" />
        </button>
        <span className="text-[12px] font-extrabold text-teal-dark">{name}</span>
      </div>

      <div className="flex-1 space-y-2 overflow-y-auto px-3 py-3">
        {messages.length === 0 && (
          <p className="pt-8 text-center text-[9px] text-black/35">Say hi to {name}!</p>
        )}
        {messages.map((m) => (
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
          onKeyDown={(e) => e.key === "Enter" && send()}
          placeholder="Message"
          className="flex-1 rounded-full bg-black/[0.04] px-3 py-2 text-[9.5px] outline-none placeholder:text-black/35"
        />
        <button
          type="button"
          onClick={send}
          className="flex h-7 w-7 items-center justify-center rounded-full bg-teal-dark text-white"
        >
          <Send size={12} />
        </button>
      </div>
    </div>
  );
}
