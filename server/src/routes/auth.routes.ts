import { Hono } from "hono";
import User from "../models/userSchema";
import RefreshToken from "../models/refreshTokenSchema";
import {
  generateRefreshToken,
  hashToken,
  signAccessToken,
  REFRESH_TOKEN_TTL_MS,
} from "../lib/tokens";
import type { LoginBody, RegisterBody } from "../types/requests";

export const authRoutes = new Hono();

interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

async function issueTokenPair(userId: string): Promise<TokenPair> {
  const accessToken = signAccessToken(userId);
  const refreshToken = generateRefreshToken();
  await RefreshToken.create({
    userId,
    tokenHash: hashToken(refreshToken),
    expiresAt: new Date(Date.now() + REFRESH_TOKEN_TTL_MS),
  });
  return { accessToken, refreshToken };
}

authRoutes.post("/register", async (c) => {
  const { username, password, userEmail } = await c.req.json<RegisterBody>();
  try {
    const newUser = new User({ username, userEmail, password });
    await newUser.save();
    const tokens = await issueTokenPair(newUser.id);
    return c.json({ success: true, message: "User registered successfully", ...tokens });
  } catch (error) {
    console.error("Registration error:", error);
    return c.json({ success: false, message: "Registration failed" }, 500);
  }
});

authRoutes.post("/login", async (c) => {
  const { userEmail, password } = await c.req.json<LoginBody>();
  try {
    const user = await User.findOne({ userEmail });
    const passwordMatches = user ? await user.comparePassword(password) : false;

    if (user && passwordMatches) {
      const userData = user.toObject();
      delete (userData as { password?: string }).password;
      const tokens = await issueTokenPair(user.id);
      return c.json({ success: true, message: "Login successful", data: userData, ...tokens });
    } else {
      return c.json({ success: false, message: "Incorrect Password or Email" });
    }
  } catch {
    return c.json({ success: false, message: "Login failed" }, 500);
  }
});

interface RefreshBody {
  refreshToken: string;
}

authRoutes.post("/refresh", async (c) => {
  const { refreshToken } = await c.req.json<RefreshBody>();
  if (!refreshToken) {
    return c.json({ success: false, message: "refreshToken is required" }, 400);
  }

  try {
    const tokenHash = hashToken(refreshToken);
    const stored = await RefreshToken.findOne({ tokenHash });

    if (!stored) {
      return c.json({ success: false, message: "Invalid refresh token" }, 401);
    }

    if (stored.revokedAt) {
      // A revoked (already-rotated) token being presented again means it was
      // either replayed or stolen — kill every session for this user.
      await RefreshToken.updateMany(
        { userId: stored.userId, revokedAt: null },
        { revokedAt: new Date() }
      );
      return c.json(
        { success: false, message: "Session revoked — please log in again" },
        401
      );
    }

    if (stored.expiresAt.getTime() < Date.now()) {
      return c.json({ success: false, message: "Refresh token expired" }, 401);
    }

    const userId = stored.userId.toString();
    const tokens = await issueTokenPair(userId);
    stored.revokedAt = new Date();
    stored.replacedByHash = hashToken(tokens.refreshToken);
    await stored.save();

    return c.json({ success: true, message: "Token refreshed", ...tokens });
  } catch (error) {
    console.error("Error refreshing token:", error);
    return c.json({ success: false, message: "Error refreshing token" }, 500);
  }
});

authRoutes.post("/logout", async (c) => {
  const { refreshToken } = await c.req.json<RefreshBody>();
  if (refreshToken) {
    await RefreshToken.updateOne(
      { tokenHash: hashToken(refreshToken) },
      { revokedAt: new Date() }
    );
  }
  // Always succeed — whether or not the token existed, the client's job is done.
  return c.json({ success: true, message: "Logged out" });
});
