const { sql } = require('../db');
require('dotenv').config(); // Ensure environment variables are loaded

// Database configuration (same as in db/index.js)
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: false, // Set to true if you're using Azure or need encryption
    trustServerCertificate: true, // For local development, allow self-signed certificates
  },
  pool: {
    max: parseInt(process.env.DB_POOL_MAX) || 10,
    min: parseInt(process.env.DB_POOL_MIN) || 0,
    idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT) || 30000,
  },
  connectionTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT) || 15000,
};

// Test database connection
const testDB = async () => {
  try {
    console.log('Database Configuration:', dbConfig); // Debugging configuration
    await sql.connect(dbConfig); // Use the dbConfig
    const result = await sql.query('SELECT 1 AS Test');
    console.log('Database test successful:', result.recordset);
  } catch (error) {
    console.error('Database connection failed:', error.message);
  } finally {
    await sql.close();
    console.log('Database connection closed.');
  }
};

testDB();
