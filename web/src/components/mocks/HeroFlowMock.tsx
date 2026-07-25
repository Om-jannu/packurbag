"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import {
  MapPin,
  Briefcase,
  ArrowLeft,
  ChevronRight,
  Plus,
} from "lucide-react";

const STEPS = [
  { scene: "home", top: 61, left: 50 },
  { scene: "home", top: 89, left: 23 },
  { scene: "trips", top: 24, left: 50 },
  { scene: "detail", tab: 0, top: 23, left: 15 },
  { scene: "detail", tab: 1, top: 21, left: 32 },
  { scene: "detail", tab: 2, top: 50, left: 50 },
  { scene: "nearby", top: 19, left: 85 },
  { scene: "nearby", top: 33, left: 50 },
] as const;

const STEP_MS = 2600;

export default function HeroFlowMock() {
  const [step, setStep] = useState(0);

  useEffect(() => {
    const id = setInterval(() => setStep((s) => (s + 1) % STEPS.length), STEP_MS);
    return () => clearInterval(id);
  }, []);

  const current = STEPS[step];
  const scene = current.scene;
  const tab = "tab" in current ? current.tab : -1;

  return (
    <div className="pointer-events-none relative h-full select-none bg-white text-[11px]">
      <Scene visible={scene === "home"}>
        <HomeScene dayActive={step === 0} tripsActive={step === 1} />
      </Scene>
      <Scene visible={scene === "trips"}>
        <TripsScene cardActive={step === 2} />
      </Scene>
      <Scene visible={scene === "detail"}>
        <DetailScene tab={tab} />
      </Scene>
      <Scene visible={scene === "nearby"}>
        <NearbyScene toggleOn={step >= 6} rowActive={step === 7} />
      </Scene>

      {/* ghost cursor */}
      <div
        className="absolute z-30 -ml-3.5 -mt-3.5 h-7 w-7 transition-[top,left] duration-700 ease-in-out"
        style={{ top: `${current.top}%`, left: `${current.left}%` }}
      >
        <span
          key={step}
          className="absolute inset-0 rounded-full bg-teal-dark/70"
          style={{ animation: "cursorPulse 1.4s ease-out" }}
        />
        <span className="absolute inset-[7px] rounded-full bg-white shadow" />
      </div>
    </div>
  );
}

function Scene({ visible, children }: { visible: boolean; children: React.ReactNode }) {
  return (
    <div
      className={`absolute inset-0 flex flex-col bg-white transition-opacity duration-500 ${
        visible ? "opacity-100" : "opacity-0"
      }`}
    >
      {children}
    </div>
  );
}

