// backend/models/Skills.js

const mongoose = require('mongoose');

const SkillSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true 
    },
    category: {
        type: String, 
        required: true 
    },
    description: String,
    teacherId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true 
    },
    teacherName: String, 
    datePosted: {
        type: Date,
        default: Date.now
    }
});

const SkillModel = mongoose.model("skills", SkillSchema);
module.exports = SkillModel;