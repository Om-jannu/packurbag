import { Hono } from "hono";
import mongoose from "mongoose";

export const healthRoutes = new Hono();

// Render (and similar platforms) poll this to confirm the service is ready
// to receive traffic during zero-downtime deploys.
healthRoutes.get("/", async (c) => {
  const dbConnected = mongoose.connection.readyState === 1;

  return c.json(
    {
      success: dbConnected,
      status: dbConnected ? "ok" : "degraded",
      uptimeSeconds: Math.round(process.uptime()),
      timestamp: new Date().toISOString(),
      db: dbConnected ? "connected" : "disconnected",
    },
    dbConnected ? 200 : 503
  );
});
