import type { Metadata } from "next";
import LegalLayout from "@/components/LegalLayout";

export const metadata: Metadata = {
  title: "Terms of Service — Packurbag",
  description: "The terms that govern your use of Packurbag.",
};

function H2({ children }: { children: React.ReactNode }) {
  return <h2 className="text-lg font-bold text-teal-dark">{children}</h2>;
}

export default function TermsPage() {
  return (
    <LegalLayout title="Terms of Service" updated="25 July 2026">
      <section>
        <p>
          By creating an account or using Packurbag, you agree to these terms. If you don&apos;t
          agree, please don&apos;t use the app.
        </p>
      </section>

      <section>
        <H2>Using Packurbag</H2>
        <p className="mt-2">
          Packurbag helps you plan trips: itineraries, packing lists, budgets, destination
          weather, currency conversion, translation, an AI travel assistant, and opt-in
          discovery of nearby travelers. You&apos;re responsible for the accuracy of the
          information you enter and for keeping your account credentials secure.
        </p>
      </section>

      <section>
        <H2>Acceptable use</H2>
        <p className="mt-2">
          Don&apos;t use Packurbag to harass other travelers, impersonate someone else, or
          attempt to access another user&apos;s account or data. We may suspend accounts that
          violate this.
        </p>
      </section>

      <section>
        <H2>Emergency SOS is not a substitute for emergency services</H2>
        <p className="mt-2">
          The SOS feature is a convenience tool that can call a saved contact and share your
          location. It is not connected to emergency services (like 911/112/100) and should
          never be relied on as your only means of getting help in an emergency.
        </p>
      </section>

      <section>
        <H2>Third-party data</H2>
        <p className="mt-2">
          Weather, currency, translation, and AI assistant features rely on third-party
          providers. We do our best to keep them accurate and available, but we don&apos;t
          guarantee their uptime or precision — always verify anything safety-critical (like
          weather warnings) through official sources.
        </p>
      </section>

      <section>
        <H2>No warranty</H2>
        <p className="mt-2">
          Packurbag is provided &ldquo;as is&rdquo;, without warranties of any kind. We&apos;re
          not liable for losses arising from your use of the app, to the fullest extent
          permitted by law.
        </p>
      </section>

      <section>
        <H2>Changes</H2>
        <p className="mt-2">
          We may update these terms as the app evolves. Continuing to use Packurbag after a
          change means you accept the updated terms.
        </p>
      </section>

      <section>
        <H2>Contact</H2>
        <p className="mt-2">Questions about these terms? Reach out at legal@packurbag.app.</p>
      </section>
    </LegalLayout>
  );
}
