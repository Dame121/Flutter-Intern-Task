// backend/notification-service/src/index.js

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

// FCM Token Schema
const fcmSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  tokens: [{ type: String }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

const FCMToken = mongoose.model('FCMToken', fcmSchema);

// Connect to MongoDB
async function connectDB() {
  try {
    await mongoose.connect(
      process.env.MONGO_URI || 'mongodb://admin:admin@localhost:27017/notification_service'
    );
    console.log('Connected to MongoDB');
  } catch (error) {
    console.error('MongoDB connection error:', error);
  }
}

/**
 * Register FCM token
 * POST /api/notifications/register-token
 */
app.post('/api/notifications/register-token', async (req, res) => {
  try {
    const { userId } = req.headers;
    const { token } = req.body;

    if (!userId || !token) {
      return res.status(400).json({ message: 'Missing userId or token' });
    }

    let fcmDoc = await FCMToken.findOne({ userId });

    if (!fcmDoc) {
      fcmDoc = new FCMToken({ userId, tokens: [token] });
    } else if (!fcmDoc.tokens.includes(token)) {
      fcmDoc.tokens.push(token);
    }

    fcmDoc.updatedAt = new Date();
    await fcmDoc.save();

    res.json({ message: 'FCM token registered', tokenCount: fcmDoc.tokens.length });
  } catch (error) {
    console.error('Register token error:', error);
    res.status(500).json({ message: 'Failed to register token', error: error.message });
  }
});

/**
 * Mock: Send notification
 * POST /api/notifications/send
 */
app.post('/api/notifications/send', async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!userId) {
      return res.status(400).json({ message: 'userId required' });
    }

    // In production, this would use Firebase Admin SDK to send actual notifications
    console.log(`[Notification] To ${userId}: ${title} - ${body}`);

    res.json({
      message: 'Notification sent (mocked)',
      userId,
    });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({ message: 'Failed to send notification', error: error.message });
  }
});

/**
 * Get user FCM tokens
 * GET /api/notifications/tokens/:userId
 */
app.get('/api/notifications/tokens/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const fcmDoc = await FCMToken.findOne({ userId });

    if (!fcmDoc) {
      return res.json({ tokens: [] });
    }

    res.json({ tokens: fcmDoc.tokens });
  } catch (error) {
    console.error('Get tokens error:', error);
    res.status(500).json({ message: 'Failed to get tokens', error: error.message });
  }
});

app.get('/health', (req, res) => res.json({ status: 'Notification Service OK' }));

const PORT = process.env.PORT || 3006;

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Notification Service running on port ${PORT}`);
  });
});
