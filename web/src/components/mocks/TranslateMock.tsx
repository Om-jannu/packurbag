"use client";

import { useState } from "react";
import { ArrowLeftRight, Mic, MicOff, Search, Volume2, X } from "lucide-react";
import PhoneNavBar, { type NavTab } from "./PhoneNavBar";

const LANGUAGES = [
  "English",
  "French",
  "Spanish",
  "Hindi",
  "Japanese",
  "German",
  "Italian",
  "Portuguese",
  "Arabic",
  "Korean",
];

const CANNED_TRANSLATIONS: Record<string, string> = {
  French: "Où est l'hôtel le plus proche ?",
  Spanish: "¿Dónde está el hotel más cercano?",
  Hindi: "सबसे नज़दीकी होटल कहाँ है?",
  Japanese: "一番近いホテルはどこですか？",
  German: "Wo ist das nächste Hotel?",
  English: "Where is the nearest hotel?",
};

interface TranslateMockProps {
  onNavigate?: (tab: NavTab) => void;
}

export default function TranslateMock({ onNavigate }: TranslateMockProps) {
  const [source, setSource] = useState("English");
  const [target, setTarget] = useState("French");
  const [picking, setPicking] = useState<"source" | "target" | null>(null);
  const [input, setInput] = useState("Where is the nearest hotel?");
  const [output, setOutput] = useState(CANNED_TRANSLATIONS.French);
  const [listening, setListening] = useState(false);
  const [speaking, setSpeaking] = useState(false);
  const [search, setSearch] = useState("");

  const swap = () => {
    setSource(target);
    setTarget(source);
    setOutput("");
  };

  const translate = () => {
    setOutput(CANNED_TRANSLATIONS[target] ?? input);
  };

  // Playback is a deliberate tap now — the app used to speak the result
  // automatically the moment it arrived, but the user should stay in
  // control of when audio plays.
  const speak = () => {
    setSpeaking(true);
    setTimeout(() => setSpeaking(false), 1200);
  };

  const filteredLanguages = LANGUAGES.filter((lang) =>
    lang.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="border-b border-black/5 px-4 pb-3 pt-9">
        <span className="text-[13px] font-extrabold text-teal-dark">Language Translation</span>
      </div>

      <div className="relative flex-1 min-h-0">
        <div className="h-full overflow-y-auto px-4 pb-20 pt-3">
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setPicking("source")}
              className="flex-1 rounded-xl bg-teal/10 px-2 py-2 text-center text-[10px] font-bold text-teal-dark"
            >
              {source}
            </button>
            <button
              type="button"
              onClick={swap}
              className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-black/[0.05]"
            >
              <ArrowLeftRight size={12} className="text-teal-dark" />
            </button>
            <button
              type="button"
              onClick={() => setPicking("target")}
              className="flex-1 rounded-xl bg-teal/10 px-2 py-2 text-center text-[10px] font-bold text-teal-dark"
            >
              {target}
            </button>
          </div>

          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            rows={3}
            placeholder="Enter text to translate"
            className="mt-3 w-full rounded-2xl border border-black/10 p-2.5 text-[10px] text-teal-dark outline-none placeholder:text-black/35"
          />

          <button
            type="button"
            onClick={translate}
            className="mt-3 w-full rounded-2xl bg-teal-dark py-2.5 text-[10.5px] font-bold text-white"
          >
            Translate
          </button>

          {output && (
            <div className="mt-3 rounded-2xl bg-black/[0.03] p-2.5">
              <div className="flex items-center justify-between">
                <p className="text-[8px] font-bold uppercase tracking-wide text-black/40">
                  Translated text
                </p>
                <button
                  type="button"
                  onClick={speak}
                  className="relative flex h-6 w-6 items-center justify-center rounded-full text-teal"
                >
                  {speaking && (
                    <span className="absolute inset-0 animate-ping rounded-full bg-teal/20" />
                  )}
                  <Volume2 size={13} />
                </button>
              </div>
              <p className="mt-1 text-[10.5px] font-medium text-teal-dark">{output}</p>
            </div>
          )}
        </div>

        {picking && (
          <div className="absolute inset-0 z-30 flex flex-col bg-white">
            <div className="flex items-center justify-between border-b border-black/5 px-3 py-2.5">
              <span className="text-[10px] font-bold text-teal-dark">Choose a language</span>
              <button
                type="button"
                onClick={() => {
                  setPicking(null);
                  setSearch("");
                }}
              >
                <X size={14} className="text-black/40" />
              </button>
            </div>
            <div className="flex items-center gap-2 border-b border-black/5 px-3 py-2.5">
              <Search size={13} className="text-black/40" />
              <input
                autoFocus
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search language"
                className="w-full bg-transparent text-[10.5px] text-teal-dark outline-none placeholder:text-black/35"
              />
            </div>
            <div className="flex-1 overflow-y-auto">
              {filteredLanguages.map((lang) => (
                <button
                  key={lang}
                  type="button"
                  onClick={() => {
                    if (picking === "source") setSource(lang);
                    else setTarget(lang);
                    setPicking(null);
                    setSearch("");
                    setOutput("");
                  }}
                  className="flex w-full items-center px-4 py-2.5 text-left text-[10.5px] font-medium text-teal-dark hover:bg-black/[0.03]"
                >
                  {lang}
                </button>
              ))}
            </div>
          </div>
        )}

        <button
          type="button"
          onClick={() => setListening((l) => !l)}
          className="absolute bottom-4 right-4 z-20 flex h-11 w-11 items-center justify-center rounded-full bg-teal-dark text-white shadow-lg"
        >
          {listening && (
            <span className="absolute inset-0 animate-ping rounded-full bg-teal-dark/60" />
          )}
          {listening ? <MicOff size={16} /> : <Mic size={16} />}
        </button>
      </div>

      <PhoneNavBar active="translate" enabled={onNavigate ? ["home", "trips", "nearby"] : []} onSelect={onNavigate} />
    </div>
  );
}
