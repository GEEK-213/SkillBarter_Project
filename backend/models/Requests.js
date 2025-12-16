// backend/models/Requests.js
const mongoose = require('mongoose');

const RequestSchema = new mongoose.Schema({
    studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    studentName: String, 
    
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    teacherName: String,

    skillId: { type: mongoose.Schema.Types.ObjectId, ref: 'Skill' },
    skillTitle: String,

    status: { 
        type: String, 
        default: "Pending" 
    },
    timestamp: { type: Date, default: Date.now }
});

const RequestModel = mongoose.model("requests", RequestSchema);
module.exports = RequestModel;