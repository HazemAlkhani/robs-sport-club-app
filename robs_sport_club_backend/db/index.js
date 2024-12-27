const sql = require('mssql');
require('dotenv').config(); // Load environment variables

// Database configuration
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: false, // Adjust if necessary
    trustServerCertificate: true, // For local dev
  },
  pool: {
    max: parseInt(process.env.DB_POOL_MAX, 10) || 10,
    min: parseInt(process.env.DB_POOL_MIN, 10) || 0,
    idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT, 10) || 30000,
  },
  connectionTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT, 10) || 15000,
};

// Debugging the configuration
console.log('Database Configuration:', dbConfig);

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

module.exports = {
  connectDB,
  disconnectDB,
  sql,
};
