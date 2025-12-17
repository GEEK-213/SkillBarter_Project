const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const RequestModel = require('./models/Requests');
const SkillModel = require('./models/Skills');
dotenv.config();

const app = express();

app.use(express.json()); 
app.use(cors()); 

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

// REGISTER ROUTE
app.post('/register', async (req, res) => {
    try {
        console.log("Data received:", req.body); 
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

// ADD SKILL ROUTE
app.post('/add-skill', async (req, res) => {
    try {
        const { title, category, description, teacherId, teacherName } = req.body;
        if (!title || !category || !teacherId) {
            return res.status(400).json({ status: "error", message: "Missing required fields" });
        }
        const newSkill = await SkillModel.create({
            title, category, description, teacherId, teacherName
        });
        res.json({ status: "ok", message: "Skill Added!", skill: newSkill });
    } catch (error) {
        res.status(500).json({ status: "error", error: "Failed to add skill" });
    }
});
// GET SKILLS ROUTE (Now with Search!)
app.get('/get-skills', async (req, res) => {
    try {
        const { search } = req.query; 
        
        let filter = {};

        if (search) {
          
            filter = { 
                $or: [
                    { title: { $regex: search, $options: 'i' } },
                    { category: { $regex: search, $options: 'i' } }
                ]
            };
        }

        const skills = await SkillModel.find(filter).sort({ datePosted: -1 });

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
      
        const student = await User.findById(studentId);
        
        
        if (student.wallet < 1) { 
             return res.json({ status: "error", message: "Insufficient Time Credits!" });
        }

        const newRequest = await RequestModel.create({
            studentId, studentName, teacherId, teacherName, skillId, skillTitle
        });

        res.json({ status: "ok", message: "Request Sent!" });

    } catch (error) {
        console.log(error); 
        res.status(500).json({ status: "error", error: "Booking failed" });
    }
});
// GET REQUESTS I SENT (As a Student)
app.get('/my-sent-requests/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        // Find requests where I am the STUDENT
        const requests = await RequestModel.find({ studentId: userId }).sort({ timestamp: -1 });
        res.json({ status: "ok", data: requests });
    } catch (error) {
        res.status(500).json({ status: "error", error: "Fetch failed" });
    }
});

// GET MY REQUESTS
app.get('/my-requests/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
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
        
    
        const request = await RequestModel.findById(requestId);
        
        if (status === 'Accepted' && request.status !== 'Accepted') {
            await User.findByIdAndUpdate(request.studentId, { $inc: { wallet: -1 } });
            await User.findByIdAndUpdate(request.teacherId, { $inc: { wallet: 1 } });
        }

        const updatedRequest = await RequestModel.findByIdAndUpdate(
            requestId, 
            { status: status }, 
            { new: true }
        );

        res.json({ status: "ok", data: updatedRequest });

    } catch (error) {
        console.log(error);
        res.status(500).json({ status: "error", error: "Update failed" });
    }
});

app.listen(3000, () => {
    console.log("🚀 Server is running on Port 3000");
});