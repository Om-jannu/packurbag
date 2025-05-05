const express = require("express");
const router = express.Router();
const User = require("../models/userSchema");

// Get all categories for a user
router.get("/:userId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user.categories);
  } catch (error) {
    console.error("Error fetching categories:", error);
    res.status(500).json({ message: "Error fetching categories" });
  }
});

// Add a new category
router.post("/add", async (req, res) => {
  try {
    const { userId, categoryName, categoryColor } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.categories.push({
      categoryName,
      categoryColor: categoryColor || "#FFFFFF",
      todoCount: 0,
      todoCompleted: 0,
    });

    await user.save();
    res.status(201).json({ message: "Category added successfully" });
  } catch (error) {
    console.error("Error adding category:", error);
    res.status(500).json({ message: "Error adding category" });
  }
});

// Delete a category
router.delete("/:userId/:categoryId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const category = user.categories.id(req.params.categoryId);
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }

    category.deleteOne();
    await user.save();
    res.json({ message: "Category deleted successfully" });
  } catch (error) {
    console.error("Error deleting category:", error);
    res.status(500).json({ message: "Error deleting category" });
  }
});

module.exports = router; 