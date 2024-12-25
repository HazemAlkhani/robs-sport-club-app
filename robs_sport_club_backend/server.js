require('dotenv').config(); // Load environment variables
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimiter = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const corsConfig = require('./middleware/corsConfig');
const { connectDB, disconnectDB } = require('./db');
const authRoutes = require('./routes/authRoutes');
const childRoutes = require('./routes/childRoutes');
const userRoutes = require('./routes/userRoutes');
const participationRoutes = require('./routes/participationRoutes');
const requestLogger = require('./middleware/requestLogger');

const app = express();

// Validate required environment variables
const requiredVars = ['DB_USER', 'DB_PASSWORD', 'JWT_SECRET'];
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
app.use(express.json()); // Parse JSON request bodies
app.use(corsConfig); // Enable CORS
app.use(helmet()); // Set security headers
app.use(morgan('combined')); // Log HTTP requests
app.use(rateLimiter); // Protect against rate-based attacks
app.use(requestLogger); // Log request details for debugging

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
  console.log('Request Body:', req.body);
  next();
});


// Register routes
app.use('/auth', authRoutes);
app.use('/children', childRoutes);
app.use('/users', userRoutes);
app.use('/participation', participationRoutes);

// Handle errors
app.use(errorHandler);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'Healthy',
    uptime: process.uptime(),
    timestamp: new Date(),
    message: 'RØBS Sport Club Management API is running smoothly',
  });
});


// Graceful shutdown
const gracefulShutdown = async (signal) => {
  console.log(`${signal} received: Shutting down server...`);
  try {
    await disconnectDB();
    console.log('Database disconnected successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err.message);
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