const express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

const uri = 'mongodb+srv://vedant:vedant@cluster0.fmdoczv.mongodb.net/?retryWrites=true&w=majority';
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
client.connect();

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

// app.post('/get_categories', async (req, res) => {
//     const { username } = req.body;
//     try {
//         const db = client.db('packurbag');
//         const usersCollection = db.collection('users');
//         const user = await usersCollection.findOne({ username });
//         if (user && user.categories) {
//             res.json({
//                 success: true,
//                 categories: user.categories,
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
                categorywithcount : categoriesWithCount,
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

app.post('/get_todos_by_date', async (req, res) => {
    const { username, selectedDate, category } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const user = await usersCollection.findOne({ username });
        if (user && user.todos) {
            let todosToReturn = [];
            if (category === null || category === undefined) {
                for (const [categoryKey, categoryTodos] of Object.entries(user.todos)) {
                    todosToReturn = todosToReturn.concat(
                        categoryTodos.map(todo => ({ ...todo, category: categoryKey }))
                    );
                }
            } else {
                const categoryTodos = user.todos[category] || [];
                todosToReturn = categoryTodos.map(todo => ({ ...todo, category }));
            }
            res.json({
                success: true,
                todos: todosToReturn,
                message: 'Todos found for the selected date and category',
            });
        } else {
            res.json({
                success: false,
                message: 'Todos not found for the user',
            });
        }
    } catch (error) {
        console.error('Error fetching todos:', error);
        res.json({ success: false, message: 'Error fetching todos' });
    }
});

app.post('/add_todo', async (req, res) => {
    const { username, category, todo } = req.body;
    try {
        const db = client.db('packurbag');
        const usersCollection = db.collection('users');
        const currentDate = new Date();
        await usersCollection.updateOne(
            { username, categories: category },
            {
                $addToSet: {
                    [`todos.${category}`]: {
                        text: todo,
                        date: currentDate
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
