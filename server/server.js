const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const mongoose = require("mongoose");
const axios = require("axios");
const User = require("./models/userSchema");
const Expense = require("./models/expenseSchema");
const app = express();

app.use(cors());
app.use(bodyParser.json());
require("dotenv").config();

mongoose.connect(process.env.MONGO_URL);
const port = process.env.PORT || 5000;
// ==========================Define routes================================
// Register a new user
app.get("/", async (req, res) => {
  res.json({
    success: "true",
    message: "server running ",
  });
});
app.post("/register", async (req, res) => {
  const { username, password, userEmail } = req.body;
  console.log(username, password, userEmail);
  try {
    const newUser = new User({ username, userEmail, password });
    await newUser.save();
    res.json({ success: true, message: "User registered successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Registration failed" });
  }
});
// Login user
app.post("/login", async (req, res) => {
  const { userEmail, password } = req.body;
  console.log(userEmail, password);
  try {
    const user = await User.findOne({
      userEmail: userEmail,
      password: password,
    });
    console.log("user details", user);
    if (user) {
      res.json({ success: true, message: "Login successful", data: user });
    } else {
      res.json({ success: false, message: "Incorrect Password or Email" });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: "Login failed" });
  }
});

// Fetch todos
app.get("/todos/:userId", async (req, res) => {
  const userId = req.params.userId;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }
    res.json({ success: true, message: "Todos found", data: user.todos });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error fetching todos" });
  }
});

// Fetch todos for a category
app.get("/todos/:userId/:categoryId", async (req, res) => {
  console.log("inside fetch todos for categoryId");
  const userId = req.params.userId;
  const categoryId = req.params.categoryId;
  try {
    // Find the user by userId
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the category by categoryId
    const category = user.categories.find((cat) => cat._id == categoryId);
    if (!category) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found" });
    }

    // Filter todos based on the category name
    const todosForCategory = user.todos.filter(
      (todo) => todo.category === category.categoryName
    );

    if (todosForCategory.length > 0) {
      res.json({
        success: true,
        message: "Todos Found",
        data: todosForCategory,
      });
    } else {
      res.json({
        success: false,
        message: "No Todos Found for this category",
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error fetching todos" });
  }
});

// Add todo
app.post("/todos/:userId", async (req, res) => {
  const userId = req.params.userId;
  const todoData = req.body;
  console.log(todoData);

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the category for the todo
    const category = user.categories.find(
      (category) => category.categoryName === todoData.category
    );

    if (!category) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found" });
    }

    // Add the todo to the todos array with category color
    const todoWithCategoryColor = {
      ...todoData,
      categoryColor: category.categoryColor,
    };
    user.todos.push(todoWithCategoryColor);

    // Update the todo count for the corresponding category
    category.todoCount++;

    // Save the user
    await user.save();

    res.send(user.todos);
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error adding todo" });
  }
});

// Edit todo
app.put("/todos/:userId/:todoId", async (req, res) => {
  const userId = req.params.userId;
  const todoId = req.params.todoId;
  const updatedTodoData = req.body;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the todo by todoId
    const todo = user.todos.find((todo) => todo._id == todoId);
    if (!todo) {
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });
    }

    // Update todo data
    Object.assign(todo, updatedTodoData);

    await user.save();
    res.json({ success: true, message: "Todo updated successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).send("Error updating todo");
  }
});

app.delete("/todos/:userId/:todoId", async (req, res) => {
  const userId = req.params.userId;
  const todoId = req.params.todoId;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the todo by todoId
    const todo = user.todos.find((todo) => todo._id == todoId);
    console.log(todo);
    if (!todo) {
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });
    }

    // Find the category associated with the todo
    const category = user.categories.find(
      (cat) => cat.categoryName === todo.category
    );
    if (!category) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found for the todo" });
    }

    // Remove todo from the todos array
    const todoIndex = user.todos.findIndex((todo) => todo._id == todoId);
    user.todos.splice(todoIndex, 1);

    // Update todo count for the category
    if (category.todoCount && category.todoCount > 0) {
      category.todoCount--;
    }

    // Decrement todoCompleted count if todo is completed
    if (todo.completed) {
      if (category.todoCompleted && category.todoCompleted > 0) {
        category.todoCompleted--;
      }
    }

    await user.save();
    res.json({ success: true, message: "Todo deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).send("Error deleting todo");
  }
});

