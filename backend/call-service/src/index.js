// backend/call-service/src/index.js
require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'Call Service OK' }));
app.post('/api/calls/initiate', (req, res) => {
  res.json({ sessionId: 'session-1', status: 'initiated' });
});
app.post('/api/calls/respond', (req, res) => {
  res.json({ sessionId: 'session-1', status: 'responding' });
});
app.get('/api/calls/rtc-token', (req, res) => {
  res.json({ token: 'mock-agora-token' });
});
app.listen(3004, () => console.log('Call Service on 3004'));
