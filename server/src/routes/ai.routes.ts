import { Hono } from "hono";
import { openai } from "../lib/openai";
import type { AiChatBody } from "../types/requests";

export const aiRoutes = new Hono();

// Proxies OpenAI so the API key never ships in the client app. Framed as a
// travel assistant; the client may pass the active trip's destination as context.
aiRoutes.post("/chat", async (c) => {
  if (!openai) {
    return c.json({ success: false, message: "AI chat is not configured on this server" }, 503);
  }

  const { message, history, destination } = await c.req.json<AiChatBody>();
  if (!message) {
    return c.json({ success: false, message: "message is required" }, 400);
  }

  try {
    const systemPrompt = destination
      ? `You are a knowledgeable, friendly travel assistant helping a traveler currently planning or visiting ${destination}. Give concise, practical advice: local tips, food, safety, culture, and itinerary ideas.`
      : "You are a knowledgeable, friendly travel assistant. Give concise, practical advice: destination ideas, itinerary planning, local tips, food, safety, and culture.";

    const messages = [
      { role: "system" as const, content: systemPrompt },
      ...(Array.isArray(history) ? history : []),
      { role: "user" as const, content: message },
    ];

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages,
    });

    return c.json({
      success: true,
      message: completion.choices[0]?.message?.content ?? "",
    });
  } catch (error) {
    console.error("Error calling OpenAI:", error);
    return c.json({ success: false, message: "AI chat request failed" }, 500);
  }
});
