const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/hame_shop';
    // Log URI without sensitive info
    const sanitizedUri = mongoUri.includes('@') 
        ? mongoUri.split('@')[1] 
        : mongoUri;
    console.log(`Attempting to connect to MongoDB: ${sanitizedUri}`);
    
    const conn = await mongoose.connect(mongoUri, {
        serverSelectionTimeoutMS: 5000, 
    });
    
    console.log(`MongoDB Connected: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error(`MongoDB Connection Error: ${error.message}`);
    throw error;
  }
};

module.exports = connectDB;
