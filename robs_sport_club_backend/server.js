const express = require('express');
require('dotenv').config(); // Load environment variables
const { connectDB, disconnectDB } = require('./db');
const authRoutes = require('./routes/authRoutes'); // Authentication routes
const participationRoutes = require('./routes/participationRoutes'); // Participation routes
const verifyToken = require('./middleware/auth'); // JWT middleware
const cors = require('cors'); // CORS middleware
const helmet = require('helmet'); // Security middleware

const app = express();
app.use(express.json()); // Middleware to parse JSON bodies
app.use(cors()); // Enable CORS
app.use(helmet()); // Add security headers

// Connect to the database
connectDB()
  .then(() => console.log("Connected to database"))
  .catch((err) => {
    console.error("Failed to connect to database:", err.message);
    process.exit(1); // Exit if database connection fails
  });

// Debugging info (avoid exposing secrets in production)
if (process.env.NODE_ENV !== 'production') {
  console.log("Debug mode enabled. Database connection and JWT configuration loaded.");
}

// Root endpoint
app.get('/', (req, res) => {
  res.send('RØBS Sport Club Management API is running');
});

// Set up routes
app.use('/auth', authRoutes); // Unprotected routes
app.use('/participation', verifyToken, participationRoutes); // Protected routes

// Generic error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
});

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
