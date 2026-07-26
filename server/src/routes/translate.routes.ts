import { Hono } from "hono";
import { groq, GROQ_MODEL } from "../lib/groq";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { TranslateBody } from "../types/requests";

export const translateRoutes = new Hono<AppEnv>();
translateRoutes.use("*", requireAuth);

// Proxies Groq for translation so the API key never ships in the client app
// — replaces the old client-side `translator` package, which scraped
// Google Translate's public web endpoint rather than calling a real API.
translateRoutes.post("/", async (c) => {
  if (!groq) {
    return c.json({ success: false, message: "Translation is not configured on this server" }, 503);
  }

  const { text, from, to } = await c.req.json<TranslateBody>();
  if (!text || !from || !to) {
    return c.json({ success: false, message: "text, from, and to are required" }, 400);
  }

  try {
    const completion = await groq.chat.completions.create({
      model: GROQ_MODEL,
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content:
            `You are a translation engine. Translate the user's message from the ` +
            `language with ISO 639-1 code "${from}" to the language with ISO 639-1 ` +
            `code "${to}". Reply with ONLY the translated text — no explanations, ` +
            `no quotes, no notes, nothing else.`,
        },
        { role: "user", content: text },
      ],
    });

    const translated = completion.choices[0]?.message?.content?.trim() ?? "";
    return c.json({ success: true, translated });
  } catch (error) {
    console.error("Error calling Groq for translation:", error);
    return c.json({ success: false, message: "Translation request failed" }, 500);
  }
});
