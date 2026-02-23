// backend/user-service/src/middleware/auth.js

function authenticateToken(req, res, next) {
  // This would typically verify JWT from API Gateway
  // For now, we'll expect userId and role in headers
  const userId = req.headers['user-id'];
  const role = req.headers['user-role'];

  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  req.user = { userId, role };
  next();
}

module.exports = {
  authenticateToken,
};
