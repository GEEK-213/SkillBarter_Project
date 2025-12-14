
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();


app.use(express.json()); 


const mongoURI = process.env.MONGO_URI;

mongoose.connect(mongoURI)
    .then(() => console.log(" DATABASE CONNECTED"))
    .catch((err) => console.log(" DB ERROR:", err));

const UserSchema = new mongoose.Schema({
    name: String,
    email: String,
    password: String,
    wallet: { type: Number, default: 3 }
});
const User = mongoose.model('User', UserSchema);


app.post('/register', async (req, res) => {
    try {
        console.log("Data received from App:", req.body); 
        
        const newUser = new User(req.body); 
        await newUser.save();

        res.json({ message: "User Created!", user: newUser });
    } catch (error) {
        res.status(500).json({ error: "Failed to save user" });
    }
});

// LOGIN ROUTE
app.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email: email });
        
        if (!user) {
            return res.json({ status: "error", message: "User not found" });
        }
      
        if (user.password === password) {
          
            return res.json({ status: "ok", user: user });
        } else {
            return res.json({ status: "error", message: "Wrong Password" });
        }

    } catch (error) {
        res.status(500).json({ error: "Login failed" });
    }
});

app.listen(3000, () => {
    console.log("🚀 Server is running on Port 3000");
});