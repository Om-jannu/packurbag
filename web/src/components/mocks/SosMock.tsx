"use client";

import { useEffect, useRef, useState } from "react";
import {
  TriangleAlert,
  X,
  UserPlus,
  Megaphone,
  Lightbulb,
  Phone,
  MapPin,
  Star,
  Trash2,
} from "lucide-react";

interface Contact {
  id: string;
  name: string;
  phone: string;
}

const DURATION_S = 10;

const CONTACTS: Contact[] = [
  { id: "c1", name: "Mom", phone: "+91 90000 00000" },
  { id: "c2", name: "Dad", phone: "+91 90000 11111" },
];

/**
 * Display-only mock — the countdown and slide-to-cancel reproduce the real
 * screen's two states, but contacts, buzzer, and flashlight are previews
 * only; nothing here is added, edited, or persisted.
 */
export default function SosMock() {
  const [cancelled, setCancelled] = useState(false);
  const [progress, setProgress] = useState(0);
  const [dragX, setDragX] = useState(0);
  const [dragging, setDragging] = useState(false);
  const trackRef = useRef<HTMLDivElement>(null);

  const [buzzer, setBuzzer] = useState(false);
  const [flash, setFlash] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (cancelled) return;
    const id = setInterval(() => {
      setProgress((p) => {
        const next = p + 1 / DURATION_S;
        if (next >= 1) {
          setCancelled(true);
          return 1;
        }
        return next;
      });
    }, 1000);
    return () => clearInterval(id);
  }, [cancelled]);

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 1500);
    return () => clearTimeout(t);
  }, [toast]);

  const trackWidth = 200;
  const thumbSize = 40;
  const maxDrag = trackWidth - thumbSize;

  const onPointerMove = (e: React.PointerEvent) => {
    if (!dragging || !trackRef.current) return;
    const rect = trackRef.current.getBoundingClientRect();
    const x = Math.max(0, Math.min(e.clientX - rect.left - thumbSize / 2, maxDrag));
    setDragX(x);
  };

  const onPointerUp = () => {
    if (!dragging) return;
    setDragging(false);
    if (dragX > maxDrag * 0.7) {
      setCancelled(true);
    }
    setDragX(0);
  };

  const remaining = Math.ceil(DURATION_S - progress * DURATION_S);
  const circumference = 2 * Math.PI * 42;

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <TriangleAlert size={15} className="text-red-500" />
        <span className="text-[12px] font-extrabold text-teal-dark">Emergency SOS</span>
      </div>

      <div className="flex-1 overflow-y-auto px-4 pt-6">
        {!cancelled ? (
          <div className="flex flex-col items-center">
            <div className="relative flex h-32 w-32 items-center justify-center">
              <svg viewBox="0 0 96 96" className="h-32 w-32 -rotate-90">
                <circle cx="48" cy="48" r="42" fill="none" stroke="#fee2e2" strokeWidth="8" />
                <circle
                  cx="48"
                  cy="48"
                  r="42"
                  fill="none"
                  stroke="#ef4444"
                  strokeWidth="8"
                  strokeLinecap="round"
                  strokeDasharray={circumference}
                  strokeDashoffset={circumference * (1 - progress)}
                  style={{ transition: "stroke-dashoffset 1s linear" }}
                />
              </svg>
              <span className="absolute text-[28px] font-extrabold text-teal-dark">{remaining}</span>
            </div>

            <p className="mt-4 text-center text-[9px] text-black/50">
              Calling your emergency contact in {remaining}s
            </p>

            <div
              ref={trackRef}
              onPointerMove={onPointerMove}
              onPointerUp={onPointerUp}
              onPointerLeave={onPointerUp}
              className="relative mt-6 flex items-center rounded-2xl bg-red-100"
              style={{ width: trackWidth, height: 48 }}
            >
              <span className="w-full text-center text-[10px] font-bold italic text-red-500">
                Slide to Cancel
              </span>
              <div
                onPointerDown={(e) => {
                  e.currentTarget.setPointerCapture(e.pointerId);
                  setDragging(true);
                }}
                className="absolute left-1 top-1 flex h-10 w-10 cursor-grab items-center justify-center rounded-xl bg-red-500 text-white active:cursor-grabbing"
                style={{ transform: `translateX(${dragX}px)`, transition: dragging ? "none" : "transform 0.2s" }}
              >
                <X size={16} />
              </div>
            </div>
          </div>
        ) : (
          <div className="space-y-1.5 pb-2">
            {CONTACTS.map((c, i) => (
              <div key={c.id} className="flex items-center gap-2 rounded-2xl bg-black/[0.03] px-2.5 py-2">
                <div className="flex-1">
                  <div className="flex items-center gap-1">
                    <span className="font-bold text-teal-dark">{c.name}</span>
                    {i === 0 && <Star size={11} className="fill-amber text-amber" />}
                  </div>
                  <span className="text-[8px] text-black/40">{c.phone}</span>
                </div>
                <button type="button" onClick={() => setToast("Location sent")} className="text-black/30">
                  <MapPin size={13} />
                </button>
                <button type="button" onClick={() => setToast("Calling…")} className="text-black/30">
                  <Phone size={13} />
                </button>
                <button type="button" className="text-black/30">
                  <Trash2 size={13} />
                </button>
              </div>
            ))}

            {toast && (
              <p className="rounded-xl bg-teal/10 px-2.5 py-1.5 text-center text-[9px] font-semibold text-teal-dark">
                {toast}
              </p>
            )}
          </div>
        )}
      </div>

      <div className="flex justify-evenly border-t border-black/5 py-2.5">
        <button
          type="button"
          onClick={() => setToast("Opening Add Contact…")}
          className="flex flex-col items-center gap-1 px-2 text-black/50"
        >
          <UserPlus size={16} />
          <span className="text-[7.5px]">Add contact</span>
        </button>
        <button
          type="button"
          onClick={() => setBuzzer((b) => !b)}
          className={`flex flex-col items-center gap-1 px-2 ${buzzer ? "text-red-500" : "text-black/50"}`}
        >
          <Megaphone size={16} />
          <span className="text-[7.5px]">Buzzer</span>
        </button>
        <button
          type="button"
          onClick={() => setFlash((f) => !f)}
          className={`flex flex-col items-center gap-1 px-2 ${flash ? "text-red-500" : "text-black/50"}`}
        >
          <Lightbulb size={16} />
          <span className="text-[7.5px]">Flashlight</span>
        </button>
      </div>
    </div>
  );
}
