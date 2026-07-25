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
}

export default function PhoneNavBar({ active, enabled = [], onSelect }: PhoneNavBarProps) {
  return (
    <div className="flex shrink-0 justify-around border-t border-black/5 bg-white px-1 pb-1 pt-1.5">
      {NAV_ITEMS.map(({ tab, icon: Icon, label }) => {
        const isActive = active === tab;
        const isEnabled = enabled.includes(tab);
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
            <Icon size={14} className={isActive ? "text-teal-dark" : "text-black/35"} />
            <span
              className={`text-[6.5px] ${
                isActive ? "font-bold text-teal-dark" : "font-medium text-black/35"
              }`}
            >
              {label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
