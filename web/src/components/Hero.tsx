import Image from "next/image";
import { Luggage, Wallet, Users } from "lucide-react";
import PhoneFrame from "./PhoneFrame";
import HeroFlowMock from "./mocks/HeroFlowMock";

export default function Hero() {
  return (
    <section className="relative overflow-hidden bg-teal-dark text-white">
      <div
        className="pointer-events-none absolute inset-0 opacity-30"
        style={{
          background:
            "radial-gradient(60% 50% at 15% 10%, var(--color-coral) 0%, transparent 60%), radial-gradient(50% 50% at 90% 0%, var(--color-amber) 0%, transparent 55%)",
        }}
      />

      <div className="relative mx-auto flex max-w-6xl flex-col items-center gap-14 px-6 py-20 md:flex-row md:py-28">
        <div className="max-w-xl text-center md:text-left">
          <div className="mb-6 flex items-center justify-center gap-2 md:justify-start">
            <Image src="/packurbag-logo.png" alt="Packurbag" width={36} height={36} />
            <span className="text-lg font-extrabold">Packurbag</span>
          </div>

          <h1 className="text-4xl font-extrabold leading-tight tracking-tight md:text-5xl">
            Your whole trip,{" "}
            <span className="text-amber">planned in one place.</span>
          </h1>

          <p className="mt-5 text-lg text-white/80">
            Itineraries, packing lists, budgets, and destination weather — plus
            an AI travel assistant and a way to meet other travelers nearby.
            Everything you need before you even pack a bag.
          </p>

          <div className="mt-8 flex flex-col items-center gap-4 sm:flex-row md:justify-start">
            <a
              href="#features"
              className="w-full rounded-full bg-coral px-7 py-3.5 text-center font-bold text-white shadow-lg shadow-coral/30 transition hover:brightness-110 sm:w-auto"
            >
              Explore features
            </a>
            <a
              href="#mockups"
              className="w-full rounded-full border border-white/25 px-7 py-3.5 text-center font-bold text-white/90 transition hover:bg-white/10 sm:w-auto"
            >
              See the app
            </a>
          </div>
        </div>

        <div className="relative shrink-0">
          <div className="drop-shadow-2xl">
            <PhoneFrame>
              <HeroFlowMock />
            </PhoneFrame>
          </div>

          {/* floating 3D accent cards — vertical bob only, no tilt */}
          <div
            className="animate-float-alt absolute -left-10 top-10 z-20 flex items-center gap-2 rounded-2xl bg-white px-3 py-2.5 shadow-xl shadow-black/20 sm:-left-16"
            style={{ animationDelay: "0.4s" }}
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-coral/10">
              <Luggage size={16} className="text-coral" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-teal-dark">8/12</p>
              <p className="text-[10px] text-black/50">packed</p>
            </div>
          </div>

          <div
            className="animate-float absolute -right-8 top-1/2 z-20 flex items-center gap-2 rounded-2xl bg-white px-3 py-2.5 shadow-xl shadow-black/20 sm:-right-14"
            style={{ animationDelay: "1.1s" }}
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-teal/10">
              <Users size={16} className="text-teal" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-teal-dark">3 nearby</p>
              <p className="text-[10px] text-black/50">travelers</p>
            </div>
          </div>

          <div
            className="animate-float-alt absolute -left-6 bottom-16 z-20 flex items-center gap-2 rounded-2xl bg-white px-3 py-2.5 shadow-xl shadow-black/20 sm:-left-12"
            style={{ animationDelay: "0.8s" }}
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-amber/10">
              <Wallet size={16} className="text-amber" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-teal-dark">₹31k</p>
              <p className="text-[10px] text-black/50">of ₹50k</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
