import { Hono } from "hono";
import { env } from "../config/env";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";

export const currencyRoutes = new Hono<AppEnv>();
currencyRoutes.use("*", requireAuth);

// Proxies Open Exchange Rates so the API key never ships in the client app.
const OPEN_EXCHANGE_RATES_BASE = "https://openexchangerates.org/api";

currencyRoutes.get("/rates", async (c) => {
  if (!env.openExchangeRatesAppId) {
    return c.json(
      { success: false, message: "Currency conversion is not configured on this server" },
      503
    );
  }
  try {
    const response = await fetch(
      `${OPEN_EXCHANGE_RATES_BASE}/latest.json?base=USD&app_id=${env.openExchangeRatesAppId}`
    );
    const data = await response.json();
    // fetch() only rejects on network-level failures (DNS, timeout) — an
    // upstream 4xx/5xx with a valid JSON body (Open Exchange Rates returns
    // {error:true, status, message, description} on auth/quota failures)
    // still lands here and would otherwise get passed through as if it
    // were a 200 success.
    if (!response.ok) {
      console.error("Open Exchange Rates returned an error:", data);
      return c.json({ success: false, message: "Failed to fetch exchange rates" }, 502);
    }
    return c.json(data);
  } catch (error) {
    console.error("Error fetching exchange rates:", error);
    return c.json({ success: false, message: "Failed to fetch exchange rates" }, 500);
  }
});

currencyRoutes.get("/currencies", async (c) => {
  if (!env.openExchangeRatesAppId) {
    return c.json(
      { success: false, message: "Currency conversion is not configured on this server" },
      503
    );
  }
  try {
    const response = await fetch(
      `${OPEN_EXCHANGE_RATES_BASE}/currencies.json?app_id=${env.openExchangeRatesAppId}`
    );
    const data = await response.json();
    if (!response.ok) {
      console.error("Open Exchange Rates returned an error:", data);
      return c.json({ success: false, message: "Failed to fetch currencies" }, 502);
    }
    return c.json(data);
  } catch (error) {
    console.error("Error fetching currencies:", error);
    return c.json({ success: false, message: "Failed to fetch currencies" }, 500);
  }
});
