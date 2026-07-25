import { Hono } from "hono";
import User from "../models/userSchema";
import type { LoginBody, RegisterBody } from "../types/requests";

export const authRoutes = new Hono();

authRoutes.post("/register", async (c) => {
  const { username, password, userEmail } = await c.req.json<RegisterBody>();
  try {
    const newUser = new User({ username, userEmail, password });
    await newUser.save();
    return c.json({ success: true, message: "User registered successfully" });
  } catch (error) {
    console.error("Registration error:", error);
    return c.json({ success: false, message: "Registration failed" }, 500);
  }
});

authRoutes.post("/login", async (c) => {
  const { userEmail, password } = await c.req.json<LoginBody>();
  try {
    const user = await User.findOne({ userEmail });
    const passwordMatches = user ? await user.comparePassword(password) : false;

    if (user && passwordMatches) {
      const userData = user.toObject();
      delete (userData as { password?: string }).password;
      return c.json({ success: true, message: "Login successful", data: userData });
    } else {
      return c.json({ success: false, message: "Incorrect Password or Email" });
    }
  } catch {
    return c.json({ success: false, message: "Login failed" }, 500);
  }
});
