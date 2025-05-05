const express = require("express");
const router = express.Router();
const User = require("../models/userSchema");

// Add expense
router.post("/add", async (req, res) => {
  try {
    const { userId, amount, description, categoryId } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Verify category exists
    const category = user.categories.id(categoryId);
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }

    user.expenses.push({
      amount,
      description,
      categoryId,
      date: new Date(),
    });

    await user.save();
    res.status(201).json({ message: "Expense added successfully" });
  } catch (error) {
    console.error("Error adding expense:", error);
    res.status(500).json({ message: "Error adding expense" });
  }
});

// Get all expenses for a user
router.get("/:userId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Get category details for each expense
    const expensesWithCategories = user.expenses.map(expense => {
      const category = user.categories.id(expense.categoryId);
      return {
        ...expense.toObject(),
        category: category ? {
          name: category.categoryName,
          color: category.categoryColor,
        } : null,
      };
    });

    res.json(expensesWithCategories);
  } catch (error) {
    console.error("Error fetching expenses:", error);
    res.status(500).json({ message: "Error fetching expenses" });
  }
});

// Delete expense
router.delete("/:userId/:expenseId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const expense = user.expenses.id(req.params.expenseId);
    if (!expense) {
      return res.status(404).json({ message: "Expense not found" });
    }

    expense.deleteOne();
    await user.save();
    res.json({ message: "Expense deleted successfully" });
  } catch (error) {
    console.error("Error deleting expense:", error);
    res.status(500).json({ message: "Error deleting expense" });
  }
});

module.exports = router; 