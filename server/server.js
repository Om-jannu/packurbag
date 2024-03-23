// const express = require('express');
// const { MongoClient } = require('mongodb');
// const bodyParser = require('body-parser');
// const cors = require('cors');
// const openai = require('openai');
// const axios = require('axios');

// const app = express();
// const port = 5000;

// app.use(cors());
// app.use(bodyParser.json());

// const uri = 'mongodb+srv://vedant:vedant@cluster0.fmdoczv.mongodb.net/?retryWrites=true&w=majority';
// const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
// client.connect();

// app.post('/generate-image', async (req, res) => {
//     try {
//       const { text } = req.body;

//       const baseUrl = 'https://api.stability.ai';
//       const url = `${baseUrl}/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image`;

//       const response = await axios.post(
//         url,
//         {
//           cfg_scale: 7,
//           clip_guidance_preset: 'FAST_BLUE',
//           height: 512,
//           width: 512,
//           samples: 1,
//           steps: 50,
//           text_prompts: [
//             {
//               text: text || '',
//               weight: 1,
//             },
//           ],
//         },
//         {
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer sk-ZzE8IbH045hfVl7A544zsCJCk45NNKNcD9igmkswpc6F45MD',
//             'Accept': 'image/png',
//           },
//         }
//       );

//       res.json({ imageUrl: response.data.imageUrl });
//     } catch (error) {
//       console.error('Error generating image:', error.message);
//       res.status(500).json({ error: 'Internal Server Error' });
//     }
//   });

// app.post('/chat', async (req, res) => {
//     try {
//       const { model, message } = req.body;

//       // You can customize this function to interact with your GPT model or any other processing
//       const gptResponse = await getGptResponse(message, model);

//       res.json({ response: gptResponse });
//     } catch (error) {
//       console.error('Error processing request:', error);
//       res.status(500).json({ error: 'Internal server error' });
//     }
//   });

//   // Example function to interact with the GPT model (you should replace this with your actual logic)
//   async function getGptResponse(message, model) {
//     const gptApiKey = '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'; // Replace with your OpenAI API key

//     const response = await axios.post(
//       'https://api.openai.com/v1/chat/completions',
//       {
//         model,
//         messages: [{ role: 'system', content: 'You are a helpful assistant.' }, { role: 'user', content: message }],
//       },
//       {
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': `Bearer ${gptApiKey}`,
//         },
//       }
//     );

//     if (response.status === 200) {
//       const gptMessage = response.data.choices[0]?.message?.content;
//       return gptMessage || 'No response from GPT model';
//     } else {
//       console.error('Failed to get response from GPT model. Status code:', response.status);
//       return 'Error processing request';
//     }
//   }

// app.post('/register', async (req, res) => {
//     const { username, password } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const newUser = { username, password };
//         await usersCollection.insertOne(newUser);
//         res.json({ success: true, message: 'User registered successfully' });
//     } catch (error) {
//         res.json({ success: false, message: 'Registration failed' });
//     }
// });

// app.post('/login', async (req, res) => {
//     const { username, password } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username, password });
//         if (user) {
//             res.json({ success: true, message: 'Login successful' });
//         } else {
//             res.json({ success: false, message: 'Invalid credentials' });
//         }
//     } catch (error) {
//         res.json({ success: false, message: 'Login failed' });
//     }
// });

// app.post('/get_categories', async (req, res) => {
//     const { username } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username });

//         if (user && user.categories) {
//             const categoriesWithCount = await Promise.all(
//                 user.categories.map(async (category) => {
//                     const todosCount = user.todos && user.todos[category]
//                         ? user.todos[category].length
//                         : 0;

//                     return {
//                         categories: category,
//                         todoCount: todosCount,
//                     };
//                 })
//             );

//             res.json({
//                 success: true,
//                 categories: user.categories,
//                 categorywithcount: categoriesWithCount,
//                 message: 'Categories found for the user',
//             });
//         } else {
//             res.json({
//                 success: false,
//                 message: 'Categories not found for the user',
//             });
//         }
//     } catch (error) {
//         console.error('Error fetching categories:', error);
//         res.json({ success: false, message: 'Error fetching categories' });
//     }
// });

// app.post('/add_category', async (req, res) => {
//     const { username, category } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         await usersCollection.updateOne(
//             { username },
//             { $addToSet: { categories: category } }
//         );
//         res.json({ success: true, message: 'Category added successfully' });
//     } catch (error) {
//         console.error('Failed to add category:', error);
//         res.json({ success: false, message: 'Failed to add category' });
//     }
// });

