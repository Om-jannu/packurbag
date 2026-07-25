import { Hono } from "hono";
import User from "../models/userSchema";
import type { CompletedStatusBody, ItineraryItemBody } from "../types/requests";

export const itineraryRoutes = new Hono();

itineraryRoutes.get("/:userId/:tripId/itinerary", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    return c.json({ success: true, message: "Itinerary found", data: trip.itinerary });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching itinerary" }, 500);
  }
});

itineraryRoutes.post("/:userId/:tripId/itinerary", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    trip.itinerary.push({ ...(await c.req.json<ItineraryItemBody>()), dateOfCreation: new Date() } as never);
    await user!.save();
    return c.json({ success: true, message: "Itinerary item added" }, 201);
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error adding itinerary item" }, 500);
  }
});

itineraryRoutes.put("/:userId/:tripId/itinerary/:itemId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.itinerary.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Itinerary item not found" }, 404);
    }
    Object.assign(item, await c.req.json<Partial<ItineraryItemBody>>());
    await user!.save();
    return c.json({ success: true, message: "Itinerary item updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating itinerary item" }, 500);
  }
});

itineraryRoutes.delete("/:userId/:tripId/itinerary/:itemId", async (c) => {
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.itinerary.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Itinerary item not found" }, 404);
    }
    item.deleteOne();
    await user!.save();
    return c.json({ success: true, message: "Itinerary item deleted" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error deleting itinerary item" }, 500);
  }
});

itineraryRoutes.put("/:userId/:tripId/itinerary/:itemId/completedStatus", async (c) => {
  const { completed } = await c.req.json<CompletedStatusBody>();
  try {
    const user = await User.findById(c.req.param("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.itinerary.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Itinerary item not found" }, 404);
    }
    item.completed = completed;
    await user!.save();
    return c.json({ success: true, message: "Itinerary item completion status updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating completion status" }, 500);
  }
});
