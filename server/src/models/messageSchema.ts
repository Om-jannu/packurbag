import mongoose, { Schema, Document, Types } from "mongoose";

export interface MessageDocument extends Document {
  conversationId: string;
  senderId: Types.ObjectId;
  receiverId: Types.ObjectId;
  text: string;
  createdAt: Date;
}

const messageSchema = new Schema<MessageDocument>({
  conversationId: {
    type: String,
    required: true,
    index: true,
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
  text: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const Message = mongoose.model<MessageDocument>("Message", messageSchema);
export default Message;
