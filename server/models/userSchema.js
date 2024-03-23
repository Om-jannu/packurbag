const mongoose = require("mongoose");
const todoSchema = {
  text: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  completed: {
    type: Boolean,
    default: false,
  },
  priority: {
    type: Number,
    default: 0,
  },
  category: {
    type: String,
    default: "Uncategorized",
  },
  dateOfCreation: {
    type: Date,
  },
};
const categorySchema = {
  categoryName: {
    type: String,
    required: true,
    unique: true,
  },
  categoryColor: {
    type: String,
    default: "#FFFFFF",
  },
  todoCount: {
    type: Number,
    default: 0,
  },
};

const userSchema = {
  username: {
    type: String,
    required: true,
  },
  userEmail: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  categories: {
    type: [categorySchema],
    default: [],
  },
  todos: {
    type: Map,
    of: [todoSchema],
    default: {},
  },
};
const User = mongoose.model("User", userSchema);
module.exports = User;
