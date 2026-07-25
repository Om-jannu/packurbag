import { Hono } from "hono";
import { env } from "../config/env";
import type { OpenWeatherResponse } from "../types/requests";

export const weatherRoutes = new Hono();

// Proxies OpenWeatherMap so the API key never ships in the client app.
weatherRoutes.get("/", async (c) => {
  if (!env.weatherApiKey) {
    return c.json({ success: false, message: "Weather is not configured on this server" }, 503);
  }
  const lat = c.req.query("lat");
  const lng = c.req.query("lng");
  const city = c.req.query("city");
  if ((!lat || !lng) && !city) {
    return c.json({ success: false, message: "lat/lng or city is required" }, 400);
  }
  const locationQuery = city ? `q=${encodeURIComponent(city)}` : `lat=${lat}&lon=${lng}`;
  try {
    const response = await fetch(
      `https://api.openweathermap.org/data/2.5/weather?${locationQuery}&units=metric&appid=${env.weatherApiKey}`
    );
    const data = (await response.json()) as OpenWeatherResponse;
    if (!response.ok) {
      return c.json(
        { success: false, message: data.message || "Weather request failed" },
        response.status as 400 | 404 | 500
      );
    }
    return c.json({
      success: true,
      data: {
        tempCelsius: data.main?.temp,
        feelsLikeCelsius: data.main?.feels_like,
        condition: data.weather?.[0]?.main,
        description: data.weather?.[0]?.description,
        icon: data.weather?.[0]?.icon,
        cityName: data.name,
      },
    });
  } catch (error) {
    console.error("Error fetching weather:", error);
    return c.json({ success: false, message: "Failed to fetch weather" }, 500);
  }
});
