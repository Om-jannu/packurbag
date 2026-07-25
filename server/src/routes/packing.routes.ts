import { Hono } from "hono";
import User from "../models/userSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { PackedStatusBody, PackingItemBody } from "../types/requests";

export const packingRoutes = new Hono<AppEnv>();
packingRoutes.use("*", requireAuth);

packingRoutes.get("/:tripId/packing", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    return c.json({ success: true, message: "Packing items found", data: trip.packingItems });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching packing items" }, 500);
  }
});

packingRoutes.post("/:tripId/packing", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const body = await c.req.json<PackingItemBody | PackingItemBody[]>();
    const items = Array.isArray(body) ? body : [body];
    trip.packingItems.push(...(items as never[]));
    await user!.save();
    return c.json({ success: true, message: "Packing item(s) added" }, 201);
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error adding packing item" }, 500);
  }
});

packingRoutes.put("/:tripId/packing/:itemId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.packingItems.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Packing item not found" }, 404);
    }
    Object.assign(item, await c.req.json<Partial<PackingItemBody>>());
    await user!.save();
    return c.json({ success: true, message: "Packing item updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating packing item" }, 500);
  }
});

packingRoutes.delete("/:tripId/packing/:itemId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.packingItems.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Packing item not found" }, 404);
    }
    item.deleteOne();
    await user!.save();
    return c.json({ success: true, message: "Packing item deleted" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error deleting packing item" }, 500);
  }
});

packingRoutes.put("/:tripId/packing/:itemId/packedStatus", async (c) => {
  const { packed } = await c.req.json<PackedStatusBody>();
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.packingItems.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Packing item not found" }, 404);
    }
    item.packed = packed;
    await user!.save();
    return c.json({ success: true, message: "Packing item status updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating packing item status" }, 500);
  }
});
