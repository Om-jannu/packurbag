"use client";

import Link from "next/link";
import Footer from "./Footer";
import PhoneFrame from "./PhoneFrame";
import SplashMock from "./mocks/SplashMock";
import LoginMock from "./mocks/LoginMock";
import RegisterMock from "./mocks/RegisterMock";
import HomeMock from "./mocks/HomeMock";
import TripsMock from "./mocks/TripsMock";
import NearbyMock from "./mocks/NearbyMock";
import TranslateMock from "./mocks/TranslateMock";
import CurrencyConverterMock from "./mocks/CurrencyConverterMock";
import AiAssistantMock from "./mocks/AiAssistantMock";
import ProfileMock from "./mocks/ProfileMock";
import SosMock from "./mocks/SosMock";

const SCREENS: { title: string; description: string; mock: React.ReactNode }[] = [
  { title: "Splash", description: "Launch screen, brand mark fade/scale in.", mock: <SplashMock /> },
  { title: "Login", description: "Email/password sign-in with show/hide toggle.", mock: <LoginMock /> },
  { title: "Register", description: "New account creation form.", mock: <RegisterMock /> },
  { title: "Home", description: "Dashboard: countdown, weather, calendar, quick actions.", mock: <HomeMock /> },
  {
    title: "Trips",
    description: "Every trip, with a live countdown — tap one to open its itinerary, packing, budget, and documents.",
    mock: <TripsMock />,
  },
  {
    title: "Nearby Travelers",
    description: "Opt in to meet travelers nearby — tap one to open the 1:1 chat.",
    mock: <NearbyMock />,
  },
  { title: "Translate", description: "Voice and text translation on the go.", mock: <TranslateMock /> },
  { title: "Currency Converter", description: "Convert between any two currencies.", mock: <CurrencyConverterMock /> },
  { title: "AI Assistant", description: "Destination-aware travel advice.", mock: <AiAssistantMock /> },
  { title: "Profile", description: "Account details, theme, and permissions.", mock: <ProfileMock /> },
  { title: "Emergency SOS", description: "Countdown, slide-to-cancel, emergency contacts.", mock: <SosMock /> },
];

export default function ScreensGallery() {
  return (
    <div className="flex min-h-screen flex-col">
      <div className="bg-teal-dark py-16 text-white">
        <div className="mx-auto max-w-6xl px-6">
          <Link href="/" className="text-sm font-semibold text-white/60 hover:text-white">
            ← Back home
          </Link>

          <div className="mx-auto mt-6 max-w-2xl text-center">
            <p className="text-sm font-bold uppercase tracking-widest text-amber">Design reference</p>
            <h1 className="mt-3 text-3xl font-extrabold tracking-tight md:text-4xl">
              Every screen, in one place
            </h1>
            <p className="mt-3 text-white/70">
              A living reference for the mobile app&apos;s UI — kept in sync as the design evolves.
            </p>
          </div>

          <div className="mt-16 grid grid-cols-1 gap-16 sm:grid-cols-2 lg:grid-cols-3">
            {SCREENS.map(({ title, description, mock }) => (
              <div key={title} className="flex flex-col items-center text-center">
                <PhoneFrame>{mock}</PhoneFrame>
                <h3 className="mt-8 font-bold">{title}</h3>
                <p className="mt-1 max-w-[240px] text-sm text-white/60">{description}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
