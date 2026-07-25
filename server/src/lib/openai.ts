import OpenAI from "openai";
import { env } from "../config/env";

export const openai = env.openaiApiKey ? new OpenAI({ apiKey: env.openaiApiKey }) : null;
