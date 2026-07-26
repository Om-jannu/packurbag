import OpenAI from "openai";
import { env } from "../config/env";

// Groq's API is wire-compatible with OpenAI's client — same SDK, just a
// different base URL and key. Powers both /ai/chat and /translate so the
// app doesn't depend on a paid OpenAI account.
export const groq = env.groqApiKey
  ? new OpenAI({ apiKey: env.groqApiKey, baseURL: "https://api.groq.com/openai/v1" })
  : null;

// Fast, capable, and Groq's own recommended replacement for the now
// deprecated llama-3.3-70b-versatile — good for both chat and translation.
export const GROQ_MODEL = "openai/gpt-oss-120b";
