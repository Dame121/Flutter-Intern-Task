// backend/auth-service/src/controllers/authController.js

const bcrypt = require('bcryptjs');
const db = require('../config/database');
const jwt = require('../utils/jwt');
const { v4: uuidv4 } = require('uuid');

/**
 * Register a new user
 * POST /api/auth/register
 */
async function register(req, res) {
  try {
    const { email, password, displayName, role } = req.body;

    // Validate input
    if (!email || !password || !displayName || !role) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    if (role !== 'caller' && role !== 'host') {
      return res.status(400).json({ message: 'Invalid role' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const result = await db.query(
      `INSERT INTO users (email, password_hash, display_name, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, display_name, role, created_at`,
      [email, hashedPassword, displayName, role]
    );

    const user = result.rows[0];

    // Generate tokens
    const accessToken = jwt.generateAccessToken(user.id, role);
    const refreshToken = jwt.generateRefreshToken(user.id, uuidv4());

    // Save session
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    await db.query(
      `INSERT INTO sessions (user_id, refresh_token, expires_at)
       VALUES ($1, $2, $3)`,
      [user.id, refreshToken, expiresAt]
    );

    const expiresInMs = 15 * 60 * 1000; // 15 minutes
    const accessTokenExpiresAt = new Date(Date.now() + expiresInMs);

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        role: user.role,
        createdAt: user.created_at,
        isOnline: false,
      },
      token: {
        accessToken,
        refreshToken,
        expiresAt: accessTokenExpiresAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Register error:', error);

    if (error.code === '23505') {
      return res.status(409).json({ message: 'Email already exists' });
    }

    res.status(500).json({ message: 'Registration failed', error: error.message });
  }
}

/**
 * Login user
 * POST /api/auth/login
 */
async function login(req, res) {
  try {
    const { email, password, fcmToken } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password required' });
    }

    // Find user
    const result = await db.query(
      `SELECT id, email, display_name, role, password_hash, created_at
       FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate tokens
    const accessToken = jwt.generateAccessToken(user.id, user.role);
    const sessionId = uuidv4();
    const refreshToken = jwt.generateRefreshToken(user.id, sessionId);

    // Save/update session
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    await db.query(
      `INSERT INTO sessions (user_id, refresh_token, fcm_token, expires_at)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (refresh_token) DO UPDATE SET
       fcm_token = EXCLUDED.fcm_token,
       expires_at = EXCLUDED.expires_at`,
      [user.id, refreshToken, fcmToken || null, expiresAt]
    );

    const expiresInMs = 15 * 60 * 1000; // 15 minutes
    const accessTokenExpiresAt = new Date(Date.now() + expiresInMs);

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        role: user.role,
        createdAt: user.created_at,
        isOnline: true,
      },
      token: {
        accessToken,
        refreshToken,
        expiresAt: accessTokenExpiresAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
}

/**
 * Refresh access token
 * POST /api/auth/refresh
 */
async function refreshToken(req, res) {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ message: 'Refresh token required' });
    }

    // Verify refresh token
    const decoded = jwt.verifyRefreshToken(refreshToken);
    if (!decoded) {
      return res.status(401).json({ message: 'Invalid refresh token' });
    }

    // Check if session exists and not expired
    const sessionResult = await db.query(
      `SELECT user_id, expires_at FROM sessions 
       WHERE refresh_token = $1 AND expires_at > NOW()`,
      [refreshToken]
    );

    if (sessionResult.rows.length === 0) {
      return res.status(401).json({ message: 'Session expired' });
    }

    const session = sessionResult.rows[0];

    // Get user role
    const userResult = await db.query(
      `SELECT role FROM users WHERE id = $1`,
      [session.user_id]
    );

    const user = userResult.rows[0];

    // Generate new access token
    const newAccessToken = jwt.generateAccessToken(session.user_id, user.role);
    const expiresInMs = 15 * 60 * 1000; // 15 minutes
    const accessTokenExpiresAt = new Date(Date.now() + expiresInMs);

    res.json({
      message: 'Token refreshed successfully',
      token: {
        accessToken: newAccessToken,
        refreshToken, // Return same refresh token
        expiresAt: accessTokenExpiresAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({ message: 'Token refresh failed', error: error.message });
  }
}

/**
 * Logout user
 * POST /api/auth/logout
 */
async function logout(req, res) {
  try {
    const { userId } = req.user; // From middleware

    // Invalidate all sessions for user
    await db.query(
      `DELETE FROM sessions WHERE user_id = $1`,
      [userId]
    );

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ message: 'Logout failed', error: error.message });
  }
}

module.exports = {
  register,
  login,
  refreshToken,
  logout,
};
