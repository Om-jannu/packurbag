import { Hono } from "hono";
import User from "../models/userSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { CompletedStatusBody, ItineraryItemBody } from "../types/requests";

export const itineraryRoutes = new Hono<AppEnv>();
itineraryRoutes.use("*", requireAuth);

itineraryRoutes.get("/:tripId/itinerary", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
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

itineraryRoutes.post("/:tripId/itinerary", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
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

itineraryRoutes.put("/:tripId/itinerary/:itemId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
    const trip = user?.trips.id(c.req.param("tripId"));
    if (!trip) {
      return c.json({ success: false, message: "Trip not found" }, 404);
    }
    const item = trip.itinerary.id(c.req.param("itemId"));
    if (!item) {
      return c.json({ success: false, message: "Itinerary item not found" }, 404);
    }
    const body = await c.req.json<Partial<ItineraryItemBody>>();
    // Assign only the known editable fields — Object.assign(item, body) would
    // let any field on the same schema through (e.g. completed,
    // dateOfCreation) if the body ever contained them.
    const editableFields: (keyof ItineraryItemBody)[] = ["text", "date", "priority", "location"];
    for (const field of editableFields) {
      if (body[field] !== undefined) {
        (item as unknown as Record<string, unknown>)[field] = body[field];
      }
    }
    await user!.save();
    return c.json({ success: true, message: "Itinerary item updated" });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error updating itinerary item" }, 500);
  }
});

itineraryRoutes.delete("/:tripId/itinerary/:itemId", async (c) => {
  try {
    const user = await User.findById(c.get("userId"));
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

itineraryRoutes.put("/:tripId/itinerary/:itemId/completedStatus", async (c) => {
  const { completed } = await c.req.json<CompletedStatusBody>();
  try {
    const user = await User.findById(c.get("userId"));
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
