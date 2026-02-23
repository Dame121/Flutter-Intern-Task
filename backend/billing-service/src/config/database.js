// backend/billing-service/src/config/database.js

const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'billing_service',
});

async function initDatabase() {
  try {
    // Create credits/balance table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS credits (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL UNIQUE,
        balance DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
        pre_authorized_amount DECIMAL(10, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create transactions table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        type VARCHAR(50) NOT NULL CHECK (type IN ('credit_purchase', 'call_deduction', 'message_deduction', 'refund')),
        amount DECIMAL(10, 2) NOT NULL,
        session_id UUID,
        other_user_id UUID,
        reference_type VARCHAR(50),
        reference_id VARCHAR(255),
        status VARCHAR(50) DEFAULT 'completed',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES credits(user_id)
      );
    `);

    // Create earnings table for hosts
    await pool.query(`
      CREATE TABLE IF NOT EXISTS earnings (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        host_id UUID NOT NULL,
        amount DECIMAL(10, 2) NOT NULL,
        session_id UUID,
        caller_id UUID,
        deduction_type VARCHAR(50) NOT NULL CHECK (deduction_type IN ('audio', 'video', 'message')),
        period TIMESTAMP NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create platform revenue table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS platform_revenue (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        amount DECIMAL(10, 2) NOT NULL,
        from_earnings_id UUID,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
    throw error;
  }
}

module.exports = {
  pool,
  initDatabase,
  query: (text, params) => pool.query(text, params),
};
