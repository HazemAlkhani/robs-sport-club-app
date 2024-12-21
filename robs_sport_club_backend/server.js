require('dotenv').config(); // Load environment variables
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan'); // Enhanced request logging
const rateLimiter = require('./middleware/rateLimiter');
const errorHandler = require('./middleware/errorHandler');
const corsConfig = require('./middleware/corsConfig');
const { connectDB, disconnectDB, sql } = require('./db');
const authRoutes = require('./routes/authRoutes');
const participationRoutes = require('./routes/participationRoutes');
const verifyToken = require('./middleware/auth');

const app = express();

// Middleware setup
app.use(express.json());
app.use(corsConfig); // CORS middleware
app.use(helmet()); // Security headers
app.use(morgan('combined')); // Request logging
app.use(rateLimiter); // Rate limiting

// Connect to database
connectDB()
  .then(() => console.log('Database connected successfully'))
  .catch((err) => {
    console.error('Failed to connect to database:', err.message);
    process.exit(1);
  });

console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode`);

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
    await sql.query('SELECT 1');
    res.status(200).json({ status: 'healthy' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', error: err.message });
  }
});

// Routes
app.use('/auth', authRoutes);
app.use('/participation', verifyToken, participationRoutes);

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down server...');
  await disconnectDB();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down server due to SIGTERM...');
  await disconnectDB();
  process.exit(0);
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
