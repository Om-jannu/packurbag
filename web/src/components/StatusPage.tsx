"use client";

import Link from "next/link";
import { CheckCircle2, XCircle, Loader2, RefreshCw } from "lucide-react";
import { useBackendHealth } from "@/lib/useBackendHealth";
import { API_BASE_URL } from "@/lib/api";
import Footer from "./Footer";

export default function StatusPage() {
  const { health, refresh } = useBackendHealth();

  return (
    <div className="flex min-h-screen flex-col">
      <div className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <Link href="/" className="text-sm font-semibold text-teal hover:text-teal-dark">
          ← Back home
        </Link>

        <h1 className="mt-6 text-3xl font-extrabold tracking-tight text-teal-dark">
          System Status
        </h1>
        <p className="mt-2 text-sm text-black/50">
          Live check against the Packurbag API at <code className="text-black/60">{API_BASE_URL}</code>
        </p>

        <div className="mt-10 rounded-3xl border border-black/5 bg-black/[0.02] p-8">
          <div className="flex items-center gap-4">
            {health.state === "checking" && (
              <Loader2 size={32} className="animate-spin text-black/30" />
            )}
            {health.state === "online" && (
              <CheckCircle2 size={32} className="text-emerald-500" />
            )}
            {health.state === "offline" && <XCircle size={32} className="text-red-500" />}

            <div>
              <p className="text-xl font-bold text-teal-dark">
                {health.state === "checking"
                  ? "Checking…"
                  : health.state === "online"
                    ? "All systems operational"
                    : "API unreachable"}
              </p>
              <p className="text-sm text-black/50">
                {health.state === "checking"
                  ? "Contacting the backend"
                  : health.state === "online"
                    ? `Responded in ${health.latencyMs}ms`
                    : "The backend did not respond — it may be waking up (free-tier hosts sleep when idle) or down."}
              </p>
            </div>
          </div>

          {health.state === "online" && (
            <dl className="mt-8 grid grid-cols-2 gap-4 text-sm">
              <div>
                <dt className="text-black/40">Database</dt>
                <dd
                  className={`mt-0.5 font-semibold ${
                    health.data.db === "connected" ? "text-emerald-600" : "text-red-500"
                  }`}
                >
                  {health.data.db === "connected" ? "Connected" : "Disconnected"}
                </dd>
              </div>
              <div>
                <dt className="text-black/40">Uptime</dt>
                <dd className="mt-0.5 font-semibold text-teal-dark">
                  {formatUptime(health.data.uptimeSeconds)}
                </dd>
              </div>
              <div>
                <dt className="text-black/40">Server time</dt>
                <dd className="mt-0.5 font-semibold text-teal-dark">
                  {new Date(health.data.timestamp).toLocaleString()}
                </dd>
              </div>
              <div>
                <dt className="text-black/40">Last checked</dt>
                <dd className="mt-0.5 font-semibold text-teal-dark">
                  {health.checkedAt.toLocaleTimeString()}
                </dd>
              </div>
            </dl>
          )}

          {health.state === "offline" && (
            <p className="mt-6 text-sm text-black/50">
              Last checked {health.checkedAt.toLocaleTimeString()}
            </p>
          )}

          <button
            type="button"
            onClick={refresh}
            className="mt-8 flex items-center gap-2 rounded-full bg-teal-dark px-5 py-2.5 text-sm font-bold text-white transition hover:brightness-110"
          >
            <RefreshCw size={14} />
            Refresh now
          </button>
        </div>

        <p className="mt-6 text-xs text-black/40">
          Auto-refreshes every 30 seconds. This page checks{" "}
          <code className="text-black/50">GET {API_BASE_URL}/health</code>, proxied through this
          site&apos;s own server so ad blockers and privacy shields don&apos;t flag the
          cross-origin request as tracking.
        </p>
      </div>
      <Footer />
    </div>
  );
}

function formatUptime(totalSeconds: number): string {
  const days = Math.floor(totalSeconds / 86400);
  const hours = Math.floor((totalSeconds % 86400) / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (days > 0) return `${days}d ${hours}h`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  if (minutes > 0) return `${minutes}m ${seconds}s`;
  return `${seconds}s`;
}
