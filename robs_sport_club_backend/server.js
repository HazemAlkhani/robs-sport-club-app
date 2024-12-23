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

// Connect to the database
connectDB()
  .then(() => console.log('Database connected successfully'))
  .catch((err) => {
    console.error('Database connection failed:', err.message);
    process.exit(1); // Exit if the database connection fails
  });

// Middleware setup
app.use(express.json()); // Parse JSON request bodies
app.use(corsConfig); // CORS setup
app.use(helmet()); // Security headers
app.use(morgan('combined')); // Log requests
app.use(rateLimiter); // Limit request rates
app.use(requestLogger); // Log request details

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'RØBS Sport Club Management API is running',
    version: '1.0.0',
  });
});

// Routes
app.use('/auth', authRoutes);
app.use('/children', childRoutes);
app.use('/users', userRoutes);
app.use('/participation', participationRoutes);

// Error handling middleware
app.use(errorHandler);

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('SIGINT received: Shutting down server...');
  await disconnectDB();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('SIGTERM received: Shutting down server...');
  await disconnectDB();
  process.exit(0);
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
