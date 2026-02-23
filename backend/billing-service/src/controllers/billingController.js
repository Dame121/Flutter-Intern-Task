// backend/billing-service/src/controllers/billingController.js

const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

const PLATFORM_CUT = 0.20; // 20% platform commission

/**
 * Get user credit balance
 * GET /api/billing/balance
 */
async function getBalance(req, res) {
  try {
    const { userId } = req.user;

    const result = await db.query(
      `SELECT balance, pre_authorized_amount FROM credits WHERE user_id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      // Create initial balance
      await db.query(
        `INSERT INTO credits (user_id, balance) VALUES ($1, 0)`,
        [userId]
      );
      return res.json({ balance: 0, preAuthorizedAmount: 0 });
    }

    const { balance, pre_authorized_amount } = result.rows[0];
    res.json({
      balance: parseFloat(balance),
      preAuthorizedAmount: parseFloat(pre_authorized_amount),
      availableBalance: parseFloat(balance) - parseFloat(pre_authorized_amount),
    });
  } catch (error) {
    console.error('Get balance error:', error);
    res.status(500).json({ message: 'Failed to get balance', error: error.message });
  }
}

/**
 * Purchase credits (mock payment)
 * POST /api/billing/purchase
 */
async function purchaseCredits(req, res) {
  try {
    const { userId } = req.user;
    const { amount, packageName } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Invalid amount' });
    }

    const transactionId = uuidv4();

    // Update balance
    const result = await db.query(
      `UPDATE credits 
       SET balance = balance + $1, updated_at = NOW()
       WHERE user_id = $2
       RETURNING balance`,
      [amount, userId]
    );

    if (result.rows.length === 0) {
      // Create new balance record
      await db.query(
        `INSERT INTO credits (user_id, balance) VALUES ($1, $2)`,
        [userId, amount]
      );
    }

    // Log transaction
    await db.query(
      `INSERT INTO transactions (id, user_id, type, amount, status, created_at)
       VALUES ($1, $2, 'credit_purchase', $3, 'completed', NOW())`,
      [transactionId, userId, amount]
    );

    res.json({
      message: 'Credits purchased successfully',
      transactionId,
      amount,
      packageName,
      newBalance: result.rows[0]?.balance || amount,
    });
  } catch (error) {
    console.error('Purchase credits error:', error);
    res.status(500).json({ message: 'Failed to purchase credits', error: error.message });
  }
}

/**
 * Deduct credits for message
 * POST /api/billing/deduct-message
 */
async function deductMessageCredit(req, res) {
  try {
    const { callerId, hostId, amount, messageId } = req.body;

    if (!callerId || !hostId || !amount) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Check caller balance
    const callerBalance = await db.query(
      `SELECT balance FROM credits WHERE user_id = $1`,
      [callerId]
    );

    if (callerBalance.rows.length === 0 || parseFloat(callerBalance.rows[0].balance) < amount) {
      return res.status(402).json({ message: 'Insufficient balance' });
    }

    const transactionId = uuidv4();

    // Deduct from caller
    await db.query(
      `UPDATE credits SET balance = balance - $1 WHERE user_id = $2`,
      [amount, callerId]
    );

    // Credit to host (after platform cut)
    const hostEarnings = amount * (1 - PLATFORM_CUT);
    const platformCut = amount * PLATFORM_CUT;

    await db.query(
      `INSERT INTO earnings (host_id, amount, caller_id, deduction_type, period, status)
       VALUES ($1, $2, $3, 'message', NOW(), 'pending')`,
      [hostId, hostEarnings, callerId]
    );

    // Log platform revenue
    await db.query(
      `INSERT INTO platform_revenue (amount) VALUES ($1)`,
      [platformCut]
    );

    // Log transaction for caller
    await db.query(
      `INSERT INTO transactions (user_id, type, amount, other_user_id, reference_type, reference_id, status)
       VALUES ($1, 'message_deduction', $2, $3, 'message', $4, 'completed')`,
      [callerId, amount, hostId, messageId]
    );

    res.json({
      message: 'Message deducted successfully',
      transactionId,
      deducted: amount,
      hostEarnings,
    });
  } catch (error) {
    console.error('Deduct message credit error:', error);
    res.status(500).json({ message: 'Failed to deduct credits', error: error.message });
  }
}

/**
 * Pre-authorize credits for call
 * POST /api/billing/pre-authorize
 */
async function preAuthorizeCredits(req, res) {
  try {
    const { callerId, amount, sessionId } = req.body;

    if (!callerId || !amount || !sessionId) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Get caller balance
    const result = await db.query(
      `SELECT balance, pre_authorized_amount FROM credits WHERE user_id = $1`,
      [callerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User credit account not found' });
    }

    const { balance, pre_authorized_amount } = result.rows[0];
    const availableBalance = parseFloat(balance) - parseFloat(pre_authorized_amount);

    if (availableBalance < amount) {
      return res.status(402).json({
        message: 'Insufficient balance',
        requiredAmount: amount,
        availableBalance,
      });
    }

    // Pre-authorize amount
    await db.query(
      `UPDATE credits 
       SET pre_authorized_amount = pre_authorized_amount + $1
       WHERE user_id = $2`,
      [amount, callerId]
    );

    res.json({
      message: 'Credits pre-authorized',
      sessionId,
      preAuthorizedAmount: amount,
      remainingBalance: availableBalance - amount,
    });
  } catch (error) {
    console.error('Pre-authorize error:', error);
    res.status(500).json({ message: 'Pre-authorization failed', error: error.message });
  }
}

/**
 * Release pre-authorized credits
 * POST /api/billing/release-pre-auth
 */
async function releasePreAuth(req, res) {
  try {
    const { callerId, amount, sessionId } = req.body;

    if (!callerId || !amount) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    await db.query(
      `UPDATE credits 
       SET pre_authorized_amount = GREATEST(pre_authorized_amount - $1, 0)
       WHERE user_id = $2`,
      [amount, callerId]
    );

    res.json({
      message: 'Pre-authorized amount released',
      sessionId,
      releasedAmount: amount,
    });
  } catch (error) {
    console.error('Release pre-auth error:', error);
    res.status(500).json({ message: 'Failed to release pre-auth', error: error.message });
  }
}

/**
 * Finalize call billing
 * POST /api/billing/finalize-call
 */
async function finalizeCallBilling(req, res) {
  try {
    const { callerId, hostId, duration, callType, sessionId, preAuthorizedAmount } = req.body;

    if (!callerId || !hostId || !duration || !callType) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Get rates from user service (mocked here)
    const ratePerMinute = callType === 'video' ? 1.0 : 0.5; // Mock rates
    const totalCost = (duration / 60) * ratePerMinute;

    // Deduct from caller
    await db.query(
      `UPDATE credits 
       SET balance = balance - $1,
           pre_authorized_amount = GREATEST(pre_authorized_amount - $2, 0)
       WHERE user_id = $3`,
      [totalCost, preAuthorizedAmount, callerId]
    );

    // Credit to host (after platform cut)
    const hostEarnings = totalCost * (1 - PLATFORM_CUT);
    const platformCut = totalCost * PLATFORM_CUT;

    await db.query(
      `INSERT INTO earnings (host_id, amount, caller_id, deduction_type, period, status)
       VALUES ($1, $2, $3, $4, NOW(), 'completed')`,
      [hostId, hostEarnings, callerId, callType]
    );

    // Log platform revenue
    await db.query(
      `INSERT INTO platform_revenue (amount) VALUES ($1)`,
      [platformCut]
    );

    // Log transaction
    const transactionId = uuidv4();
    await db.query(
      `INSERT INTO transactions (user_id, type, amount, other_user_id, reference_type, reference_id, status)
       VALUES ($1, 'call_deduction', $2, $3, $4, $5, 'completed')`,
      [callerId, totalCost, hostId, callType, sessionId]
    );

    res.json({
      message: 'Call billing finalized',
      transactionId,
      totalCost,
      hostEarnings,
      duration,
      callType,
    });
  } catch (error) {
    console.error('Finalize call error:', error);
    res.status(500).json({ message: 'Failed to finalize call billing', error: error.message });
  }
}

/**
 * Get transaction history
 * GET /api/billing/history
 */
async function getTransactionHistory(req, res) {
  try {
    const { userId } = req.user;

    const result = await db.query(
      `SELECT id, type, amount, other_user_id, created_at
       FROM transactions
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 50`,
      [userId]
    );

    res.json({
      transactions: result.rows.map(tx => ({
        id: tx.id,
        type: tx.type,
        amount: parseFloat(tx.amount),
        otherUserId: tx.other_user_id,
        createdAt: tx.created_at,
      })),
    });
  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({ message: 'Failed to get history', error: error.message });
  }
}

/**
 * Get host earnings
 * GET /api/billing/earnings
 */
async function getEarnings(req, res) {
  try {
    const { userId } = req.user;

    const result = await db.query(
      `SELECT 
        SUM(amount) as total_earnings,
        COUNT(*) as transaction_count
       FROM earnings
       WHERE host_id = $1 AND status = 'completed'`,
      [userId]
    );

    const earnings = result.rows[0];

    res.json({
      totalEarnings: parseFloat(earnings.total_earnings) || 0,
      transactionCount: parseInt(earnings.transaction_count) || 0,
    });
  } catch (error) {
    console.error('Get earnings error:', error);
    res.status(500).json({ message: 'Failed to get earnings', error: error.message });
  }
}

module.exports = {
  getBalance,
  purchaseCredits,
  deductMessageCredit,
  preAuthorizeCredits,
  releasePreAuth,
  finalizeCallBilling,
  getTransactionHistory,
  getEarnings,
};
