import Image from "next/image";

export default function Footer() {
  return (
    <footer className="border-t border-black/5 bg-black/[0.015]">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-4 px-6 py-10 text-center sm:flex-row sm:justify-between sm:text-left">
        <div className="flex items-center gap-2">
          <Image src="/packurbag-logo.png" alt="Packurbag" width={24} height={24} />
          <span className="font-bold text-teal-dark">Packurbag</span>
        </div>

        <p className="text-sm text-black/50">
          &copy; {new Date().getFullYear()} Packurbag. All rights reserved.
        </p>

        <div className="flex gap-6 text-sm font-medium text-black/50">
          <a href="#features" className="transition hover:text-teal">
            Features
          </a>
          <a href="#mockups" className="transition hover:text-teal">
            App
          </a>
        </div>
      </div>
    </footer>
  );
}
