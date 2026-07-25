import { Hono } from "hono";
import Message from "../models/messageSchema";
import { requireAuth } from "../middleware/auth";
import type { AppEnv } from "../types/hono";
import type { SendMessageBody } from "../types/requests";

export const messagesRoutes = new Hono<AppEnv>();
messagesRoutes.use("*", requireAuth);

function conversationIdFor(userIdA: string, userIdB: string) {
  return [userIdA, userIdB].sort().join("_");
}

messagesRoutes.get("/:otherUserId", async (c) => {
  try {
    const conversationId = conversationIdFor(c.get("userId"), c.req.param("otherUserId"));
    const messages = await Message.find({ conversationId }).sort({ createdAt: 1 });
    return c.json({ success: true, message: "Messages found", data: messages });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching messages" }, 500);
  }
});

messagesRoutes.post("/", async (c) => {
  // senderId always comes from the authenticated token — never trust a
  // caller-supplied sender, or anyone could send messages as anyone else.
  const senderId = c.get("userId");
  const { receiverId, text } = await c.req.json<Omit<SendMessageBody, "senderId">>();
  if (!receiverId || !text) {
    return c.json({ success: false, message: "receiverId and text are required" }, 400);
  }
  try {
    const message = await Message.create({
      conversationId: conversationIdFor(senderId, receiverId),
      senderId,
      receiverId,
      text,
    });
    return c.json({ success: true, message: "Message sent", data: message }, 201);
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error sending message" }, 500);
  }
});
