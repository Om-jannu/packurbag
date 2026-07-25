import { Hono } from "hono";
import Message from "../models/messageSchema";
import type { SendMessageBody } from "../types/requests";

export const messagesRoutes = new Hono();

function conversationIdFor(userIdA: string, userIdB: string) {
  return [userIdA, userIdB].sort().join("_");
}

messagesRoutes.get("/:userId/:otherUserId", async (c) => {
  try {
    const conversationId = conversationIdFor(c.req.param("userId"), c.req.param("otherUserId"));
    const messages = await Message.find({ conversationId }).sort({ createdAt: 1 });
    return c.json({ success: true, message: "Messages found", data: messages });
  } catch (error) {
    console.error(error);
    return c.json({ success: false, message: "Error fetching messages" }, 500);
  }
});

messagesRoutes.post("/", async (c) => {
  const { senderId, receiverId, text } = await c.req.json<SendMessageBody>();
  if (!senderId || !receiverId || !text) {
    return c.json({ success: false, message: "senderId, receiverId and text are required" }, 400);
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
