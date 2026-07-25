export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL?.replace(/\/$/, "");

export interface HealthResponse {
  success: boolean;
  status: "ok" | "degraded";
  uptimeSeconds: number;
  timestamp: string;
  db: "connected" | "disconnected";
}
