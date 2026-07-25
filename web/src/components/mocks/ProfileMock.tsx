"use client";

import { useState } from "react";
import { UserCircle, Mail, Mic, LogOut } from "lucide-react";
import PhoneNavBar, { type NavTab } from "./PhoneNavBar";
import SpeedDialFab from "./SpeedDialFab";

type ThemeChoice = "system" | "light" | "dark";

interface ProfileMockProps {
  onNavigate?: (tab: NavTab) => void;
}

export default function ProfileMock({ onNavigate }: ProfileMockProps) {
  const [theme, setTheme] = useState<ThemeChoice>("system");
  const [micGranted, setMicGranted] = useState(false);

  // "system" previews as light — there's no ambient OS preference to read in a static mock.
  const isDark = theme === "dark";

  const bg = isDark ? "bg-[#0f2328]" : "bg-white";
  const card = isDark ? "bg-white/[0.06]" : "bg-black/[0.03]";
  const primaryText = isDark ? "text-white" : "text-teal-dark";
  const sectionLabel = isDark ? "text-white/40" : "text-black/40";
  const mutedText = isDark ? "text-white/40" : "text-black/40";
  const border = isDark ? "border-white/10" : "border-black/5";
  const accent = isDark ? "text-amber" : "text-teal";
  const iconMuted = isDark ? "text-white/40" : "text-black/40";

  return (
    <div className={`flex h-full flex-col ${bg} text-[11px] transition-colors`}>
      <div className={`border-b px-4 pb-3 pt-9 ${border}`}>
        <span className={`text-[13px] font-extrabold ${primaryText}`}>Profile</span>
      </div>

      <div className="relative flex-1 min-h-0">
        <div className="h-full overflow-y-auto px-4 pb-20 pt-4">
          <div className={`mx-auto flex h-16 w-16 items-center justify-center rounded-full ${isDark ? "bg-amber/10" : "bg-teal/10"}`}>
            <UserCircle size={34} className={accent} />
          </div>

          <p className={`mt-4 text-[9px] font-bold uppercase tracking-wide ${sectionLabel}`}>
            User Details
          </p>
          <div className="mt-1.5 space-y-1.5">
            <div className={`flex items-center gap-2.5 rounded-2xl px-3 py-2.5 ${card}`}>
              <UserCircle size={15} className={iconMuted} />
              <div>
                <p className={`text-[8px] ${mutedText}`}>Username</p>
                <p className={`text-[10px] font-bold ${primaryText}`}>travel_jane</p>
              </div>
            </div>
            <div className={`flex items-center gap-2.5 rounded-2xl px-3 py-2.5 ${card}`}>
              <Mail size={15} className={iconMuted} />
              <div>
                <p className={`text-[8px] ${mutedText}`}>Email</p>
                <p className={`text-[10px] font-bold ${primaryText}`}>jane@packurbag.app</p>
              </div>
            </div>
          </div>

          <p className={`mt-4 text-[9px] font-bold uppercase tracking-wide ${sectionLabel}`}>
            Appearance
          </p>
          <div className={`mt-1.5 rounded-2xl p-1 ${card}`}>
            {(["system", "light", "dark"] as ThemeChoice[]).map((mode) => (
              <button
                key={mode}
                type="button"
                onClick={() => setTheme(mode)}
                className="flex w-full items-center gap-2.5 rounded-xl px-2 py-2 text-left"
              >
                <span
                  className={`flex h-3.5 w-3.5 items-center justify-center rounded-full border-2 ${
                    theme === mode ? (isDark ? "border-amber" : "border-teal") : isDark ? "border-white/25" : "border-black/25"
                  }`}
                >
                  {theme === mode && <span className={`h-1.5 w-1.5 rounded-full ${isDark ? "bg-amber" : "bg-teal"}`} />}
                </span>
                <span className={`text-[10px] font-medium capitalize ${primaryText}`}>
                  {mode === "system" ? "Match system" : mode}
                </span>
              </button>
            ))}
          </div>

          <p className={`mt-4 text-[9px] font-bold uppercase tracking-wide ${sectionLabel}`}>
            Permissions
          </p>
          <div className={`mt-1.5 flex items-center justify-between rounded-2xl px-3 py-2.5 ${card}`}>
            <div className="flex items-center gap-2">
              <Mic size={14} className={iconMuted} />
              <span className={`text-[10px] font-medium ${primaryText}`}>Microphone</span>
            </div>
            <button
              type="button"
              onClick={() => setMicGranted(true)}
              disabled={micGranted}
              className={`rounded-full px-2.5 py-1 text-[8px] font-bold ${accent} ${
                micGranted ? "" : isDark ? "bg-amber/10" : "bg-teal/10"
              }`}
            >
              {micGranted ? "Granted" : "Request"}
            </button>
          </div>

          <button
            type="button"
            className="mt-6 flex w-full items-center justify-center gap-2 rounded-2xl bg-coral/15 py-2.5 text-[10.5px] font-bold text-coral"
          >
            <LogOut size={13} />
            Logout
          </button>
        </div>

        <SpeedDialFab />
      </div>

      <PhoneNavBar
        active="profile"
        enabled={onNavigate ? ["home", "trips", "nearby"] : []}
        onSelect={onNavigate}
        dark={isDark}
      />
    </div>
  );
}
