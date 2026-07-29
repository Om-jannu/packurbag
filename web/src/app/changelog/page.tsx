import type { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";

export const metadata: Metadata = {
  title: "Changelog — Packurbag",
  description: "What's new in Packurbag.",
};

interface Highlight {
  text: string;
  href?: string;
  linkLabel?: string;
}

interface ChangelogEntry {
  version: string;
  date: string;
  highlights: (string | Highlight)[];
}

const ANDROID_APK_URL =
  "https://github.com/Om-jannu/packurbag/releases/latest/download/app-release.apk";

const ENTRIES: ChangelogEntry[] = [
  {
    version: "1.0.0",
    date: "29 July 2026",
    highlights: [
      {
        text: "First public release — Android builds are now available to download directly.",
        href: ANDROID_APK_URL,
        linkLabel: "Download the APK",
      },
      "Set up automated Android builds and releases via GitHub Actions, including proper release signing.",
      "Switched AI Chat and Translate from OpenAI to Groq — a free, actively-maintained provider — removing a dependency on an unofficial Google Translate scraper.",
      "The Translate screen now speaks the result only when you tap the new speaker button, instead of always speaking automatically.",
      "Voice input now auto-translates as soon as you stop speaking, instead of requiring a separate tap.",
      "Fixed the language picker's search box not filtering the list.",
      "Replaced the abandoned `torch_controller` package (unmaintained since 2022) with an actively-maintained alternative for the SOS flashlight signal.",
      "Polished several UI details: rounded budget expense tiles, properly centered icons in circular buttons, and theme-aware Speed Dial labels.",
    ],
  },
  {
    version: "0.3.0",
    date: "25 July 2026",
    highlights: [
      "Secured every backend route behind JWT access tokens (short-lived) and rotating refresh tokens (long-lived), with automatic reuse detection.",
      "Removed user IDs from API URLs — the backend now derives identity from the signed token on every request, closing a hole where one account could reach another's trips.",
      "The mobile app now transparently refreshes an expired session in the background, retrying the original request instead of dropping the user out.",
      "Error messages in the app now surface the backend's actual reason for a failure instead of a generic message.",
      "Added a `/health` endpoint and a Render deployment blueprint to prepare the backend for production hosting.",
      "Added a live backend status page and footer badge on this site.",
      "Synced the design-reference mocks with the latest app UI: trip budget-usage bars, the edit-trip icon, and document thumbnails.",
      "Fixed a text-alignment bug that was subtly centering copy inside every phone mock instead of left-aligning it like the real app.",
      "Installed a full favicon and app-icon set across the marketing site.",
    ],
  },
  {
    version: "0.2.0",
    date: "25 July 2026",
    highlights: [
      "Rebranded from Tour Buddy to Packurbag — new name, logo, and a teal/amber/coral color scheme across the whole app.",
      "Rebuilt around Trips as the core entity: itineraries, packing lists, budgets, and travel documents all live under a trip.",
      "Added Nearby Travelers — opt-in location sharing to discover and chat with other travelers nearby.",
      "Added an AI travel assistant, destination weather, currency conversion, translation, and emergency SOS.",
      "Redesigned the home dashboard with a trip calendar, quick stats, and upcoming itinerary items.",
      "Rewrote the backend from Express to Hono, in TypeScript, with a modular, production-ready structure.",
      "Restructured the repo into mobile/, server/, and web/ workspaces.",
      "Launched this marketing site, including a full screen-mock design reference gallery.",
    ],
  },
  {
    version: "0.1.0",
    date: "Initial release",
    highlights: [
      "Original Tour Buddy app: to-do lists, categories, a currency converter, and Bluetooth-based nearby chat.",
    ],
  },
];

export default function ChangelogPage() {
  return (
    <LegalLayout title="Changelog" updated="29 July 2026">
      <div className="space-y-10">
        {ENTRIES.map((entry) => (
          <section key={entry.version}>
            <div className="flex items-center gap-3">
              <span className="rounded-full bg-teal/10 px-3 py-1 text-sm font-bold text-teal-dark">
                v{entry.version}
              </span>
              <span className="text-sm text-black/40">{entry.date}</span>
            </div>
            <ul className="mt-4 list-disc space-y-2 pl-5">
              {entry.highlights.map((point) => {
                const text = typeof point === "string" ? point : point.text;
                const href = typeof point === "string" ? undefined : point.href;
                return (
                  <li key={text}>
                    {text}
                    {href && (
                      <>
                        {" "}
                        <a
                          href={href}
                          className="font-semibold text-teal underline hover:text-teal-dark"
                        >
                          {typeof point === "string" ? "" : point.linkLabel ?? "Download"}
                        </a>
                      </>
                    )}
                  </li>
                );
              })}
            </ul>
          </section>
        ))}
      </div>
    </LegalLayout>
  );
}
