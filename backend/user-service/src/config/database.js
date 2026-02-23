// backend/user-service/src/config/database.js

const mongoose = require('mongoose');

async function connectDatabase() {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://admin:admin@localhost:27017/user_service';
    
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('Connected to MongoDB (User Service)');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    throw error;
  }
}

module.exports = {
  connectDatabase,
};
