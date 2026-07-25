"use client";

import Link from "next/link";
import { useBackendHealth } from "@/lib/useBackendHealth";

export default function BackendStatusBadge() {
  const { health } = useBackendHealth();

  const dotColor =
    health.state === "checking"
      ? "bg-black/20"
      : health.state === "online"
        ? "bg-emerald-500"
        : "bg-red-500";

  const label =
    health.state === "checking"
      ? "Checking API…"
      : health.state === "online"
        ? "API Online"
        : "API Offline";

  return (
    <Link
      href="/status"
      className="flex items-center gap-1.5 text-sm font-medium text-black/50 transition hover:text-teal"
    >
      <span className={`h-2 w-2 shrink-0 rounded-full ${dotColor}`} />
      {label}
    </Link>
  );
}
