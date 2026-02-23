// backend/user-service/src/routes/userRoutes.js

const express = require('express');
const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Protected routes
router.get('/profile', authenticateToken, userController.getProfile);
router.post('/profile', authenticateToken, userController.updateProfile);
router.put('/status', authenticateToken, userController.updateStatus);

// Public route
router.get('/host/:id', userController.getHostProfile);

module.exports = router;