//todo completionstatus
app.put("/todos/:userId/:todoId/completedStatus", async (req, res) => {
  const userId = req.params.userId;
  const todoId = req.params.todoId;
  const { completed } = req.body;
  console.log(userId, todoId, completed);
  try {
    // Find the user by userId
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the todo item by todoId
    const todoIndex = user.todos.findIndex(
      (todo) => todo._id.toString() === todoId
    );
    if (todoIndex === -1) {
      return res
        .status(404)
        .json({ success: false, message: "Todo not found" });
    }

    // Update the completion status of the todo item
    user.todos[todoIndex].completed = completed;

    // Increment or decrement todoCompleted count in categories based on completion status
    const category = user.todos[todoIndex].category;
    const categoryIndex = user.categories.findIndex(
      (cat) => cat.categoryName === category
    );
    if (categoryIndex !== -1) {
      if (completed) {
        user.categories[categoryIndex].todoCompleted++;
      } else {
        user.categories[categoryIndex].todoCompleted--;
      }
    }

    // Save the updated user document
    await user.save();

    res.json({
      success: true,
      message: "Todo completion status updated successfully",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Error updating todo completion status",
    });
  }
});

// Fetch categories
app.get("/categories/:userId", async (req, res) => {
  const userId = req.params.userId;
  try {
    // Find the user by userId
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const categories = user.categories;
    if (categories.length > 0) {
      res.json({
        success: true,
        message: "Categories Found",
        data: categories,
      });
    } else {
      res.json({
        success: true,
        message: "No Categories Found",
      });
    }
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ success: false, message: "Error fetching categories" });
  }
});

// Fetch a category by its Name
app.get("/categories/:userId/:categoryName", async (req, res) => {
  const { userId, categoryName } = req.params;
  try {
    // Find the user by userId
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the category by categoryId
    const category = user.categories.find(
      (cat) => cat.categoryName.toLowerCase() === categoryName
    );
    if (!category) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found" });
    }

    res.json({
      success: true,
      message: "Category found",
      data: category,
    });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ success: false, message: "Error fetching category" });
  }
});

// Add category
app.post("/categories/:userId", async (req, res) => {
  const userId = req.params.userId;
  let { categoryName, categoryColor } = req.body;
  try {
    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }
    // Convert categoryName to lowercase
    categoryName = categoryName.toLowerCase();

    // Check if the category with the same name already exists for the user
    const existingCategory = user.categories.find(
      (category) =>
        category.categoryName.toLowerCase() === categoryName.toLowerCase()
    );
    if (existingCategory) {
      return res.status(400).json({
        success: false,
        message: "Category with the same name already exists",
      });
    }

    // Create a new category object
    const newCategory = { categoryName, categoryColor };

    // Add the new category to the user's categories array
    user.categories.push(newCategory);
    await user.save();

    res
      .status(201)
      .json({ success: true, message: "Category added successfully" });
  } catch (error) {
    console.error("Error adding category:", error);
    res.status(500).json({ success: false, message: "Error adding category:" });
  }
});

