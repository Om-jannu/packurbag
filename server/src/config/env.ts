import "dotenv/config";

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export const env = {
  nodeEnv: process.env.NODE_ENV,
  port: Number(process.env.PORT),
  mongoUrl: required("MONGO_URL"),
  jwtSecret: required("JWT_SECRET"),
  openExchangeRatesAppId: process.env.OPEN_EXCHANGE_RATES_APP_ID,
  groqApiKey: process.env.GROQ_API_KEY,
  weatherApiKey: process.env.WEATHER_API_KEY,
};

export const isProduction = env.nodeEnv === "production";