// app.post('/delete_category', async (req, res) => {
//     const { username, category } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         await usersCollection.updateOne(
//             { username },
//             { $pull: { categories: category }, $unset: { [`todos.${category}`]: '' } }
//         );
//         res.json({ success: true, message: 'Category deleted successfully' });
//     } catch (error) {
//         res.json({ success: false, message: 'Failed to delete category' });
//     }
// });

// app.put('/edit_category', async (req, res) => {
//     const { username, oldCategory, newCategory } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         await usersCollection.updateOne(
//             { username, categories: oldCategory },
//             { $set: { 'categories.$': newCategory } }
//         );
//         await usersCollection.updateOne(
//             { username },
//             { $rename: { [`todos.${oldCategory}`]: `todos.${newCategory}` } }
//         );
//         res.json({ success: true, message: 'Category edited successfully' });
//     } catch (error) {
//         console.error('Failed to edit category:', error);
//         res.json({ success: false, message: 'Failed to edit category' });
//     }
// });

// app.post('/get_todos', async (req, res) => {
//     const { username, category } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username });
//         if (user && user.todos && user.todos[category]) {
//             res.json({
//                 success: true,
//                 todos: user.todos[category],
//                 message: 'Todos found for the category',
//             });
//         } else {
//             res.json({
//                 success: false,
//                 message: 'Todos not found for the category',
//             });
//         }
//     } catch (error) {
//         console.error('Error fetching todos:', error);
//         res.json({ success: false, message: 'Error fetching todos' });
//     }
// });
// app.post('/get_todos_by_date', async (req, res) => {
//     const { username, selectedDate, category } = req.body;

//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username });

//         if (!user || !user.todos) {
//             return res.json({ success: false, message: 'Todos not found for the user' });
//         }

//         let todosToReturn = [];

//         if (selectedDate) {
//             for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
//                 if (category && category !== categoryKey) {
//                     continue;
//                 }

//                 const filteredCategoryTodos = categoryTodos.filter(todo => {
//                     const todoDate = new Date(todo.date);
//                     console.log(todoDate.toISOString().split('T')[0]+" "+selectedDate.split('T')[0]);
//                     return todoDate.toISOString().split('T')[0] === selectedDate.split('T')[0];
//                 });

//                 todosToReturn = todosToReturn.concat(filteredCategoryTodos.map(todo => ({ ...todo, category: categoryKey })));
//             }
//         } else if (category) {
//             const categoryTodos = user.todos[category] || [];
//             todosToReturn = categoryTodos.map(todo => ({ ...todo, category }));
//         } else {
//             // If no date or category is selected, fetch all todos
//             for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
//                 todosToReturn = todosToReturn.concat(categoryTodos.map(todo => ({ ...todo, category: categoryKey })));
//             }
//         }

//         res.json({
//             success: true,
//             todos: todosToReturn,
//             message: 'Todos found for the selected date and category',
//         });
//     } catch (error) {
//         console.error('Error fetching todos:', error);
//         res.json({ success: false, message: 'Error fetching todos' });
//     }
// });

// app.post('/add_todo', async (req, res) => {
//     const { username, category, todo, date } = req.body;
//     try {
//         await client.db('packurbag').collection('users').updateOne(
//             { username, categories: category },
//             {
//                 $addToSet: {
//                     [`todos.${category}`]: {
//                         text: todo,
//                         date: new Date(`${date}Z`),
//                         completed: false, // Set completed status to false
//                     }
//                 }
//             }
//         );
//         res.json({ success: true, message: 'Todo added successfully' });
//     } catch (error) {
//         console.error('Failed to add todo:', error);
//         res.json({ success: false, message: 'Failed to add todo' });
//     }
// });

// app.put('/edit_todo', async (req, res) => {
//     const { username, category, oldTodo, newTodo } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         await usersCollection.updateOne(
//             { username, [`todos.${category}.text`]: oldTodo },
//             { $set: { [`todos.${category}.$[elem].text`]: newTodo } },
//             { arrayFilters: [{ 'elem.text': { $eq: oldTodo } }] }
//         );
//         res.json({ success: true, message: 'Todo edited successfully' });
//     } catch (error) {
//         console.error('Failed to edit todo:', error);
//         res.json({ success: false, message: 'Failed to edit todo' });
//     }
// });

// app.delete('/delete_todo', async (req, res) => {
//     const { username, category, todo } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         await usersCollection.updateOne(
//             { username, [`todos.${category}.text`]: todo },
//             { $pull: { [`todos.${category}`]: { text: todo } } }
//         );
//         res.json({ success: true, message: 'Todo deleted successfully' });
//     } catch (error) {
//         console.error('Failed to delete todo:', error);
//         res.json({ success: false, message: 'Failed to delete todo' });
//     }
// });

