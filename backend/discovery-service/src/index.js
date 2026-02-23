// backend/discovery-service/src/index.js
require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());
app.get('/health', (req, res) => res.json({ status: 'Discovery Service OK' }));
app.get('/api/discovery/hosts', (req, res) => {
  res.json({
    hosts: [
      {
        id: '1',
        displayName: 'John Host',
        audioCallRate: 0.5,
        videoCallRate: 1.0,
        messageRate: 0.1,
        status: 'online',
      },
    ],
  });
});

app.listen(3002, () => console.log('Discovery Service on 3002'));
