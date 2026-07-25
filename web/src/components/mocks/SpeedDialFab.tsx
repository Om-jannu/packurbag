"use client";

import { useEffect, useState } from "react";
import { Plus, X, Briefcase, Wallet, Bot, TriangleAlert, type LucideIcon } from "lucide-react";

type SpeedDialAction = "newTrip" | "currency" | "aiChat" | "sos";

const OPTIONS: { action: SpeedDialAction; icon: LucideIcon; label: string; danger?: boolean }[] = [
  { action: "sos", icon: TriangleAlert, label: "SOS", danger: true },
  { action: "aiChat", icon: Bot, label: "AI Chat" },
  { action: "currency", icon: Wallet, label: "Currency" },
  { action: "newTrip", icon: Briefcase, label: "New Trip" },
];

const TOAST_TEXT: Record<SpeedDialAction, string> = {
  newTrip: "Trip added!",
  currency: "Opening Currency Converter…",
  aiChat: "Opening AI Assistant…",
  sos: "Opening emergency SOS…",
};

export default function SpeedDialFab({ onAction }: { onAction?: (action: SpeedDialAction) => void }) {
  const [open, setOpen] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 1800);
    return () => clearTimeout(t);
  }, [toast]);

  const handleAction = (action: SpeedDialAction) => {
    setOpen(false);
    setToast(TOAST_TEXT[action]);
    onAction?.(action);
  };

  return (
    <div className="absolute bottom-4 right-4 z-20 flex flex-col items-end gap-2.5">
      {toast && (
        <div className="absolute bottom-full right-0 mb-2 whitespace-nowrap rounded-full bg-teal-dark px-3 py-1.5 text-[9px] font-semibold text-white shadow-lg">
          {toast}
        </div>
      )}

      {open &&
        OPTIONS.map(({ action, icon: Icon, label, danger }) => (
          <button
            key={action}
            type="button"
            onClick={() => handleAction(action)}
            className="flex items-center gap-2 transition"
          >
            <span className="rounded-md bg-black/70 px-2 py-1 text-[8px] font-semibold text-white">
              {label}
            </span>
            <span
              className={`flex h-8 w-8 items-center justify-center rounded-full shadow-lg ${
                danger ? "bg-coral text-white" : "bg-white text-teal"
              }`}
            >
              <Icon size={14} />
            </span>
          </button>
        ))}

      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="flex h-11 w-11 items-center justify-center rounded-full bg-teal-dark text-white shadow-lg shadow-teal-dark/30 transition active:scale-90"
      >
        {open ? <X size={18} /> : <Plus size={18} />}
      </button>
    </div>
  );
}
