// backend/billing-service/src/routes/billingRoutes.js

const express = require('express');
const billingController = require('../controllers/billingController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Protected routes
router.get('/balance', authenticateToken, billingController.getBalance);
router.post('/purchase', authenticateToken, billingController.purchaseCredits);
router.post('/deduct-message', billingController.deductMessageCredit);
router.post('/pre-authorize', billingController.preAuthorizeCredits);
router.post('/release-pre-auth', billingController.releasePreAuth);
router.post('/finalize-call', billingController.finalizeCallBilling);
router.get('/history', authenticateToken, billingController.getTransactionHistory);
router.get('/earnings', authenticateToken, billingController.getEarnings);

module.exports = router;
