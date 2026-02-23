// backend/billing-service/src/middleware/auth.js

function authenticateToken(req, res, next) {
  // This would typically verify JWT from API Gateway
  const userId = req.headers['user-id'];

  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  req.user = { userId };
  next();
}

module.exports = {
  authenticateToken,
};
