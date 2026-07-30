"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import {
  MapPin,
  ArrowLeft,
  Pencil,
  ChevronRight,
  Plus,
  Lock,
  Download,
  Share2,
  Receipt,
  CloudSun,
  Briefcase,
  Plane,
  Luggage,
  Image as ImageIcon,
  CalendarClock,
} from "lucide-react";

// Each step is one simulated tap: where the cursor lands, and which scene is
// showing while it travels there. The resulting highlight/navigation is
// derived from (step, phase) below, not stored here — see STEP_EFFECTS.
const STEPS = [
  { scene: "home", top: 18, left: 80 }, // 0: tap "Add budget" on the countdown card
  { scene: "home", top: 73, left: 79 }, // 1: tap a calendar date
  { scene: "home", top: 90, left: 17 }, // 2: tap a recent-photo tile
  { scene: "trips", top: 27, left: 50 }, // 3: tap the first trip card
  { scene: "detail", tab: 0, top: 23, left: 15 }, // 4: Itinerary
  { scene: "detail", tab: 1, top: 21, left: 32 }, // 5: Packing
  { scene: "detail", tab: 2, top: 42, left: 50 }, // 6: Budget — export/share row
  { scene: "detail", tab: 3, top: 35, left: 27 }, // 7: Documents grid tile
  { scene: "nearby", top: 16, left: 87 }, // 8: toggle "Share my location"
  { scene: "nearby", top: 26, left: 50 }, // 9: tap a traveler row
] as const;

// A tap has three felt beats: the cursor glides to the target (no reaction
// yet), it lands and "presses" (the ripple fires, the UI responds), then a
// beat to actually read the result before moving on — rather than one flat
// dwell where the destination appears the instant the cursor starts moving.
const MOVE_MS = 650;
const CLICK_MS = 1400; // matches the cursorPulse keyframe's own duration
const READ_MS = 900;