// app.listen(port, () => {
//     console.log(`Server is running on http://localhost:${port}`);
// });

const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const mongoose = require("mongoose");
const axios = require("axios");
const User = require("./models/userSchema");
const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

mongoose.connect(
  "mongodb+srv://vedant:vedant@cluster0.fmdoczv.mongodb.net/packurbag?retryWrites=true&w=majority"
);

const { v4: uuidv4 } = require("uuid");

function generateUniqueKey() {
  return uuidv4();
}
function generateUniqueKey() {
  const timestamp = Date.now().toString(36); // Convert current timestamp to base36 string
  const randomNumber = Math.random().toString(36).substr(2, 5); // Generate a random number and convert to base36 string
  return `${timestamp}-${randomNumber}`;
}

// ==========================Define routes================================
// Fetch todos
app.get("/todos/:userId", async (req, res) => {
  const userId = req.params.userId;
  try {
    const user = await User.findById(userId);
    res.send(user.todos);
  } catch (error) {
    console.error(error);
    res.status(500).send("Error fetching todos");
  }
});

// Add todo
app.post("/todos/:userId", async (req, res) => {
  const userId = req.params.userId;
  const todoData = req.body;
  console.log(userId, todoData);

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Generate unique key for the todo
    const todoKey = generateUniqueKey();

    // Set the todo with the generated key
    user.todos.set(todoKey, todoData);

    // Update the todo count for the corresponding category
    const categoryIndex = user.categories.findIndex(
      (category) => category.categoryName === todoData.category
    );
    if (categoryIndex !== -1) {
      user.categories[categoryIndex].todoCount++;
    }

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
    const todo = user.todos.id(todoId);
    todo.set(updatedTodoData);
    await user.save();
    res.send(user.todos);
  } catch (error) {
    console.error(error);
    res.status(500).send("Error updating todo");
  }
});

// Delete todo
app.delete("/todos/:userId/:todoId", async (req, res) => {
  const userId = req.params.userId;
  const todoId = req.params.todoId;
  try {
    const user = await User.findById(userId);
    user.todos.id(todoId).remove();
    await user.save();
    res.send(user.todos);
  } catch (error) {
    console.error(error);
    res.status(500).send("Error deleting todo");
  }
});

// Register a new user
app.post("/register", async (req, res) => {
  const { username, password, userEmail } = req.body;
  try {
    const newUser = new User({ username, userEmail, password });
    await newUser.save();
    res.json({ success: true, message: "User registered successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Registration failed" });
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
        success: false,
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
      return res.status(404).send("User not found");
    }

    // Check if the category exists for the user
    const categoryIndex = user.categories.findIndex(
      (category) => category.categoryName.toLowerCase() === categoryName
    );
    if (categoryIndex === -1) {
      return res.status(404).send("Category not found for the user");
    }

    // Remove the category from the user's categories array
    user.categories.splice(categoryIndex, 1);
    await user.save();

    res.send("Category deleted successfully");
  } catch (error) {
    console.error(error);
    res.status(500).send("Error deleting category");
  }
});

// Edit category
app.put("/categories/:userId/:categoryName", async (req, res) => {
  const userId = req.params.userId;
  const categoryName = req.params.categoryName.toLowerCase(); // Convert category name to lowercase
  const { newCategoryName, categoryColor } = req.body;
  try {
    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).send("User not found");
    }

    // Check if the category exists for the user
    const category = user.categories.find(
      (category) => category.categoryName.toLowerCase() === categoryName
    );
    if (!category) {
      return res.status(404).send("Category not found for the user");
    }

    console.log(category);
    // Update the category name and color
    category.categoryName = newCategoryName;
    category.categoryColor = categoryColor;

    await user.save();
    res.send("Category updated successfully");
  } catch (error) {
    console.error(error);
    res.status(500).send("Error updating category");
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
      res.json({ success: false, message: "User not found" });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: "Login failed" });
  }
});

