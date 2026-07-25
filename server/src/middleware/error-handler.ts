import type { ErrorHandler } from "hono";
import { isProduction } from "../config/env";

export const errorHandler: ErrorHandler = (err, c) => {
  console.error(`Unhandled error on ${c.req.method} ${c.req.path}:`, err);
  return c.json(
    {
      success: false,
      message: isProduction ? "Internal server error" : err.message,
    },
    500
  );
};
