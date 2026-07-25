import { Hono } from "hono";
import User from "../models/userSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { LocationBody } from "../types/requests";

export const usersRoutes = new Hono<AppEnv>();
usersRoutes.use("*", requireAuth);

usersRoutes.put("/location", async (c) => {
  const { lat, lng, isDiscoverable } = await c.req.json<LocationBody>();
  try {
    const user = await User.findById(c.get("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    if (lat !== undefined && lng !== undefined) {
      user.location = { type: "Point", coordinates: [lng, lat] };
      user.locationUpdatedAt = new Date();
    }
    if (isDiscoverable !== undefined) {
      user.isDiscoverable = isDiscoverable;
    }
    await user.save();
    return c.json({ success: true, message: "Location updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating location" }, 500);
  }
});
