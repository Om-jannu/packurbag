import Link from "next/link";
import { Apple, Smartphone } from "lucide-react";

export default function Cta() {
  return (
    <section className="mx-auto max-w-6xl px-6 py-24">
      <div className="relative overflow-hidden rounded-[2.5rem] bg-coral px-8 py-16 text-center text-white">
        <div
          className="pointer-events-none absolute inset-0 opacity-25"
          style={{
            background:
              "radial-gradient(50% 60% at 85% 20%, var(--color-amber) 0%, transparent 60%)",
          }}
        />
        <div className="relative">
          <h2 className="text-3xl font-extrabold tracking-tight md:text-4xl">
            Download Packurbag
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-white/85">
            No app store gatekeeping — grab the Android APK or the iOS build directly
            and start planning your next trip.
          </p>
          <div className="mx-auto mt-8 flex max-w-md flex-col items-center gap-4 sm:flex-row sm:justify-center">
            <Link
              href="/changelog"
              className="flex w-full items-center justify-center gap-2 rounded-full bg-white px-6 py-3.5 text-sm font-bold text-teal-dark transition hover:brightness-95 sm:w-auto"
            >
              <Smartphone size={18} />
              Download for Android
            </Link>
            <Link
              href="/changelog"
              className="flex w-full items-center justify-center gap-2 rounded-full bg-teal-dark px-6 py-3.5 text-sm font-bold text-white transition hover:brightness-110 sm:w-auto"
            >
              <Apple size={18} />
              Download for iOS
            </Link>
          </div>
          <p className="mt-5 text-xs text-white/70">
            Builds are rolling out — check the changelog for the latest release.
          </p>
        </div>
      </div>
    </section>
  );
}
