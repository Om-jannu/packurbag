import type { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";

export const metadata: Metadata = {
  title: "Privacy Policy — Packurbag",
  description: "How Packurbag collects, uses, and protects your data.",
};

function H2({ children }: { children: React.ReactNode }) {
  return <h2 className="text-lg font-bold text-teal-dark">{children}</h2>;
}

export default function PrivacyPage() {
  return (
    <LegalLayout title="Privacy Policy" updated="25 July 2026">
      <section>
        <p>
          Packurbag (&ldquo;we&rdquo;, &ldquo;our&rdquo;, &ldquo;the app&rdquo;) is a trip-planning
          app. This page explains what data we collect, why, and how it&apos;s handled.
        </p>
      </section>

      <section>
        <H2>Account data</H2>
        <p className="mt-2">
          When you register, we store your username, email address, and a securely hashed
          password (we never store your password in plain text). This is used solely to sign
          you in and identify your data.
        </p>
      </section>

      <section>
        <H2>Trip data</H2>
        <p className="mt-2">
          Trips, itineraries, packing lists, budgets, and expenses you create are stored against
          your account so they sync across your own devices. We don&apos;t sell or share this
          data with advertisers.
        </p>
      </section>

      <section>
        <H2>Location &amp; Nearby Travelers</H2>
        <p className="mt-2">
          Location sharing for the Nearby Travelers feature is opt-in and off by default. When
          enabled, your approximate location is stored so other opted-in travelers can discover
          and message you; turning it off removes you from discovery immediately. Messages you
          send to other travelers are stored to display your conversation history.
        </p>
      </section>

      <section>
        <H2>Travel documents</H2>
        <p className="mt-2">
          Passport, visa, ticket, and insurance references you save are stored only on your own
          device and are never uploaded to our servers.
        </p>
      </section>

      <section>
        <H2>Third-party services</H2>
        <p className="mt-2">We proxy a few requests through our backend so third-party API keys never ship in the app:</p>
        <ul className="mt-2 list-disc space-y-1 pl-5">
          <li>OpenWeatherMap — for destination weather.</li>
          <li>Open Exchange Rates — for currency conversion.</li>
          <li>OpenAI — for the AI travel assistant; your messages are sent to generate a reply and are not used to train models on our behalf.</li>
        </ul>
      </section>

      <section>
        <H2>Your choices</H2>
        <p className="mt-2">
          You can edit or delete your trips, packing items, expenses, and documents at any time
          from within the app. Contact us if you&apos;d like your account and associated data
          deleted entirely.
        </p>
      </section>

      <section>
        <H2>Contact</H2>
        <p className="mt-2">Questions about this policy? Reach out at privacy@packurbag.app.</p>
      </section>
    </LegalLayout>
  );
}
