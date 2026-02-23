// backend/api-gateway/src/index.js

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.env.PORT || 8000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Service URLs
const SERVICES = {
  auth: process.env.AUTH_SERVICE_URL || 'http://auth-service:3000',
  user: process.env.USER_SERVICE_URL || 'http://user-service:3001',
  discovery: process.env.DISCOVERY_SERVICE_URL || 'http://discovery-service:3002',
  chat: process.env.CHAT_SERVICE_URL || 'http://chat-service:3003',
  call: process.env.CALL_SERVICE_URL || 'http://call-service:3004',
  billing: process.env.BILLING_SERVICE_URL || 'http://billing-service:3005',
  notification: process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:3006',
};

// Middleware
app.use(express.json());
app.use(cors());

// JWT verification middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  // Some routes don't require auth
  const publicRoutes = [
    '/api/auth/register',
    '/api/auth/login',
    '/api/auth/refresh',
  ];

  if (publicRoutes.some(route => req.path.startsWith(route))) {
    return next();
  }

  if (!token) {
    return res.status(401).json({ message: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    
    // Add user info to headers for upstream services
    req.headers['user-id'] = decoded.userId;
    req.headers['user-role'] = decoded.role;
    
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

app.use(authenticateToken);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'API Gateway OK' });
});

// Auth Service proxy
app.use('/api/auth', createProxyMiddleware({
  target: SERVICES.auth,
  changeOrigin: true,
  pathRewrite: { '^/api/auth': '/api/auth' },
}));

// User Service proxy
app.use('/api/users', createProxyMiddleware({
  target: SERVICES.user,
  changeOrigin: true,
  pathRewrite: { '^/api/users': '/api/users' },
}));

// Discovery Service proxy
app.use('/api/discovery', createProxyMiddleware({
  target: SERVICES.discovery,
  changeOrigin: true,
  pathRewrite: { '^/api/discovery': '/api/discovery' },
}));

// Chat Service proxy
app.use('/api/chat', createProxyMiddleware({
  target: SERVICES.chat,
  changeOrigin: true,
  pathRewrite: { '^/api/chat': '/api/chat' },
}));

// Call Service proxy
app.use('/api/calls', createProxyMiddleware({
  target: SERVICES.call,
  changeOrigin: true,
  pathRewrite: { '^/api/calls': '/api/calls' },
}));

// Billing Service proxy
app.use('/api/billing', createProxyMiddleware({
  target: SERVICES.billing,
  changeOrigin: true,
  pathRewrite: { '^/api/billing': '/api/billing' },
}));

// Notification Service proxy
app.use('/api/notifications', createProxyMiddleware({
  target: SERVICES.notification,
  changeOrigin: true,
  pathRewrite: { '^/api/notifications': '/api/notifications' },
}));

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint not found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
  console.log('Service URLs:');
  Object.entries(SERVICES).forEach(([name, url]) => {
    console.log(`  ${name}: ${url}`);
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});
