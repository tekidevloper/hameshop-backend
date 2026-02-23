const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const listUsers = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/hame_shop');
        const users = await User.find({}).select('name email role');
        console.log('--- Users in Database ---');
        console.log(JSON.stringify(users, null, 2));
        mongoose.connection.close();
    } catch (error) {
        console.error('Error:', error);
    }
};

listUsers();
