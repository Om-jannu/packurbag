import type { Context, MiddlewareHandler } from "hono";
import type { AppEnv } from "../types/hono";

/** Shared in-memory sliding-window limiter, keyed by whatever [keyOf] returns.
 * Resets on every deploy/restart and doesn't share state across multiple
 * instances — both fine for this app's single-instance Render deployment. */
function slidingWindowLimit(
  keyOf: (c: Context<AppEnv>) => string,
  options: { limit: number; windowMs: number }
): MiddlewareHandler<AppEnv> {
  const requestsByKey = new Map<string, number[]>();

  return async (c, next) => {
    const key = keyOf(c);
    const now = Date.now();
    const windowStart = now - options.windowMs;

    const recent = (requestsByKey.get(key) ?? []).filter((t) => t > windowStart);
    if (recent.length >= options.limit) {
      const retryAfterSeconds = Math.ceil((recent[0]! + options.windowMs - now) / 1000);
      c.header("Retry-After", String(retryAfterSeconds));
      return c.json({ success: false, message: "Too many requests — please slow down and try again shortly." }, 429);
    }

    recent.push(now);
    requestsByKey.set(key, recent);
    await next();
  };
}

/** Per-user sliding-window rate limiter. Exists to protect a shared,
 * externally-capped resource (e.g. Groq's free-tier quota) from being
 * exhausted by one heavy user or a script hitting the endpoint directly with
 * a valid token, which would otherwise lock out every other user too. */
export function rateLimit(options: { limit: number; windowMs: number }): MiddlewareHandler<AppEnv> {
  return slidingWindowLimit((c) => c.get("userId"), options);
}

/** Per-IP sliding-window rate limiter, for routes hit *before* a token
 * exists (login/register) — protects against credential-stuffing and
 * registration-spam, where `rateLimit`'s per-user key isn't available yet. */
export function rateLimitByIp(options: { limit: number; windowMs: number }): MiddlewareHandler<AppEnv> {
  return slidingWindowLimit((c) => {
    const forwardedFor = c.req.header("x-forwarded-for");
    return forwardedFor?.split(",")[0]?.trim() ?? "unknown";
  }, options);
}
