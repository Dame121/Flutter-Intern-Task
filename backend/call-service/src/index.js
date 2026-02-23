// backend/call-service/src/index.js

require('dotenv').config();
const express = require('express');
const { createClient } = require('redis');

const app = express();
app.use(express.json());

const redisClient = createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });

// Generate UUID if not available
const generateId = () => Math.random().toString(36).substring(2) + Date.now().toString(36);

// Redis connection
redisClient.on('error', (err) => console.log('Redis Client Error', err));

// Call session structure
const CALL_SESSION_PREFIX = 'call:';
const CALL_TIMEOUT = 30 * 1000; // 30 seconds timeout

/**
 * Initiate a call
 * POST /api/calls/initiate
 */
app.post('/api/calls/initiate', async (req, res) => {
  try {
    const { callerId, hostId, callType } = req.body; // callType: 'audio' or 'video'

    if (!callerId || !hostId || !callType) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const sessionId = generateId();
    const session = {
      sessionId,
      callerId,
      hostId,
      callType,
      state: 'initiated', // initiated -> ringing -> active -> ended
      startedAt: new Date().toISOString(),
      connectedAt: null,
      endedAt: null,
    };

    // Store in Redis with TTL
    await redisClient.setEx(
      `${CALL_SESSION_PREFIX}${sessionId}`,
      60, // 60 second TTL
      JSON.stringify(session)
    );

    res.json({
      sessionId,
      state: 'initiated',
      message: 'Call session created, waiting for host response',
    });
  } catch (error) {
    console.error('Initiate call error:', error);
    res.status(500).json({ message: 'Failed to initiate call', error: error.message });
  }
});

/**
 * Respond to call
 * POST /api/calls/respond
 */
app.post('/api/calls/respond', async (req, res) => {
  try {
    const { sessionId, response } = req.body; // response: 'accepted' or 'declined'

    if (!sessionId || !response) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const sessionKey = `${CALL_SESSION_PREFIX}${sessionId}`;
    const sessionData = await redisClient.get(sessionKey);

    if (!sessionData) {
      return res.status(404).json({ message: 'Session not found' });
    }

    const session = JSON.parse(sessionData);

    if (response === 'accepted') {
      session.state = 'active';
      session.connectedAt = new Date().toISOString();
    } else if (response === 'declined') {
      session.state = 'ended';
      session.endedAt = new Date().toISOString();
    }

    await redisClient.setEx(sessionKey, 3600, JSON.stringify(session)); // 1 hour TTL for active calls

    res.json({
      sessionId,
      state: session.state,
      message: `Call ${response}`,
    });
  } catch (error) {
    console.error('Respond call error:', error);
    res.status(500).json({ message: 'Failed to respond to call', error: error.message });
  }
});

/**
 * Get RTC token from Agora
 * POST /api/calls/rtc-token
 */
app.post('/api/calls/rtc-token', async (req, res) => {
  try {
    const { sessionId } = req.body;

    if (!sessionId) {
      return res.status(400).json({ message: 'Session ID required' });
    }

    // Generate mock Agora token (real implementation needs Agora SDK)
    const mockToken = `agora_token_${sessionId}`;

    res.json({
      sessionId,
      rtcToken: mockToken,
      agoraAppId: process.env.AGORA_APP_ID || 'mock_app_id',
      channel: `call_${sessionId}`,
      uid: 0, // Will be assigned by client
    });
  } catch (error) {
    console.error('Get RTC token error:', error);
    res.status(500).json({ message: 'Failed to generate token', error: error.message });
  }
});

/**
 * End call
 * POST /api/calls/end
 */
app.post('/api/calls/end', async (req, res) => {
  try {
    const { sessionId } = req.body;

    if (!sessionId) {
      return res.status(400).json({ message: 'Session ID required' });
    }

    const sessionKey = `${CALL_SESSION_PREFIX}${sessionId}`;
    const sessionData = await redisClient.get(sessionKey);

    if (!sessionData) {
      return res.status(404).json({ message: 'Session not found' });
    }

    const session = JSON.parse(sessionData);
    session.state = 'ended';
    session.endedAt = new Date().toISOString();

    await redisClient.setEx(sessionKey, 3600, JSON.stringify(session));

    res.json({
      sessionId,
      state: 'ended',
      message: 'Call ended',
    });
  } catch (error) {
    console.error('End call error:', error);
    res.status(500).json({ message: 'Failed to end call', error: error.message });
  }
});

/**
 * Get session status
 * GET /api/calls/session/:sessionId
 */
app.get('/api/calls/session/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;

    const sessionKey = `${CALL_SESSION_PREFIX}${sessionId}`;
    const sessionData = await redisClient.get(sessionKey);

    if (!sessionData) {
      return res.status(404).json({ message: 'Session not found' });
    }

    const session = JSON.parse(sessionData);
    res.json(session);
  } catch (error) {
    console.error('Get session error:', error);
    res.status(500).json({ message: 'Failed to get session', error: error.message });
  }
});

app.get('/health', (req, res) => res.json({ status: 'Call Service OK' }));

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
  console.log(`Call Service running on port ${PORT}`);
});
