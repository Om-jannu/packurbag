import {
  MapPinned,
  Luggage,
  Wallet,
  Users,
  Bot,
  ShieldAlert,
  CloudSun,
  Languages,
  type LucideIcon,
} from "lucide-react";

const features: { icon: LucideIcon; title: string; description: string }[] = [
  {
    icon: MapPinned,
    title: "Trips & itineraries",
    description:
      "Plan day-by-day activities for every trip, with priorities and locations, all in one timeline.",
  },
  {
    icon: Luggage,
    title: "Packing lists",
    description:
      "Quick-apply templates for Beach, Hiking, Business, or General trips — never forget the essentials.",
  },
  {
    icon: Wallet,
    title: "Budget tracking",
    description:
      "Log expenses in any currency and see your spending converted automatically against your trip budget.",
  },
  {
    icon: CloudSun,
    title: "Destination weather",
    description:
      "Check the forecast for where you're headed right from your trip dashboard.",
  },
  {
    icon: Users,
    title: "Nearby travelers",
    description:
      "Opt in to share your location, discover other registered travelers nearby, and start chatting.",
  },
  {
    icon: Bot,
    title: "AI travel assistant",
    description:
      "Get destination-aware advice — local tips, food, safety, and itinerary ideas — on demand.",
  },
  {
    icon: Languages,
    title: "Translation",
    description: "Break language barriers with built-in voice and text translation.",
  },
  {
    icon: ShieldAlert,
    title: "Emergency SOS",
    description:
      "A countdown, slide-to-cancel, and one tap to call your emergency contact with your live location.",
  },
];

export default function Features() {
  return (
    <section id="features" className="mx-auto max-w-6xl px-6 py-24">
      <div className="mx-auto max-w-2xl text-center">
        <p className="text-sm font-bold uppercase tracking-widest text-coral">
          Everything for the trip
        </p>
        <h2 className="mt-3 text-3xl font-extrabold tracking-tight text-teal-dark md:text-4xl">
          One app, every part of the journey
        </h2>
      </div>

      <div className="mt-14 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {features.map(({ icon: Icon, title, description }) => (
          <div
            key={title}
            className="rounded-3xl border border-black/5 bg-black/[0.02] p-6 transition hover:border-teal/20 hover:bg-teal/5"
          >
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-teal/10">
              <Icon size={22} className="text-teal" />
            </div>
            <h3 className="mt-4 font-bold text-teal-dark">{title}</h3>
            <p className="mt-1.5 text-sm text-black/60">{description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