// Delete category
app.delete("/categories/:userId/:categoryName", async (req, res) => {
  const userId = req.params.userId;
  const categoryName = req.params.categoryName.toLowerCase(); // Convert category name to lowercase
  try {
    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Remove the category from the user's categories array
    const removedCategory = user.categories.find(
      (category) => category.categoryName.toLowerCase() === categoryName
    );
    if (!removedCategory) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found for the user" });
    }

    const categoryIndex = user.categories.indexOf(removedCategory);
    user.categories.splice(categoryIndex, 1);

    // Update todos with the deleted category name
    user.todos = user.todos.filter((todo) => todo.category !== categoryName);

    await user.save();

    res.json({ success: true, message: "Category deleted successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ success: false, message: "Error deleting category" });
  }
});

// Edit category
app.put("/categories/:userId/:categoryName", async (req, res) => {
  const userId = req.params.userId;
  const oldCategoryName = req.params.categoryName.toLowerCase(); // Convert category name to lowercase
  const { newCategoryName, categoryColor } = req.body;
  console.log(newCategoryName, categoryColor);
  try {
    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Find the category to be edited
    const category = user.categories.find(
      (category) => category.categoryName.toLowerCase() === oldCategoryName
    );
    if (!category) {
      return res
        .status(404)
        .json({ success: false, message: "Category not found for the user" });
    }

    // Update the category name and color
    category.categoryName = newCategoryName;
    category.categoryColor = categoryColor;

    // Update todos with the edited category name
    user.todos.forEach((todo) => {
      if (todo.category.toLowerCase() === oldCategoryName) {
        todo.category = newCategoryName;
        todo.categoryColor = categoryColor;
      }
    });

    await user.save();

    res.json({ success: true, message: "Category updated successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ success: false, message: "Error deleting category" });
  }
});

// Add expense
app.post("/expenses/:userId", async (req, res) => {
  const userId = req.params.userId;
  const expenseData = req.body;
  
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Find the category for the expense
    const category = user.categories.find(
      (category) => category.categoryName === expenseData.category
    );

    if (!category) {
      return res.status(404).json({ success: false, message: "Category not found" });
    }

    const newExpense = new Expense({
      ...expenseData,
      categoryColor: category.categoryColor,
      userId: userId
    });

    await newExpense.save();
    res.json({ success: true, message: "Expense added successfully", data: newExpense });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error adding expense" });
  }
});

// Get all expenses for a user
app.get("/expenses/:userId", async (req, res) => {
  const userId = req.params.userId;
  try {
    const expenses = await Expense.find({ userId }).sort({ date: -1 });
    res.json({ success: true, data: expenses });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error fetching expenses" });
  }
});

// Get expenses by category
app.get("/expenses/:userId/category/:categoryId", async (req, res) => {
  const userId = req.params.userId;
  const categoryId = req.params.categoryId;
  
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const category = user.categories.find((cat) => cat._id == categoryId);
    if (!category) {
      return res.status(404).json({ success: false, message: "Category not found" });
    }

    const expenses = await Expense.find({
      userId,
      category: category.categoryName
    }).sort({ date: -1 });

    res.json({ success: true, data: expenses });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error fetching expenses" });
  }
});

// Delete expense
app.delete("/expenses/:userId/:expenseId", async (req, res) => {
  const userId = req.params.userId;
  const expenseId = req.params.expenseId;
  
  try {
    const expense = await Expense.findOneAndDelete({
      _id: expenseId,
      userId: userId
    });

    if (!expense) {
      return res.status(404).json({ success: false, message: "Expense not found" });
    }

    res.json({ success: true, message: "Expense deleted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error deleting expense" });
  }
});

// Update expense
app.put("/expenses/:userId/:expenseId", async (req, res) => {
  const userId = req.params.userId;
  const expenseId = req.params.expenseId;
  const updatedData = req.body;
  
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (updatedData.category) {
      const category = user.categories.find(
        (category) => category.categoryName === updatedData.category
      );
      if (!category) {
        return res.status(404).json({ success: false, message: "Category not found" });
      }
      updatedData.categoryColor = category.categoryColor;
    }

    const expense = await Expense.findOneAndUpdate(
      { _id: expenseId, userId: userId },
      updatedData,
      { new: true }
    );

    if (!expense) {
      return res.status(404).json({ success: false, message: "Expense not found" });
    }

    res.json({ success: true, message: "Expense updated successfully", data: expense });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Error updating expense" });
  }
});

app.post("/generate-image", async (req, res) => {
  try {
    const { text } = req.body;

    const baseUrl = "https://api.stability.ai";
    const url = `${baseUrl}/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image`;

    const response = await axios.post(
      url,
      {
        cfg_scale: 7,
        clip_guidance_preset: "FAST_BLUE",
        height: 512,
        width: 512,
        samples: 1,
        steps: 50,
        text_prompts: [
          {
            text: text || "",
            weight: 1,
          },
        ],
      },
      {
        headers: {
          "Content-Type": "application/json",
          Authorization:
            "Bearer sk-ZzE8IbH045hfVl7A544zsCJCk45NNKNcD9igmkswpc6F45MD",
          Accept: "image/png",
        },
      }
    );

    res.json({ imageUrl: response.data.imageUrl });
  } catch (error) {
    console.error("Error generating image:", error.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
