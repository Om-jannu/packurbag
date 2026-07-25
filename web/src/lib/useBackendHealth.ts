"use client";

import { useCallback, useEffect, useState } from "react";
import { API_BASE_URL, type HealthResponse } from "./api";

export type HealthState =
  | { state: "checking" }
  | { state: "online"; data: HealthResponse; latencyMs: number; checkedAt: Date }
  | { state: "offline"; checkedAt: Date };

const POLL_MS = 30000;

export function useBackendHealth() {
  const [health, setHealth] = useState<HealthState>({ state: "checking" });

  const check = useCallback(async () => {
    const started = performance.now();
    try {
      const res = await fetch(`${API_BASE_URL}/health`, { cache: "no-store" });
      const latencyMs = Math.round(performance.now() - started);
      if (!res.ok) {
        setHealth({ state: "offline", checkedAt: new Date() });
        return;
      }
      const data = (await res.json()) as HealthResponse;
      setHealth({ state: "online", data, latencyMs, checkedAt: new Date() });
    } catch {
      setHealth({ state: "offline", checkedAt: new Date() });
    }
  }, []);

  useEffect(() => {
    check();
    const id = setInterval(check, POLL_MS);
    return () => clearInterval(id);
  }, [check]);

  return { health, refresh: check };
}
