"use client";

import { useState } from "react";
import Image from "next/image";
import {
  MapPin,
  CloudSun,
  Briefcase,
  Receipt,
  CalendarClock,
  Luggage,
  Plane,
} from "lucide-react";
import PhoneNavBar, { type NavTab } from "./PhoneNavBar";
import SpeedDialFab from "./SpeedDialFab";

const WEEKDAYS = ["M", "T", "W", "T", "F", "S", "S"];
// A 30-day month starting on a Wednesday, padded to full weeks — same visual
// rhythm as the real TableCalendar month view.
const LEADING_BLANKS = 2;
const DAYS_IN_MONTH = 30;
const TRAILING_BLANKS = 3;
const HIGHLIGHTED_DAYS = [12, 13, 14, 15];

const upcomingItinerary = [
  { text: "Visit temple", trip: "Bali Getaway", date: "Wed, 2 Aug", color: "text-coral" },
  { text: "Book train tickets", trip: "Kerala Backwaters", date: "Fri, 4 Aug", color: "text-amber" },
];

// Recent photo-journal shots pulled across every trip — same gradient
// placeholder look used for photo tiles in the Documents grid.
const recentPhotos = [
  "bg-gradient-to-br from-coral to-black/20",
  "bg-gradient-to-br from-amber to-black/20",
  "bg-gradient-to-br from-teal to-black/20",
  "bg-gradient-to-br from-coral to-black/20",
  "bg-gradient-to-br from-amber to-black/20",
];

interface HomeMockProps {
  onNavigate?: (tab: NavTab) => void;
}

export default function HomeMock({ onNavigate }: HomeMockProps) {
  const [selectedDate, setSelectedDate] = useState(13);
  const tripCount = 4;

  const dayHasTrip = HIGHLIGHTED_DAYS.includes(selectedDate);

  return (
    <div className="flex h-full flex-col bg-white text-[11px]">
      {/* app bar */}
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <Image src="/packurbag-logo.png" alt="" width={20} height={20} className="rounded-full" />
        <span className="text-[13px] font-extrabold text-teal-dark">Packurbag</span>
      </div>

      <div className="relative flex-1 min-h-0">
        <div className="h-full space-y-3 overflow-y-auto px-3 pb-20 pt-3">
          {/* countdown card */}
          <div className="rounded-2xl bg-coral/15 p-3">
            <div className="flex items-center justify-between">
              <p className="text-[9px] font-semibold uppercase tracking-wide text-coral">Next up</p>
              <button
                type="button"
                className="flex items-center gap-1 rounded-full bg-coral/20 px-2 py-1 text-[8px] font-bold text-coral"
              >
                <Receipt size={9} /> Add budget
              </button>
            </div>
            <p className="mt-1 text-[13px] font-extrabold text-teal-dark">Bali Getaway</p>
            <div className="mt-1 flex items-center gap-1 text-[10px] text-teal-dark/70">
              <MapPin size={11} className="text-coral" />
              Bali, Indonesia
            </div>
            <p className="mt-2 text-[12px] font-bold text-coral">In 12 days</p>
          </div>

          {/* weather */}
          <div className="flex items-center gap-2 rounded-2xl bg-black/[0.03] p-2.5">
            <CloudSun size={18} className="text-amber" />
            <div>
              <p className="text-[11px] font-bold text-teal-dark">29°C in Denpasar</p>
              <p className="text-[9px] text-black/50">Sunny</p>
            </div>
          </div>

          {/* currency snippet */}
          <div className="flex items-center gap-2 rounded-2xl bg-black/[0.03] p-2.5">
            <span className="text-[13px]">💱</span>
            <p className="text-[10px] font-semibold text-teal-dark">1 INR ≈ 1.47 IDR</p>
          </div>

          {/* quick stats */}
          <div className="grid grid-cols-3 gap-2">
            {[
              { icon: Briefcase, value: `${tripCount}`, label: "Trips" },
              { icon: Plane, value: "1", label: "Ongoing" },
              { icon: Luggage, value: "8/12", label: "Packed" },
            ].map(({ icon: Icon, value, label }) => (
              <div key={label} className="rounded-xl bg-black/[0.03] py-2.5 text-center">
                <Icon size={13} className="mx-auto text-teal" />
                <p className="mt-1 text-[12px] font-extrabold text-teal-dark">{value}</p>
                <p className="text-[7.5px] text-black/50">{label}</p>
              </div>
            ))}
          </div>

          {/* calendar */}
          <div>
            <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Trip calendar</p>
            <div className="rounded-2xl bg-black/[0.03] p-2.5">
              <div className="grid grid-cols-7 gap-y-1.5 text-center">
                {WEEKDAYS.map((d, i) => (
                  <span key={`${d}-${i}`} className="text-[7px] font-semibold text-black/40">
                    {d}
                  </span>
                ))}
                {Array.from({ length: LEADING_BLANKS }).map((_, i) => (
                  <span key={`lead-${i}`} />
                ))}
                {Array.from({ length: DAYS_IN_MONTH }, (_, i) => i + 1).map((d) => (
                  <button
                    key={d}
                    type="button"
                    onClick={() => setSelectedDate(d)}
                    className={`mx-auto flex h-4 w-4 items-center justify-center rounded-full text-[7px] transition-colors ${
                      selectedDate === d
                        ? "bg-teal-dark font-bold text-white"
                        : HIGHLIGHTED_DAYS.includes(d)
                          ? "bg-coral font-bold text-white"
                          : "text-black/60 hover:bg-black/10"
                    }`}
                  >
                    {d}
                  </button>
                ))}
                {Array.from({ length: TRAILING_BLANKS }).map((_, i) => (
                  <span key={`trail-${i}`} />
                ))}
              </div>
              {dayHasTrip && (
                <div className="mt-2 flex items-center gap-2 rounded-xl bg-white px-2 py-1.5">
                  <span className="flex h-5 w-5 items-center justify-center rounded-full bg-coral text-[7px] font-bold text-white">
                    B
                  </span>
                  <div>
                    <p className="text-[8.5px] font-bold text-teal-dark">Bali Getaway</p>
                    <p className="text-[7px] text-black/40">Bali, Indonesia</p>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* coming up this week */}
          <div>
            <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Coming up this week</p>
            <div className="space-y-1 rounded-2xl bg-black/[0.03] p-1.5">
              {upcomingItinerary.map((entry) => (
                <div key={entry.text} className="flex items-center gap-2 rounded-xl px-1.5 py-1.5">
                  <CalendarClock size={13} className={entry.color} />
                  <div className="flex-1">
                    <p className="text-[9px] font-semibold text-teal-dark">{entry.text}</p>
                    <p className="text-[7.5px] text-black/40">
                      {entry.trip} · {entry.date}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* recent photos */}
          <div>
            <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Recent photos</p>
            <div className="flex gap-1.5 overflow-x-hidden rounded-2xl bg-black/[0.03] p-2">
              {recentPhotos.map((gradient, i) => (
                <span key={i} className={`h-9 w-9 shrink-0 rounded-lg ${gradient}`} />
              ))}
            </div>
          </div>
        </div>

        <SpeedDialFab />
      </div>

      <PhoneNavBar active="home" enabled={onNavigate ? ["trips", "nearby"] : []} onSelect={onNavigate} />
    </div>
  );
}
