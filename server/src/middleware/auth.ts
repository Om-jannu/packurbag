import type { MiddlewareHandler } from "hono";
import { verifyAccessToken } from "../lib/tokens";
import type { AppEnv } from "../types/hono";

/** Requires a valid `Authorization: Bearer <accessToken>` header, and makes
 * the authenticated user's id available to downstream handlers via
 * `c.get("userId")` — never trust a `:userId` route param instead of this. */
export const requireAuth: MiddlewareHandler<AppEnv> = async (c, next) => {
  const header = c.req.header("Authorization");
  const token = header?.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return c.json({ success: false, message: "Missing or invalid Authorization header" }, 401);
  }

  const userId = verifyAccessToken(token);
  if (!userId) {
    return c.json({ success: false, message: "Invalid or expired access token" }, 401);
  }

  c.set("userId", userId);
  await next();
};
