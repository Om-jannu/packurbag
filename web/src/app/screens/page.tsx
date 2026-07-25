import type { Metadata } from "next";
import ScreensGallery from "@/components/ScreensGallery";

export const metadata: Metadata = {
  title: "Screen Gallery — Packurbag",
  description: "Every screen mock, kept as a design reference for the mobile app.",
};

export default function ScreensPage() {
  return <ScreensGallery />;
}
