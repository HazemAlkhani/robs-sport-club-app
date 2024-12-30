require('dotenv').config(); // Load environment variables
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const cors = require('cors');
const rateLimiter = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const { connectDB, disconnectDB } = require('./db');
const authRoutes = require('./routes/authRoutes');
const childRoutes = require('./routes/childRoutes');
const userRoutes = require('./routes/userRoutes');
const participationRoutes = require('./routes/participationRoutes');
const requestLogger = require('./middleware/requestLogger');
const statisticsRouter = require('./routes/statisticsRouter');
const sql = require('./db');

const app = express();

// Validate required environment variables
const requiredVars = ['DB_USER', 'DB_PASSWORD', 'JWT_SECRET', 'PORT'];
requiredVars.forEach((key) => {
  if (!process.env[key]) {
    console.error(`Environment variable ${key} is required but not set.`);
    process.exit(1);
  }
});

// Connect to the database
(async () => {
  try {
    await connectDB();
    console.log('Database connected successfully');
  } catch (err) {
    console.error('Database connection failed:', err.message);
    process.exit(1);
  }
})();

// Middleware setup
app.use(express.json());
app.use(
  cors({
    origin: process.env.CORS_ALLOWED_ORIGINS?.split(',') || '*',
    methods: 'GET,POST,PUT,DELETE',
    allowedHeaders: 'Content-Type,Authorization',
  })
);
app.use(helmet({ contentSecurityPolicy: process.env.NODE_ENV === 'production' ? undefined : false }));
app.use(morgan('combined'));
app.use(rateLimiter);
app.use(requestLogger);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'RØBS Sport Club Management API is running',
    version: '1.0.0',
  });
});

// Log all incoming requests
app.use((req, res, next) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);
  console.log('Request Headers:', req.headers);
  console.log('Request Body:', req.body);
  console.log('Query Params:', req.query);
  next();
});

// Register routes
app.use('/auth', authRoutes);
app.use('/children', childRoutes);
app.use('/users', userRoutes);
app.use('/participations', participationRoutes);
app.use('/statistics', statisticsRouter);

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const pool = await sql.connect();
    await pool.close();
    res.status(200).json({
      status: 'Healthy',
      uptime: process.uptime(),
      timestamp: new Date(),
      database: 'Connected',
      message: 'RØBS Sport Club Management API is running smoothly',
    });
  } catch (error) {
    console.error('Database health check failed:', error.message);
    res.status(500).json({
      status: 'Unhealthy',
      uptime: process.uptime(),
      timestamp: new Date(),
      database: 'Disconnected',
      message: 'Error connecting to the database',
    });
  }
});

// Handle 404 Not Found
app.use((req, res) => {
  res.status(404).json({
    error: `Route ${req.method} ${req.url} not found.`,
  });
});

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown
const gracefulShutdown = async (signal) => {
  console.log(`[${new Date().toISOString()}] ${signal} received: Shutting down server...`);
  try {
    await disconnectDB();
    console.log(`[${new Date().toISOString()}] Database disconnected successfully.`);
    process.exit(0);
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Error during shutdown: ${err.message}`);
    process.exit(1);
  }
};

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

app.disable('x-powered-by'); // Hide Express.js usage from attackers
