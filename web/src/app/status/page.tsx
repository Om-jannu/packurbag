import type { Metadata } from "next";
import StatusPage from "@/components/StatusPage";

export const metadata: Metadata = {
  title: "System Status — Packurbag",
  description: "Live status check for the Packurbag backend.",
};

export default function Status() {
  return <StatusPage />;
}