export default function HeroFlowMock() {
  const [step, setStep] = useState(0);
  // Lags one beat behind `step` — "moving" is simply clickedStep !== step
  // (true the instant a new step begins, until the click timer catches up),
  // so resetting to "moving" on each step change falls out for free instead
  // of needing a synchronous setState at the top of the effect.
  const [clickedStep, setClickedStep] = useState(-1);

  useEffect(() => {
    const toClick = setTimeout(() => setClickedStep(step), MOVE_MS);
    const toNext = setTimeout(
      () => setStep((s) => (s + 1) % STEPS.length),
      MOVE_MS + CLICK_MS + READ_MS
    );
    return () => {
      clearTimeout(toClick);
      clearTimeout(toNext);
    };
  }, [step]);

  const current = STEPS[step];
  const scene = current.scene;
  const tab = "tab" in current ? current.tab : -1;
  const clicked = clickedStep === step;

  return (
    <div className="pointer-events-none relative h-full select-none bg-white text-[11px]">
      <Scene visible={scene === "home"}>
        <HomeScene
          budgetActive={step === 0 && clicked}
          dayActive={step === 1 && clicked}
          photoActive={step === 2 && clicked}
        />
      </Scene>
      <Scene visible={scene === "trips"}>
        <TripsScene cardActive={step === 3 && clicked} />
      </Scene>
      <Scene visible={scene === "detail"}>
        <DetailScene tab={tab} />
      </Scene>
      <Scene visible={scene === "nearby"}>
        <NearbyScene
          toggleOn={step > 8 || (step === 8 && clicked)}
          rowActive={step === 9 && clicked}
        />
      </Scene>

      {/* ghost cursor */}
      <div
        className="absolute z-30 -ml-3.5 -mt-3.5 h-7 w-7 transition-[top,left] ease-in-out"
        style={{ top: `${current.top}%`, left: `${current.left}%`, transitionDuration: `${MOVE_MS}ms` }}
      >
        {clicked && (
          <span
            key={step}
            className="absolute inset-0 rounded-full bg-teal-dark/70"
            style={{ animation: `cursorPulse ${CLICK_MS}ms ease-out` }}
          />
        )}
        <span
          className={`absolute inset-[7px] rounded-full bg-white shadow transition-transform duration-150 ${
            clicked ? "scale-90" : "scale-100"
          }`}
        />
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

function HomeScene({
  budgetActive,
  dayActive,
  photoActive,
}: {
  budgetActive: boolean;
  dayActive: boolean;
  photoActive: boolean;
}) {
  const days = Array.from({ length: 21 }, (_, i) => i + 1);
  return (
    <>
      <div className="flex items-center gap-2 border-b border-black/5 px-4 pb-3 pt-9">
        <Image src="/packurbag-logo.png" alt="" width={20} height={20} className="rounded-full" />
        <span className="text-[13px] font-extrabold text-teal-dark">Packurbag</span>
      </div>
      <div className="flex-1 space-y-3 px-3 pt-3">
        <div className="rounded-2xl bg-coral/15 p-3">
          <div className="flex items-center justify-between">
            <p className="text-[9px] font-semibold uppercase tracking-wide text-coral">Next up</p>
            <span
              className={`flex items-center gap-1 rounded-full bg-coral/20 px-2 py-1 text-[8px] font-bold text-coral transition-transform duration-300 ${
                budgetActive ? "scale-105" : ""
              }`}
            >
              <Receipt size={9} /> Add budget
            </span>
          </div>
          <p className="mt-1 text-[13px] font-extrabold text-teal-dark">Bali Getaway</p>
          <div className="mt-1 flex items-center gap-1 text-[10px] text-teal-dark/70">
            <MapPin size={11} className="text-coral" />
            Bali, Indonesia
          </div>
          <p className="mt-2 text-[12px] font-bold text-coral">In 12 days</p>
        </div>

        <div className="flex items-center gap-2 rounded-2xl bg-black/[0.03] p-2.5">
          <CloudSun size={16} className="text-amber" />
          <div>
            <p className="text-[10px] font-bold text-teal-dark">29°C in Denpasar</p>
            <p className="text-[8px] text-black/50">Sunny</p>
          </div>
        </div>

        <div className="grid grid-cols-3 gap-2">
          {[
            { icon: Briefcase, value: "4", label: "Trips" },
            { icon: Plane, value: "1", label: "Ongoing" },
            { icon: Luggage, value: "8/12", label: "Packed" },
          ].map(({ icon: Icon, value, label }) => (
            <div key={label} className="rounded-xl bg-black/[0.03] py-2 text-center">
              <Icon size={12} className="mx-auto text-teal" />
              <p className="mt-0.5 text-[10px] font-extrabold text-teal-dark">{value}</p>
              <p className="text-[6.5px] text-black/50">{label}</p>
            </div>
          ))}
        </div>

        <div>
          <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Trip calendar</p>
          <div className="rounded-2xl bg-black/[0.03] p-2.5">
            <div className="grid grid-cols-7 gap-y-1.5 text-center">
              {["M", "T", "W", "T", "F", "S", "S"].map((d, i) => (
                <span key={`${d}-${i}`} className="text-[7px] font-semibold text-black/40">
                  {d}
                </span>
              ))}
              {days.map((d) => (
                <span
                  key={d}
                  className={`mx-auto flex h-4 w-4 items-center justify-center rounded-full text-[7px] transition-colors duration-300 ${
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
        </div>

        <div>
          <p className="mb-1.5 text-[10px] font-bold text-teal-dark">Recent photos</p>
          <div className="flex gap-1.5 rounded-2xl bg-black/[0.03] p-2">
            {[
              "bg-gradient-to-br from-coral to-black/20",
              "bg-gradient-to-br from-amber to-black/20",
              "bg-gradient-to-br from-teal to-black/20",
              "bg-gradient-to-br from-coral to-black/20",
            ].map((gradient, i) => (
              <span
                key={i}
                className={`h-9 w-9 shrink-0 rounded-lg transition-transform duration-300 ${gradient} ${
                  i === 0 && photoActive ? "scale-110 ring-2 ring-teal-dark/40" : ""
                }`}
              />
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

function TripsScene({ cardActive }: { cardActive: boolean }) {
  const trips = [
    {
      title: "Bali Getaway",
      place: "Bali, Indonesia",
      dates: "1 Sep – 10 Sep",
      status: "In 12 days",
      color: "bg-coral",
      badge: "bg-coral/10 text-coral",
      spent: 32000,
      budget: 50000,
      photos: 4,
      packed: "8/12",
      itineraryCount: 3,
    },
    {
      title: "Kerala Backwaters",
      place: "Kerala, India",
      dates: "1 Oct – 5 Oct",
      status: "In 43 days",
      color: "bg-amber",
      badge: "bg-amber/10 text-amber",
      spent: 5000,
      budget: 25000,
      photos: 1,
      packed: "0/4",
      itineraryCount: 2,
    },
    {
      title: "Tokyo Adventure",
      place: "Tokyo, Japan",
      dates: "12 Dec – 20 Dec",
      status: "In 106 days",
      color: "bg-teal",
      badge: "bg-teal/10 text-teal",
      spent: 4500,
      budget: 90000,
      photos: 1,
      packed: "—",
      itineraryCount: 0,
    },
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
            className={`flex items-start gap-2.5 rounded-2xl bg-black/[0.03] p-2.5 transition-all duration-300 ${
              i === 0 && cardActive ? "ring-1 ring-teal/40" : ""
            }`}
          >
            <div className={`mt-0.5 h-10 w-1.5 shrink-0 rounded-full ${trip.color}`} />
            <div className="flex-1">
              <p className="text-[11px] font-bold text-teal-dark">{trip.title}</p>
              <div className="mt-0.5 flex items-center gap-1 text-[9px] text-black/50">
                <MapPin size={9} />
                {trip.place}
              </div>
              <p className="mt-0.5 text-[8px] text-black/40">{trip.dates}</p>
              <div className="mt-1.5 h-1 overflow-hidden rounded-full bg-black/10">
                <div
                  className={`h-full rounded-full ${trip.color}`}
                  style={{ width: `${Math.min(100, (trip.spent / trip.budget) * 100)}%` }}
                />
              </div>
              <p className="mt-1 text-[7.5px] font-medium text-black/40">
                {trip.spent} / {trip.budget} INR spent
              </p>

              {trip.photos > 0 && (
                <div className="mt-1.5 flex gap-1">
                  {Array.from({ length: trip.photos }).map((_, j) => (
                    <span key={j} className={`h-3 w-3 shrink-0 rounded bg-gradient-to-br ${trip.color} to-black/20`} />
                  ))}
                </div>
              )}

              <div className="mt-1.5 flex gap-1">
                <span className={`flex items-center gap-0.5 rounded px-1 py-0.5 text-[7px] font-bold ${trip.badge}`}>
                  <ImageIcon size={8} /> {trip.photos}
                </span>
                <span className={`flex items-center gap-0.5 rounded px-1 py-0.5 text-[7px] font-bold ${trip.badge}`}>
                  <Luggage size={8} /> {trip.packed}
                </span>
                <span className={`flex items-center gap-0.5 rounded px-1 py-0.5 text-[7px] font-bold ${trip.badge}`}>
                  <CalendarClock size={8} /> {trip.itineraryCount}
                </span>
              </div>
            </div>
            <span className={`rounded-lg px-2 py-1 text-[8px] font-bold ${trip.badge}`}>{trip.status}</span>
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
        <span className="flex-1 text-[12px] font-extrabold text-teal-dark">Bali Getaway</span>
        <Pencil size={13} className="text-teal-dark" />
      </div>
      <div className="flex border-b border-black/5">
        {DETAIL_TABS.map((t, i) => (
          <div
            key={t}
            className={`flex-1 border-b-2 py-2 text-center text-[8.5px] font-bold transition-colors duration-300 ${
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
                className={`flex h-4 w-4 shrink-0 items-center justify-center rounded-full border-2 transition-colors duration-300 ${
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
            <span className="rounded-full bg-coral/15 px-2.5 py-1 text-[8px] font-semibold text-coral">Beach</span>
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
                className="flex items-center gap-2 py-1.5 transition-opacity duration-300"
                style={{ transitionDelay: `${i * 150}ms` }}
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
              <div className="h-full rounded-full bg-coral transition-[width] duration-[1400ms]" style={{ width: "62%" }} />
            </div>
            <p className="mt-1 text-[8px] text-black/50">19000 INR remaining of 50000</p>
          </div>
          <div className="mt-2.5 flex gap-1.5">
            <span className="flex flex-1 items-center justify-center gap-1 rounded-full border border-black/10 py-1.5 text-[8px] font-bold text-teal-dark">
              <Download size={10} /> Export CSV
            </span>
            <span className="flex flex-1 items-center justify-center gap-1 rounded-full border border-black/10 py-1.5 text-[8px] font-bold text-teal-dark">
              <Share2 size={10} /> Share
            </span>
          </div>
        </div>
      )}

      {tab === 3 && (
        <div className="px-3 pt-2.5">
          <div className="flex items-center gap-1.5 text-[8px] text-black/40">
            <Lock size={10} />
            Stored only on this device — never uploaded.
          </div>
          <div className="mt-2 grid grid-cols-2 gap-2 pb-2">
            {[
              { title: "Day 1", count: 4 },
              { title: "Day 2", count: 6 },
            ].map((doc) => (
              <div key={doc.title} className="overflow-hidden rounded-xl bg-black/[0.03]">
                <div className="relative aspect-square bg-gradient-to-br from-coral to-black/20">
                  <span className="absolute bottom-1 right-1 rounded-full bg-black/60 px-1.5 py-0.5 text-[7px] font-bold text-white">
                    {doc.count}
                  </span>
                </div>
                <div className="flex items-center gap-1 px-2 py-1.5">
                  <span className="flex-1 truncate font-semibold text-teal-dark">{doc.title}</span>
                  <Pencil size={10} className="shrink-0 text-black/30" />
                  <Share2 size={10} className="shrink-0 text-black/30" />
                </div>
              </div>
            ))}
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
          <p className="text-[8px] text-black/40">
            {toggleOn ? "Other nearby travelers can see and message you" : "Turn on to find travelers near you"}
          </p>
        </div>
        <div
          className={`flex h-4 w-8 items-center rounded-full p-0.5 transition-colors duration-300 ${
            toggleOn ? "bg-teal" : "bg-black/15"
          }`}
        >
          <div
            className={`h-3 w-3 rounded-full bg-white transition-transform duration-300 ${
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
            className={`flex items-center gap-2.5 rounded-xl px-2 py-2 transition-colors duration-300 ${
              i === 0 && rowActive ? "bg-black/[0.04]" : ""
            }`}
          >
            <div className={`flex h-8 w-8 items-center justify-center rounded-full ${t.color} text-[10px] font-bold text-white`}>
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
