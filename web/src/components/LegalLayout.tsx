import Link from "next/link";
import Footer from "./Footer";

export default function LegalLayout({
  title,
  updated,
  children,
}: {
  title: string;
  updated: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen flex-col">
      <div className="mx-auto w-full max-w-3xl flex-1 px-6 py-16">
        <Link href="/" className="text-sm font-semibold text-teal hover:text-teal-dark">
          ← Back home
        </Link>

        <h1 className="mt-6 text-3xl font-extrabold tracking-tight text-teal-dark">{title}</h1>
        <p className="mt-2 text-sm text-black/50">Last updated {updated}</p>

        <div className="mt-10 space-y-8 text-[15px] leading-7 text-black/75">{children}</div>
      </div>
      <Footer />
    </div>
  );
}