function HomeScene({ dayActive, tripsActive }: { dayActive: boolean; tripsActive: boolean }) {
  const days = Array.from({ length: 21 }, (_, i) => i + 1);
  return (
    <>
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <Image src="/packurbag-logo.png" alt="" width={20} height={20} className="rounded-full" />
        <span className="text-[13px] font-extrabold text-teal-dark">Packurbag</span>
      </div>
      <div className="flex-1 space-y-3 px-3 pt-3">
        <div className="rounded-2xl bg-coral/15 p-3">
          <p className="text-[9px] font-semibold uppercase tracking-wide text-coral">Next up</p>
          <p className="mt-1 text-[13px] font-extrabold text-teal-dark">Bali Getaway</p>
          <div className="mt-1 flex items-center gap-1 text-[10px] text-teal-dark/70">
            <MapPin size={11} className="text-coral" />
            Bali, Indonesia
          </div>
          <p className="mt-2 text-[12px] font-bold text-coral">In 12 days</p>
        </div>

        <div className="rounded-2xl bg-black/[0.03] p-2.5">
          <p className="mb-1.5 text-[9px] font-semibold text-black/60">Trip calendar</p>
          <div className="grid grid-cols-7 gap-y-1.5 text-center">
            {["M", "T", "W", "T", "F", "S", "S"].map((d, i) => (
              <span key={`${d}-${i}`} className="text-[7px] font-semibold text-black/40">
                {d}
              </span>
            ))}
            {days.map((d) => (
              <span
                key={d}
                className={`mx-auto flex h-4 w-4 items-center justify-center rounded-full text-[7px] transition-colors duration-500 ${
                  d === 13 && dayActive
                    ? "bg-teal-dark font-bold text-white"
                    : [12, 13, 14, 15].includes(d)
                      ? "bg-coral font-bold text-white"
                      : "text-black/60"
                }`}
              >
                {d}
              </span>
            ))}
          </div>
        </div>

        <div>
          <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Quick actions</p>
          <div className="flex justify-around rounded-2xl bg-black/[0.03] py-2">
            {["Trips", "Translate", "Assistant", "SOS"].map((label) => (
              <div key={label} className="flex flex-col items-center gap-1">
                <div
                  className={`flex h-7 w-7 items-center justify-center rounded-full transition-colors duration-500 ${
                    label === "Trips" && tripsActive ? "bg-teal text-white" : "bg-teal/10 text-teal"
                  }`}
                >
                  <Briefcase size={14} />
                </div>
                <span className="text-[7px] text-black/50">{label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

function TripsScene({ cardActive }: { cardActive: boolean }) {
  const trips = [
    { title: "Bali Getaway", place: "Bali, Indonesia", dates: "1 Sep – 10 Sep", status: "In 12 days", color: "bg-coral", badge: "bg-coral/10 text-coral" },
    { title: "Kerala Backwaters", place: "Kerala, India", dates: "1 Oct – 5 Oct", status: "In 43 days", color: "bg-amber", badge: "bg-amber/10 text-amber" },
    { title: "Tokyo Adventure", place: "Tokyo, Japan", dates: "12 Dec – 20 Dec", status: "In 106 days", color: "bg-teal", badge: "bg-teal/10 text-teal" },
  ];
  return (
    <>
      <div className="flex items-center justify-between border-b border-black/5 px-4 pb-3 pt-9">
        <span className="text-[13px] font-extrabold text-teal-dark">My Trips</span>
        <Plus size={13} className="text-teal" />
      </div>
      <div className="flex-1 space-y-2.5 px-3 pt-3">
        {trips.map((trip, i) => (
          <div
            key={trip.title}
            className={`flex items-center gap-2.5 rounded-2xl bg-black/[0.03] p-2.5 transition-all duration-500 ${
              i === 0 && cardActive ? "ring-1 ring-teal/40" : ""
            }`}
          >
            <div className={`h-10 w-1.5 shrink-0 rounded-full ${trip.color}`} />
            <div className="flex-1">
              <p className="text-[11px] font-bold text-teal-dark">{trip.title}</p>
              <div className="mt-0.5 flex items-center gap-1 text-[9px] text-black/50">
                <MapPin size={9} />
                {trip.place}
              </div>
              <p className="mt-0.5 text-[8px] text-black/40">{trip.dates}</p>
            </div>
            <span className={`rounded-lg px-2 py-1 text-[8px] font-bold ${trip.badge}`}>
              {trip.status}
            </span>
          </div>
        ))}
      </div>
    </>
  );
}

const DETAIL_TABS = ["Itinerary", "Packing", "Budget", "Documents"];

function DetailScene({ tab }: { tab: number }) {
  return (
    <>
      <div className="flex items-center gap-2 bg-coral/15 px-3 pb-2.5 pt-9">
        <ArrowLeft size={15} className="text-teal-dark" />
        <span className="text-[12px] font-extrabold text-teal-dark">Bali Getaway</span>
      </div>
      <div className="flex border-b border-black/5">
        {DETAIL_TABS.map((t, i) => (
          <div
            key={t}
            className={`flex-1 border-b-2 py-2 text-center text-[8.5px] font-bold transition-colors duration-500 ${
              tab === i ? "border-coral text-coral" : "border-transparent text-black/40"
            }`}
          >
            {t}
          </div>
        ))}
      </div>

      {tab === 0 && (
        <div className="px-3 pt-2.5">
          {[
            { text: "Visit temple", checked: true },
            { text: "Surf lesson", checked: false },
            { text: "Rice terrace hike", checked: false },
          ].map((item) => (
            <div key={item.text} className="flex items-center gap-2 py-2">
              <span
                className={`flex h-4 w-4 shrink-0 items-center justify-center rounded-full border-2 transition-colors duration-500 ${
                  item.checked ? "border-transparent bg-coral" : "border-black/25"
                }`}
              >
                {item.checked && <span className="h-1.5 w-1.5 rounded-full bg-white" />}
              </span>
              <span className={item.checked ? "text-black/40 line-through" : "font-semibold text-teal-dark"}>
                {item.text}
              </span>
            </div>
          ))}
        </div>
      )}

      {tab === 1 && (
        <div className="px-3 pt-2.5">
          <p className="text-[9px] font-bold text-black/50">Quick-apply a template</p>
          <div className="mt-1.5 flex gap-1.5">
            <span className="rounded-full bg-coral/15 px-2.5 py-1 text-[8px] font-semibold text-coral">
              Beach
            </span>
            <span className="rounded-full bg-black/[0.04] px-2.5 py-1 text-[8px] font-semibold text-teal-dark">
              Hiking
            </span>
          </div>
          <div className="mt-2.5 h-1.5 overflow-hidden rounded-full bg-black/10">
            <div className="h-full rounded-full bg-coral transition-[width] duration-[1400ms]" style={{ width: "100%" }} />
          </div>
          <div className="mt-2">
            {["Swimsuit", "Sunscreen", "Sunglasses"].map((item, i) => (
              <div
                key={item}
                className="flex items-center gap-2 py-1.5 transition-opacity duration-500"
                style={{ transitionDelay: `${i * 180}ms` }}
              >
                <span className="flex h-4 w-4 items-center justify-center rounded border-2 border-transparent bg-coral">
                  <span className="h-1.5 w-1.5 rounded-full bg-white" />
                </span>
                <span className="text-black/40 line-through">{item}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {tab === 2 && (
        <div className="px-3 pt-2.5">
          <div className="rounded-2xl bg-coral/15 p-3">
            <p className="text-[8px] font-bold text-black/50">Spent so far</p>
            <p className="mt-0.5 text-[14px] font-extrabold text-teal-dark">31000 INR</p>
            <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-black/10">
              <div className="h-full rounded-full bg-coral transition-[width] duration-[1600ms]" style={{ width: "62%" }} />
            </div>
            <p className="mt-1 text-[8px] text-black/50">19000 INR remaining of 50000</p>
          </div>
        </div>
      )}
    </>
  );
}

function NearbyScene({ toggleOn, rowActive }: { toggleOn: boolean; rowActive: boolean }) {
  const travelers = [
    { name: "Aisha", distance: "0.6 km away", color: "bg-coral" },
    { name: "Marco", distance: "1.2 km away", color: "bg-amber" },
    { name: "Priya", distance: "2.4 km away", color: "bg-teal" },
  ];
  return (
    <>
      <div className="border-b border-black/5 px-4 pb-3 pt-9">
        <span className="text-[13px] font-extrabold text-teal-dark">Nearby Travelers</span>
      </div>
      <div className="flex items-center justify-between border-b border-black/5 px-4 py-3">
        <div>
          <p className="text-[10px] font-semibold text-teal-dark">Share my location</p>
          <p className="text-[8px] text-black/40">Visible to nearby travelers</p>
        </div>
        <div
          className={`flex h-4 w-8 items-center rounded-full p-0.5 transition-colors duration-500 ${
            toggleOn ? "bg-teal" : "bg-black/15"
          }`}
        >
          <div
            className={`h-3 w-3 rounded-full bg-white transition-transform duration-500 ${
              toggleOn ? "translate-x-4" : "translate-x-0"
            }`}
          />
        </div>
      </div>
      <div
        className={`flex-1 space-y-1 px-2 pt-2 transition-opacity duration-500 ${
          toggleOn ? "opacity-100" : "opacity-0"
        }`}
      >
        {travelers.map((t, i) => (
          <div
            key={t.name}
            className={`flex items-center gap-2.5 rounded-xl px-2 py-2 transition-colors duration-500 ${
              i === 0 && rowActive ? "bg-black/[0.04]" : ""
            }`}
          >
            <div
              className={`flex h-8 w-8 items-center justify-center rounded-full ${t.color} text-[10px] font-bold text-white`}
            >
              {t.name[0]}
            </div>
            <div className="flex-1">
              <p className="text-[10px] font-bold text-teal-dark">{t.name}</p>
              <p className="text-[8px] text-black/40">{t.distance}</p>
            </div>
            <ChevronRight size={13} className="text-black/30" />
          </div>
        ))}
      </div>
    </>
  );
}
