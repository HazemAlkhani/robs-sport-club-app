const sql = require('mssql');

// Validate required environment variables
['DB_USER', 'DB_PASSWORD', 'DB_SERVER', 'DB_NAME'].forEach((key) => {
  if (!process.env[key]) {
    console.error(`Missing environment variable: ${key}`);
    process.exit(1);
  }
});

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: true, // Use encryption for secure connections
    trustServerCertificate: true, // Bypass certificate validation if self-signed
    enableArithAbort: true, // Ensures compatibility with older SQL Server drivers
  },
  pool: {
    max: parseInt(process.env.DB_POOL_MAX || '10'), // Maximum number of connections
    min: parseInt(process.env.DB_POOL_MIN || '0'), // Minimum number of connections
    idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'), // Connection idle timeout
  },
  connectTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT || '15000'), // Connection timeout
};

let connectionPool = null;
let retryAttempts = 0;
const MAX_RETRIES = 5;

// Connect to the database
const connectDB = async () => {
  try {
    if (!connectionPool || !connectionPool.connected) {
      console.log('Attempting to connect to the database...');
      connectionPool = await sql.connect(config);
      console.log('Database connected successfully');
      retryAttempts = 0; // Reset retry attempts on successful connection
    }
    return connectionPool;
  } catch (err) {
    retryAttempts++;
    console.error(`Database connection failed (attempt ${retryAttempts}):`, err.message);
    if (retryAttempts < MAX_RETRIES) {
      console.log(`Retrying connection in 5 seconds...`);
      setTimeout(connectDB, 5000); // Retry connection after 5 seconds
    } else {
      console.error('Max retries reached. Please check your database configuration.');
      throw err;
    }
  }
};

// Disconnect from the database
const disconnectDB = async () => {
  try {
    if (connectionPool) {
      await connectionPool.close();
      console.log('Database connection closed');
      connectionPool = null;
    }
  } catch (err) {
    console.error('Failed to close the database connection:', err.message);
  }
};

// Health check for the database
const healthCheck = async () => {
  try {
    if (connectionPool) {
      await connectionPool.query('SELECT 1');
      console.log('Database connection is healthy');
    } else {
      console.warn('No active database connection');
    }
  } catch (err) {
    console.error('Database health check failed:', err.message);
  }
};

// Query helper
const query = async (queryText, params = {}) => {
  try {
    const pool = await connectDB();
    const request = pool.request();

    // Add parameters dynamically
    for (const [key, value] of Object.entries(params)) {
      request.input(key, value);
    }

    console.log('Executing query:', queryText); // Optional: Log queries for debugging
    return await request.query(queryText);
  } catch (err) {
    console.error('Query execution failed:', err.message);
    throw err; // Re-throw error for further handling
  }
};

// Graceful shutdown on SIGINT (e.g., Ctrl+C)
process.on('SIGINT', async () => {
  try {
    await disconnectDB();
    console.log('Application shutting down gracefully...');
  } catch (err) {
    console.error('Error during shutdown:', err.message);
  } finally {
    process.exit(0);
  }
});

module.exports = { connectDB, disconnectDB, healthCheck, query, sql };
