import type { MiddlewareHandler } from "hono";
import type { AppEnv } from "../types/hono";

/** In-memory per-user sliding-window rate limiter. Resets on every deploy/
 * restart, and doesn't share state across multiple instances — both fine for
 * this app's single-instance Render deployment. Exists to protect a shared,
 * externally-capped resource (e.g. Groq's free-tier quota) from being
 * exhausted by one heavy user or a script hitting the endpoint directly with
 * a valid token, which would otherwise lock out every other user too. */
export function rateLimit(options: { limit: number; windowMs: number }): MiddlewareHandler<AppEnv> {
  const requestsByUser = new Map<string, number[]>();

  return async (c, next) => {
    const userId = c.get("userId");
    const now = Date.now();
    const windowStart = now - options.windowMs;

    const recent = (requestsByUser.get(userId) ?? []).filter((t) => t > windowStart);
    if (recent.length >= options.limit) {
      const retryAfterSeconds = Math.ceil((recent[0]! + options.windowMs - now) / 1000);
      c.header("Retry-After", String(retryAfterSeconds));
      return c.json({ success: false, message: "Too many requests — please slow down and try again shortly." }, 429);
    }

    recent.push(now);
    requestsByUser.set(userId, recent);
    await next();
  };
}
