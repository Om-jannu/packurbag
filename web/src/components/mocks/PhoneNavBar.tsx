"use client";

import { LayoutList, Briefcase, Globe, MapPin, User, type LucideIcon } from "lucide-react";

export type NavTab = "home" | "trips" | "translate" | "nearby" | "profile";

const NAV_ITEMS: { tab: NavTab; icon: LucideIcon; label: string }[] = [
  { tab: "home", icon: LayoutList, label: "Home" },
  { tab: "trips", icon: Briefcase, label: "Trips" },
  { tab: "translate", icon: Globe, label: "Translate" },
  { tab: "nearby", icon: MapPin, label: "Nearby" },
  { tab: "profile", icon: User, label: "Profile" },
];

interface PhoneNavBarProps {
  active: NavTab;
  /** Tabs this instance can actually switch to. Others render inert (real, but non-functional). */
  enabled?: NavTab[];
  onSelect?: (tab: NavTab) => void;
  /** Renders with dark surface colors, e.g. when the Profile mock is previewing dark mode. */
  dark?: boolean;
}

export default function PhoneNavBar({ active, enabled = [], onSelect, dark = false }: PhoneNavBarProps) {
  return (
    <div
      className={`flex shrink-0 justify-around border-t px-1 pb-1 pt-1.5 ${
        dark ? "border-white/10 bg-[#0f2328]" : "border-black/5 bg-white"
      }`}
    >
      {NAV_ITEMS.map(({ tab, icon: Icon, label }) => {
        const isActive = active === tab;
        const isEnabled = enabled.includes(tab);
        const activeColor = dark ? "text-amber" : "text-teal-dark";
        const inactiveColor = dark ? "text-white/35" : "text-black/35";
        return (
          <button
            key={tab}
            type="button"
            disabled={!isEnabled}
            onClick={() => onSelect?.(tab)}
            className={`flex flex-1 flex-col items-center gap-0.5 rounded-lg py-1 transition-colors ${
              isEnabled ? "cursor-pointer" : "cursor-default"
            }`}
          >
            <Icon size={14} className={isActive ? activeColor : inactiveColor} />
            <span className={`text-[6.5px] font-medium ${isActive ? `font-bold ${activeColor}` : inactiveColor}`}>
              {label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
