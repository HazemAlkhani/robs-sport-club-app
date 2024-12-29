const sql = require('mssql');
require('dotenv').config(); // Load environment variables

// Database configuration
const dbConfig = {
  user: process.env.DB_USER || 'defaultUser',
  password: process.env.DB_PASSWORD || 'defaultPassword',
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'defaultDB',
  options: {
    encrypt: process.env.NODE_ENV === 'production', // Encrypt in production
    trustServerCertificate: process.env.NODE_ENV !== 'production', // Trust for dev
  },
  pool: {
    max: parseInt(process.env.DB_POOL_MAX, 10) || 10,
    min: parseInt(process.env.DB_POOL_MIN, 10) || 0,
    idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT, 10) || 30000,
  },
  connectionTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT, 10) || 15000,
};

// Secure Debugging
const secureConfig = { ...dbConfig, password: '********' };
console.log('Database Configuration:', secureConfig);

// Function to connect to the database
const connectDB = async () => {
  try {
    await sql.connect(dbConfig);
    console.log('Database connected successfully');
  } catch (error) {
    console.error('Database connection failed:', error.message);
    throw new Error(error.message);
  }
};

// Function to disconnect from the database
const disconnectDB = async () => {
  try {
    await sql.close();
    console.log('Database disconnected successfully');
  } catch (error) {
    console.error('Error disconnecting from the database:', error.message);
  }
};

// Function to check database connection
const checkDatabaseConnection = async () => {
  try {
    const pool = await sql.connect(dbConfig);
    await pool.close(); // Test and close immediately
    return true;
  } catch {
    return false;
  }
};

module.exports = {
  connectDB,
  disconnectDB,
  checkDatabaseConnection,
  sql,
};
