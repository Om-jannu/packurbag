import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { errorHandler } from "./middleware/error-handler";
import { healthRoutes } from "./routes/health.routes";
import { authRoutes } from "./routes/auth.routes";
import { tripsRoutes } from "./routes/trips.routes";
import { itineraryRoutes } from "./routes/itinerary.routes";
import { packingRoutes } from "./routes/packing.routes";
import { expensesRoutes } from "./routes/expenses.routes";
import { currencyRoutes } from "./routes/currency.routes";
import { weatherRoutes } from "./routes/weather.routes";
import { usersRoutes } from "./routes/users.routes";
import { travelersRoutes } from "./routes/travelers.routes";
import { messagesRoutes } from "./routes/messages.routes";
import { aiRoutes } from "./routes/ai.routes";

export function createApp() {
  const app = new Hono();

  app.use("*", logger());
  // The primary client is a native mobile app, which has no fixed origin to
  // allowlist (and doesn't send/enforce CORS the way a browser does) — auth
  // is handled entirely by the Bearer token, not by origin, so there's
  // nothing meaningful an origin restriction would protect here.
  app.use("*", cors({ origin: "*" }));

  app.get("/", async (c) => {
    return c.json({ success: true, message: "server running" });
  });

  app.route("/health", healthRoutes);
  app.route("/", authRoutes);
  app.route("/trips", tripsRoutes);
  app.route("/trips", itineraryRoutes);
  app.route("/trips", packingRoutes);
  app.route("/trips", expensesRoutes);
  app.route("/currency", currencyRoutes);
  app.route("/weather", weatherRoutes);
  app.route("/users", usersRoutes);
  app.route("/travelers", travelersRoutes);
  app.route("/messages", messagesRoutes);
  app.route("/ai", aiRoutes);

  app.onError(errorHandler);

  return app;
}
