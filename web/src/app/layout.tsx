import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";

const plusJakarta = Plus_Jakarta_Sans({
  variable: "--font-plus-jakarta",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Packurbag — Your Travel Companion",
  description:
    "Plan trips with itineraries, packing lists, and budgets, get destination weather, translate on the go, connect with nearby travelers, and reach help fast with emergency SOS.",
  appleWebApp: {
    title: "packurbag",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${plusJakarta.variable} antialiased`}>
      <body className="min-h-screen bg-white text-[#0b2530]">{children}</body>
    </html>
  );
}
