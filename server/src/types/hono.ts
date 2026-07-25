/** Shared Hono generics so every router agrees on what `c.get("userId")` means. */
export type AppEnv = {
  Variables: {
    userId: string;
  };
};
