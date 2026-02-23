// backend/chat-service/src/index.js
require('dotenv').config();
const express = require('express');
const { v4: uuidv4 } = require('uuid');
const app = express();
app.use(express.json());

// CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, user-id');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Mock in-memory data store for conversations and messages
const mockConversations = {
  'user1|user2': {
    userId: 'user1',
    otherUserId: 'user2',
    updatedAt: new Date(),
    lastMessage: {
      id: 'msg1',
      senderId: 'user2',
      recipientId: 'user1',
      text: 'Thanks for the quick response!',
      createdAt: new Date(Date.now() - 5 * 60000), // 5 minutes ago
      state: 'read',
    },
  },
  'user1|user3': {
    userId: 'user1',
    otherUserId: 'user3',
    updatedAt: new Date(Date.now() - 30 * 60000), // 30 minutes ago
    lastMessage: {
      id: 'msg2',
      senderId: 'user1',
      recipientId: 'user3',
      text: 'Available for a call this week?',
      createdAt: new Date(Date.now() - 30 * 60000),
      state: 'sent',
    },
  },
};

const mockMessages = {
  'user1|user2': [
    {
      id: 'msg1',
      senderId: 'user2',
      recipientId: 'user1',
      text: 'Hi, interested in your services',
      createdAt: new Date(Date.now() - 20 * 60000),
      state: 'read',
    },
    {
      id: 'msg2',
      senderId: 'user1',
      recipientId: 'user2',
      text: 'Thanks! What would you like to discuss?',
      createdAt: new Date(Date.now() - 15 * 60000),
      state: 'read',
    },
    {
      id: 'msg3',
      senderId: 'user2',
      recipientId: 'user1',
      text: 'Thanks for the quick response!',
      createdAt: new Date(Date.now() - 5 * 60000),
      state: 'read',
    },
  ],
};

app.get('/health', (req, res) => res.json({ status: 'Chat Service OK' }));

// Get all conversations for a user
app.get('/api/chat/conversations', (req, res) => {
  try {
    const userId = req.headers['user-id'] || 'user1'; // Get from auth header
    const conversations = Object.values(mockConversations)
      .filter(conv => conv.userId === userId || conv.otherUserId === userId)
      .map(conv => ({
        userId: conv.userId,
        otherUserId: conv.otherUserId,
        lastMessage: conv.lastMessage,
        updatedAt: conv.updatedAt,
      }));

    res.json(conversations);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ error: 'Failed to fetch conversations' });
  }
});

// Get messages for a specific conversation
app.get('/api/chat/messages/:otherUserId', (req, res) => {
  try {
    const { otherUserId } = req.params;
    const userId = req.headers['user-id'] || 'user1';

    const conversationKey = [userId, otherUserId].sort().join('|');
    const messages = mockMessages[conversationKey] || [];

    res.json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Send a message
app.post('/api/chat/messages', (req, res) => {
  try {
    const { recipientId, text } = req.body;
    const senderId = req.headers['user-id'] || 'user1';

    if (!recipientId || !text) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const messageId = uuidv4();
    const conversationKey = [senderId, recipientId].sort().join('|');

    const newMessage = {
      id: messageId,
      senderId,
      recipientId,
      text,
      createdAt: new Date(),
      state: 'sent',
    };

    // Store message
    if (!mockMessages[conversationKey]) {
      mockMessages[conversationKey] = [];
    }
    mockMessages[conversationKey].push(newMessage);

    // Update conversation
    mockConversations[conversationKey] = {
      userId: senderId,
      otherUserId: recipientId,
      lastMessage: newMessage,
      updatedAt: new Date(),
    };

    res.status(201).json(newMessage);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

// Mark message as read
app.put('/api/chat/messages/:messageId/read', (req, res) => {
  try {
    const { messageId } = req.params;

    // Find and update message
    for (const messages of Object.values(mockMessages)) {
      const message = messages.find(m => m.id === messageId);
      if (message) {
        message.state = 'read';
        return res.json({ status: 'Message marked as read' });
      }
    }

    res.status(404).json({ error: 'Message not found' });
  } catch (error) {
    console.error('Error marking message as read:', error);
    res.status(500).json({ error: 'Failed to mark message as read' });
  }
});

app.listen(3003, () => console.log('Chat Service on 3003'));