// Get categories for a user
app.post("/get_categories", async (req, res) => {
  const { username } = req.body;
  try {
    const user = await User.findOne({ username });
    console.log(user.categories, user.todos);
    if (user && user.categories) {
      const categoriesWithCount = await Promise.all(
        user.categories.map(async (category) => {
          const todosCount =
            user.todos && user.todos.get(category)
              ? user.todos.get(category).length
              : 0;

          return {
            category,
            todoCount: todosCount,
          };
        })
      );
      console.log(categoriesWithCount);

      res.json({
        success: true,
        categories: user.categories,
        categorywithcount: categoriesWithCount,
        message: "Categories found for the user",
      });
    } else {
      res.json({
        success: false,
        message: "Categories not found for the user",
      });
    }
  } catch (error) {
    console.error("Error fetching categories:", error);
    res
      .status(500)
      .json({ success: false, message: "Error fetching categories" });
  }
});

// Add category to user
app.post("/add_category", async (req, res) => {
  const { username, category } = req.body;
  try {
    await User.updateOne({ username }, { $addToSet: { categories: category } });
    res.json({ success: true, message: "Category added successfully" });
  } catch (error) {
    console.error("Failed to add category:", error);
    res.status(500).json({ success: false, message: "Failed to add category" });
  }
});

// Delete category
app.post("/delete_category", async (req, res) => {
  const { username, category } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { username },
      { $pull: { categories: category }, $unset: { [`todos.${category}`]: "" } }
    );
    if (user) {
      res.json({ success: true, message: "Category deleted successfully" });
    } else {
      res.json({ success: false, message: "User not found" });
    }
  } catch (error) {
    console.error("Failed to delete category:", error);
    res
      .status(500)
      .json({ success: false, message: "Failed to delete category" });
  }
});

// Edit category
app.put("/edit_category", async (req, res) => {
  const { username, oldCategory, newCategory } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { username, categories: oldCategory },
      { $set: { "categories.$": newCategory } }
    );
    if (user) {
      await User.updateOne(
        { username },
        { $rename: { [`todos.${oldCategory}`]: `todos.${newCategory}` } }
      );
      res.json({ success: true, message: "Category edited successfully" });
    } else {
      res.json({ success: false, message: "User or category not found" });
    }
  } catch (error) {
    console.error("Failed to edit category:", error);
    res
      .status(500)
      .json({ success: false, message: "Failed to edit category" });
  }
});
// Get todos for a category
app.get("/get_todos", async (req, res) => {
  const userId = req.query.userId;
  console.log(userId);
  try {
    const user = await User.findById(userId);
    console.log(user);
    if (user && user.todos) {
      let allTodos = [];
      user.todos.forEach((categoryTodos) => {
        allTodos = allTodos.concat(categoryTodos);
      });
      res.json({
        success: true,
        todos: allTodos,
        message: `Todos found for the user ${user.username}`,
      });
    } else {
      res.json({
        success: false,
        message: `Todos not found for the user ${user}`,
      });
    }
  } catch (error) {
    console.error("Error fetching todos:", error);
    res.status(500).json({ success: false, message: "Error fetching todos" });
  }
});

// Add todo to a category
app.post("/add_todo", async (req, res) => {
  const { username, category, todo, date } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { username, categories: category },
      {
        $addToSet: {
          [`todos.${category}`]: {
            text: todo,
            date: new Date(date),
            completed: false,
          },
        },
      }
    );
    if (user) {
      res.json({ success: true, message: "Todo added successfully" });
    } else {
      res.json({ success: false, message: "User or category not found" });
    }
  } catch (error) {
    console.error("Failed to add todo:", error);
    res.status(500).json({ success: false, message: "Failed to add todo" });
  }
});

// Edit todo text
app.put("/edit_todo", async (req, res) => {
  const { username, category, oldTodo, newTodo } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { username, [`todos.${category}.text`]: oldTodo },
      { $set: { [`todos.${category}.$[elem].text`]: newTodo } },
      { arrayFilters: [{ "elem.text": oldTodo }], new: true }
    );
    if (user) {
      res.json({ success: true, message: "Todo edited successfully" });
    } else {
      res.json({ success: false, message: "User or todo not found" });
    }
  } catch (error) {
    console.error("Failed to edit todo:", error);
    res.status(500).json({ success: false, message: "Failed to edit todo" });
  }
});

// Delete todo from a category
app.delete("/delete_todo", async (req, res) => {
  const { username, category, todo } = req.body;
  try {
    const user = await User.findOneAndUpdate(
      { username, [`todos.${category}.text`]: todo },
      { $pull: { [`todos.${category}`]: { text: todo } } },
      { new: true }
    );
    if (user) {
      res.json({ success: true, message: "Todo deleted successfully" });
    } else {
      res.json({ success: false, message: "User or todo not found" });
    }
  } catch (error) {
    console.error("Failed to delete todo:", error);
    res.status(500).json({ success: false, message: "Failed to delete todo" });
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
