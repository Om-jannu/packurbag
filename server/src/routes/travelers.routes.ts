import { Hono } from "hono";
import User from "../models/userSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";

export const travelersRoutes = new Hono<AppEnv>();
travelersRoutes.use("*", requireAuth);

travelersRoutes.get("/nearby", async (c) => {
  const radiusKm = Number(c.req.query("radiusKm")) || 50;
  try {
    const me = await User.findById(c.get("userId"));
    if (!me) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    if (!me.isDiscoverable) {
      return c.json({
        success: false,
        message: "Turn on discoverability to see nearby travelers",
      });
    }

    const results = await User.aggregate([
      {
        $geoNear: {
          near: { type: "Point", coordinates: me.location.coordinates },
          distanceField: "distanceMeters",
          spherical: true,
          maxDistance: radiusKm * 1000,
          query: {
            isDiscoverable: true,
            _id: { $ne: me._id },
          },
        },
      },
      { $project: { username: 1, distanceMeters: 1 } },
    ]);

    return c.json({
      success: true,
      message: "Nearby travelers found",
      data: results.map((r) => ({
        userId: r._id,
        username: r.username,
        distanceKm: r.distanceMeters / 1000,
      })),
    });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error finding nearby travelers" }, 500);
  }
});
