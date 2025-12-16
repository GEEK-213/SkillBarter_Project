
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const RequestModel = require('./models/Requests');
const SkillModel = require('./models/Skills');
dotenv.config();

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

//  SKILL ROUTE
app.post('/add-skill', async (req, res) => {
    try {
        const { title, category, description, teacherId, teacherName } = req.body;

        //  Validate Data
        if (!title || !category || !teacherId) {
            return res.status(400).json({ status: "error", message: "Missing required fields" });
        }

        //  the new Skill 
        const newSkill = await SkillModel.create({
            title,
            category,
            description,
            teacherId,
            teacherName
        });
        
        res.json({ status: "ok", message: "Skill Added!", skill: newSkill });

    } catch (error) {
        console.log("Error adding skill:", error);
        res.status(500).json({ status: "error", error: "Failed to add skill" });
    }
});
    // GET SKILLS ROUTE
app.get('/get-skills', async (req, res) => {
    try {
        
        const skills = await SkillModel.find().sort({ datePosted: -1 });

        res.json({ status: "ok", data: skills });

    } catch (error) {
        res.status(500).json({ status: "error", error: "Could not fetch skills" });
    }
});

// BOOKING ROUTE
app.post('/request-skill', async (req, res) => {
    try {
        const { studentId, studentName, teacherId, teacherName, skillId, skillTitle } = req.body;

       
        if (studentId === teacherId) {
            return res.json({ status: "error", message: "You cannot book your own skill!" });
        }

       
        const newRequest = await RequestModel.create({
            studentId, studentName, teacherId, teacherName, skillId, skillTitle
        });

        res.json({ status: "ok", message: "Request Sent!", data: newRequest });

    } catch (error) {
        console.log(error);
        res.status(500).json({ status: "error", error: "Booking failed" });
    }
});

    app.get('/my-requests/:userId', async (req, res) => {
    try {
        const { userId } = req.params;

        // Find requests where I am the teacher
        const requests = await RequestModel.find({ teacherId: userId }).sort({ timestamp: -1 });

        res.json({ status: "ok", data: requests });
    } catch (error) {
        res.status(500).json({ status: "error", error: "Fetch failed" });
    }
});

// UPDATE REQUEST STATUS (Accept/Reject)
app.post('/update-request', async (req, res) => {
    try {
        const { requestId, status } = req.body;
        
        
        const updatedRequest = await RequestModel.findByIdAndUpdate(
            requestId, 
            { status: status }, 
            { new: true } 
        );

       
        res.json({ status: "ok", data: updatedRequest });

    } catch (error) {
        res.status(500).json({ status: "error", error: "Update failed" });
    }
});











app.listen(3000, () => {
    console.log(" Server is running on Port 3000");
});