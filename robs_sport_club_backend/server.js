const express = require('express');
require('dotenv').config(); // Load environment variables
const { connectDB, disconnectDB } = require('./db');
const authRoutes = require('./routes/authRoutes'); // Authentication routes
const participationRoutes = require('./routes/participationRoutes'); // Participation routes
const verifyToken = require('./middleware/auth'); // JWT middleware
const cors = require('cors'); // CORS middleware
const corsConfig = require('./middleware/corsConfig'); // Enhanced CORS configuration
const helmet = require('helmet'); // Security middleware
const rateLimiter = require('./middleware/rateLimiter'); // Rate limiter middleware
const errorHandler = require('./middleware/errorHandler'); // Error handler middleware
const requestLogger = require('./middleware/requestLogger'); // Request logger middleware
const { sql } = require('./db'); // For health check DB queries

const app = express();

// Middleware setup
app.use(express.json()); // Parse JSON request bodies
app.use(cors(corsConfig)); // Use enhanced CORS configuration
app.use(helmet()); // Add security headers
app.use(rateLimiter); // Apply rate limiting
app.use(requestLogger); // Log all incoming requests

// Connect to the database
connectDB()
  .then(() => console.log('Connected to database'))
  .catch((err) => {
    console.error('Failed to connect to database:', err.message);
    process.exit(1); // Exit if database connection fails
  });

// Debugging info (avoid exposing secrets in production)
if (process.env.NODE_ENV !== 'production') {
  console.log('Debug mode enabled. Database connection and JWT configuration loaded.');
}

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'RØBS Sport Club Management API is running',
    version: '1.0.0',
    health: 'healthy',
  });
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await sql.query('SELECT 1'); // Example query to test DB connection
    res.status(200).json({ status: 'healthy' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', error: err.message });
  }
});

// Set up routes
app.use('/auth', authRoutes); // Unprotected routes
app.use('/participation', verifyToken, participationRoutes); // Protected routes

// Generic error handler middleware
app.use(errorHandler);

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down server...');
  await disconnectDB();
  process.exit(0);
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
