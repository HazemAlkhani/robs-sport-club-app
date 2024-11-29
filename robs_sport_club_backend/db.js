const sql = require('mssql');

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: true,
    trustServerCertificate: true,
    enableArithAbort: true,
  },
  pool: {
    max: parseInt(process.env.DB_POOL_MAX || '10'),
    min: parseInt(process.env.DB_POOL_MIN || '0'),
    idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'),
  },
  connectTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT || '15000'), // Move this here
};


let connectionPool;

const connectDB = async () => {
  try {
    if (!connectionPool) {
      console.log('Attempting to connect to the database...');
      connectionPool = await sql.connect(config);
      console.log('Database connected successfully');
    }
    return connectionPool;
  } catch (err) {
    console.error('Database connection failed:', {
      message: err.message,
      code: err.code,
      stack: err.stack,
    });
    throw err;
  }
};

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

process.on('SIGINT', async () => {
  await disconnectDB();
  console.log('Application shutting down...');
  process.exit(0);
});

module.exports = { connectDB, disconnectDB, sql, healthCheck };
