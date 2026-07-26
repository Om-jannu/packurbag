import { API_BASE_URL } from "@/lib/api";

// Same-origin proxy for the backend's /health check. The frontend polls
// this route instead of calling the backend directly from the browser —
// a cross-origin fetch to a *-onrender.com domain named "/health" is
// exactly the shape ad-blockers/privacy shields (Brave Shields, uBlock,
// etc.) heuristically block as a tracking beacon, which made the status
// badge read "offline" for real visitors even when the backend was up.
// Proxying through our own origin sidesteps that entirely.
export async function GET() {
  if (!API_BASE_URL) {
    return Response.json(
      { success: false, status: "degraded", reason: "NEXT_PUBLIC_API_URL not configured" },
      { status: 503 }
    );
  }

  try {
    const res = await fetch(`${API_BASE_URL}/health`, { cache: "no-store" });
    const data = await res.json();
    return Response.json(data, { status: res.status });
  } catch {
    return Response.json({ success: false, status: "degraded" }, { status: 503 });
  }
}
