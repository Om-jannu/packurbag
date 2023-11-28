const express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const cors = require('cors');
const openai = require('openai');
const axios = require('axios');

const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

const uri = 'mongodb+srv://vedant:vedant@cluster0.fmdoczv.mongodb.net/?retryWrites=true&w=majority';
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
client.connect();

app.post('/generate-image', async (req, res) => {
    try {
      const { text } = req.body;
  
      const baseUrl = 'https://api.stability.ai';
      const url = `${baseUrl}/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image`;
  
      const response = await axios.post(
        url,
        {
          cfg_scale: 7,
          clip_guidance_preset: 'FAST_BLUE',
          height: 512,
          width: 512,
          samples: 1,
          steps: 50,
          text_prompts: [
            {
              text: text || '',
              weight: 1,
            },
          ],
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer sk-ZzE8IbH045hfVl7A544zsCJCk45NNKNcD9igmkswpc6F45MD',
            'Accept': 'image/png',
          },
        }
      );
  
      res.json({ imageUrl: response.data.imageUrl });
    } catch (error) {
      console.error('Error generating image:', error.message);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

app.post('/chat', async (req, res) => {
    try {
      const { model, message } = req.body;
  
      // You can customize this function to interact with your GPT model or any other processing
      const gptResponse = await getGptResponse(message, model);
  
      res.json({ response: gptResponse });
    } catch (error) {
      console.error('Error processing request:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  
  // Example function to interact with the GPT model (you should replace this with your actual logic)
  async function getGptResponse(message, model) {
    const gptApiKey = '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'; // Replace with your OpenAI API key
  
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model,
        messages: [{ role: 'system', content: 'You are a helpful assistant.' }, { role: 'user', content: message }],
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${gptApiKey}`,
        },
      }
    );
  
    if (response.status === 200) {
      const gptMessage = response.data.choices[0]?.message?.content;
      return gptMessage || 'No response from GPT model';
    } else {
      console.error('Failed to get response from GPT model. Status code:', response.status);
      return 'Error processing request';
    }
  }

app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const newUser = { username, password };
        await usersCollection.insertOne(newUser);
        res.json({ success: true, message: 'User registered successfully' });
    } catch (error) {
        res.json({ success: false, message: 'Registration failed' });
    }
});

app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const user = await usersCollection.findOne({ username, password });
        if (user) {
            res.json({ success: true, message: 'Login successful' });
        } else {
            res.json({ success: false, message: 'Invalid credentials' });
        }
    } catch (error) {
        res.json({ success: false, message: 'Login failed' });
    }
});

app.post('/get_categories', async (req, res) => {
    const { username } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const user = await usersCollection.findOne({ username });

        if (user && user.categories) {
            const categoriesWithCount = await Promise.all(
                user.categories.map(async (category) => {
                    const todosCount = user.todos && user.todos[category]
                        ? user.todos[category].length
                        : 0;

                    return {
                        categories: category,
                        todoCount: todosCount,
                    };
                })
            );

            res.json({
                success: true,
                categories: user.categories,
                categorywithcount: categoriesWithCount,
                message: 'Categories found for the user',
            });
        } else {
            res.json({
                success: false,
                message: 'Categories not found for the user',
            });
        }
    } catch (error) {
        console.error('Error fetching categories:', error);
        res.json({ success: false, message: 'Error fetching categories' });
    }
});


app.post('/add_category', async (req, res) => {
    const { username, category } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        await usersCollection.updateOne(
            { username },
            { $addToSet: { categories: category } }
        );
        res.json({ success: true, message: 'Category added successfully' });
    } catch (error) {
        console.error('Failed to add category:', error);
        res.json({ success: false, message: 'Failed to add category' });
    }
});

app.post('/delete_category', async (req, res) => {
    const { username, category } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        await usersCollection.updateOne(
            { username },
            { $pull: { categories: category }, $unset: { [`todos.${category}`]: '' } }
        );
        res.json({ success: true, message: 'Category deleted successfully' });
    } catch (error) {
        res.json({ success: false, message: 'Failed to delete category' });
    }
});

app.put('/edit_category', async (req, res) => {
    const { username, oldCategory, newCategory } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        await usersCollection.updateOne(
            { username, categories: oldCategory },
            { $set: { 'categories.$': newCategory } }
        );
        await usersCollection.updateOne(
            { username },
            { $rename: { [`todos.${oldCategory}`]: `todos.${newCategory}` } }
        );
        res.json({ success: true, message: 'Category edited successfully' });
    } catch (error) {
        console.error('Failed to edit category:', error);
        res.json({ success: false, message: 'Failed to edit category' });
    }
});

app.post('/get_todos', async (req, res) => {
    const { username, category } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const user = await usersCollection.findOne({ username });
        if (user && user.todos && user.todos[category]) {
            res.json({
                success: true,
                todos: user.todos[category],
                message: 'Todos found for the category',
            });
        } else {
            res.json({
                success: false,
                message: 'Todos not found for the category',
            });
        }
    } catch (error) {
        console.error('Error fetching todos:', error);
        res.json({ success: false, message: 'Error fetching todos' });
    }
});

// app.post('/get_todos_by_date', async (req, res) => {
//     const { username, selectedDate, category } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username });
//         if (user && user.todos) {
//             let todosToReturn = [];
//             if (category === null || category === undefined) {
//                 for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
//                     const filteredCategoryTodos = categoryTodos.filter(todo => {
//                         const todoDate = new Date(todo.date); // Assuming a 'date' field in the todo object
//                         return todoDate.toISOString().split('T')[0] === selectedDate.split('T')[0];
//                     });
//                     todosToReturn = todosToReturn.concat(
//                         filteredCategoryTodos.map(todo => ({ ...todo, category: categoryKey }))
//                     );
//                 }
//             } else {
//                 const categoryTodos = user.todos[category] || [];
//                 const filteredCategoryTodos = categoryTodos.filter(todo => {
//                     const todoDate = new Date(todo.date); // Assuming a 'date' field in the todo object
//                     return todoDate.toISOString().split('T')[0] === selectedDate.split('T')[0];
//                 });
//                 todosToReturn = filteredCategoryTodos.map(todo => ({ ...todo, category }));
//             }
//             res.json({
//                 success: true,
//                 todos: todosToReturn,
//                 message: 'Todos found for the selected date and category',
//             });
//         } else {
//             res.json({
//                 success: false,
//                 message: 'Todos not found for the user',
//             });
//         }
//     } catch (error) {
//         console.error('Error fetching todos:', error);
//         res.json({ success: false, message: 'Error fetching todos' });
//     }
// });
app.post('/get_todos_by_date', async (req, res) => {
    const { username, selectedDate, category } = req.body;

    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const user = await usersCollection.findOne({ username });

        if (!user || !user.todos) {
            return res.json({ success: false, message: 'Todos not found for the user' });
        }

        let todosToReturn = [];

        if (selectedDate) {
            for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
                if (category && category !== categoryKey) {
                    continue;
                }

                const filteredCategoryTodos = categoryTodos.filter(todo => {
                    const todoDate = new Date(todo.date);
                    console.log(todoDate.toISOString().split('T')[0]+" "+selectedDate.split('T')[0]);
                    return todoDate.toISOString().split('T')[0] === selectedDate.split('T')[0];
                });

                todosToReturn = todosToReturn.concat(filteredCategoryTodos.map(todo => ({ ...todo, category: categoryKey })));
            }
        } else if (category) {
            const categoryTodos = user.todos[category] || [];
            todosToReturn = categoryTodos.map(todo => ({ ...todo, category }));
        } else {
            // If no date or category is selected, fetch all todos
            for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
                todosToReturn = todosToReturn.concat(categoryTodos.map(todo => ({ ...todo, category: categoryKey })));
            }
        }

        res.json({
            success: true,
            todos: todosToReturn,
            message: 'Todos found for the selected date and category',
        });
    } catch (error) {
        console.error('Error fetching todos:', error);
        res.json({ success: false, message: 'Error fetching todos' });
    }
});

app.post('/add_todo', async (req, res) => {
    const { username, category, todo, date } = req.body;
    try {
        await client.db('packurbag').collection('users').updateOne(
            { username, categories: category },
            {
                $addToSet: {
                    [`todos.${category}`]: {
                        text: todo,
                        date: new Date(`${date}Z`),
                        completed: false, // Set completed status to false
                    }
                }
            }
        );
        res.json({ success: true, message: 'Todo added successfully' });
    } catch (error) {
        console.error('Failed to add todo:', error);
        res.json({ success: false, message: 'Failed to add todo' });
    }
});

app.put('/edit_todo', async (req, res) => {
    const { username, category, oldTodo, newTodo } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        await usersCollection.updateOne(
            { username, [`todos.${category}.text`]: oldTodo },
            { $set: { [`todos.${category}.$[elem].text`]: newTodo } },
            { arrayFilters: [{ 'elem.text': { $eq: oldTodo } }] }
        );
        res.json({ success: true, message: 'Todo edited successfully' });
    } catch (error) {
        console.error('Failed to edit todo:', error);
        res.json({ success: false, message: 'Failed to edit todo' });
    }
});

app.delete('/delete_todo', async (req, res) => {
    const { username, category, todo } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        await usersCollection.updateOne(
            { username, [`todos.${category}.text`]: todo },
            { $pull: { [`todos.${category}`]: { text: todo } } }
        );
        res.json({ success: true, message: 'Todo deleted successfully' });
    } catch (error) {
        console.error('Failed to delete todo:', error);
        res.json({ success: false, message: 'Failed to delete todo' });
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
