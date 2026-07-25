import "dotenv/config";

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: Number(process.env.PORT) || 5000,
  mongoUrl: required("MONGO_URL"),
  allowedOrigins: process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(",").map((origin) => origin.trim())
    : "*",
  openExchangeRatesAppId: process.env.OPEN_EXCHANGE_RATES_APP_ID || null,
  openaiApiKey: process.env.OPENAI_API_KEY || null,
  weatherApiKey: process.env.WEATHER_API_KEY || null,
};

export const isProduction = env.nodeEnv === "production";
