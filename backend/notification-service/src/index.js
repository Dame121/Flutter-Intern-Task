// backend/notification-service/src/index.js
require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'Notification Service OK' }));
app.post('/api/notifications/register-token', (req, res) => {
  res.json({ message: 'Token registered' });
});
app.listen(3006, () => console.log('Notification Service on 3006'));
