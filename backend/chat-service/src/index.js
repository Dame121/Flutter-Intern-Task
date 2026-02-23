// backend/chat-service/src/index.js
require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'Chat Service OK' }));
app.post('/api/chat/messages', (req, res) => {
  res.json({ id: '1', message: 'Message sent', timestamp: new Date() });
});
app.get('/api/chat/messages/:hostId', (req, res) => {
  res.json({ messages: [] });
});
app.listen(3003, () => console.log('Chat Service on 3003'));
