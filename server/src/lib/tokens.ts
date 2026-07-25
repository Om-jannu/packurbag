import crypto from "crypto";
import jwt from "jsonwebtoken";
import { env } from "../config/env";

// Short-lived — a leaked access token is only useful for a few minutes.
const ACCESS_TOKEN_TTL = "15m";

// Sliding window — every successful refresh pushes this back out, so an
// active user is never logged out, but a device idle for 30+ days is.
export const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000;

interface AccessTokenPayload {
  sub: string;
}

export function signAccessToken(userId: string): string {
  return jwt.sign({ sub: userId } satisfies AccessTokenPayload, env.jwtSecret, {
    expiresIn: ACCESS_TOKEN_TTL,
  });
}

/** Returns the userId encoded in the token, or null if it's missing/invalid/expired. */
export function verifyAccessToken(token: string): string | null {
  try {
    const payload = jwt.verify(token, env.jwtSecret) as AccessTokenPayload;
    return payload.sub;
  } catch {
    return null;
  }
}

/** A refresh token is an opaque random value — never a signed JWT — so it can
 * actually be revoked (rotation, logout, compromise) via its DB row instead
 * of just expiring on its own schedule. */
export function generateRefreshToken(): string {
  return crypto.randomBytes(40).toString("hex");
}

export function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}
