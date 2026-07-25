import { Hono } from "hono";
import User from "../models/userSchema";
import type { TripBody } from "../types/requests";

export const tripsRoutes = new Hono();

// Fetch trips
tripsRoutes.get("/:userId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
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
tripsRoutes.post("/:userId", async (c) => {
  const { title, destination, startDate, endDate, notes, coverColor, budgetAmount, budgetCurrency } =
    await c.req.json<TripBody>();
  try {
    const user = await User.findById(c.req.param("userId"));
    if (!user) {
      return c.json({ success: false, message: "User not found" }, 404);
    }
    user.trips.push({ title, destination, startDate, endDate, notes, coverColor, budgetAmount, budgetCurrency } as never);
    await user.save();
    return c.json({ success: true, message: "Trip added successfully" }, 201);
  } catch (error) {
    console.error("Error adding trip:", error);
    return c.json({ success: false, message: "Error adding trip" }, 500);
  }
});

// Edit trip
tripsRoutes.put("/:userId/:tripId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
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
tripsRoutes.delete("/:userId/:tripId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
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
