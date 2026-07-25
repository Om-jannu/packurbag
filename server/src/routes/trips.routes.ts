import { Hono } from "hono";
import User from "../models/userSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { TripBody } from "../types/requests";

export const tripsRoutes = new Hono<AppEnv>();
tripsRoutes.use("*", requireAuth);

// Fetch trips
tripsRoutes.get("/", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    return c.json({ success: true, message: "Trips found", data: user.trips });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching trips" }, 500);
  }
});

// Add trip
tripsRoutes.post("/", async (c) => {
  const { title, destination, startDate, endDate, coverColor, budgetAmount, budgetCurrency } =
    await c.req.json<TripBody>();
  try {
    const user = await User.findById(c.get("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    user.trips.push({ title, destination, startDate, endDate, coverColor, budgetAmount, budgetCurrency } as never);
    await user.save();
    return c.json({ success: true, message: "Trip added successfully" }, 201);
  } catch (error) {
    console.error("Error adding trip:", error);
    return c.json({ success: false, message: "Error adding trip" }, 500);
  }
});

// Edit trip
tripsRoutes.put("/:tripId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    const trip = user.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    Object.assign(trip, await c.req.json<Partial<TripBody>>());
    await user.save();
    return c.json({ success: true, message: "Trip updated successfully" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating trip" }, 500);
  }
});

// Delete trip
tripsRoutes.delete("/:tripId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    const trip = user.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    trip.deleteOne();
    await user.save();
    return c.json({ success: true, message: "Trip deleted successfully" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error deleting trip" }, 500);
  }
});
