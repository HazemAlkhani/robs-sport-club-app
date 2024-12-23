// Centralized error-handling middleware
const errorHandler = (err, req, res, next) => {
  console.error(`[Error] ${err.stack}`); // Log the error stack for debugging

  const statusCode = err.status || 500; // Use provided status or default to 500
  const message = err.message || 'Internal Server Error'; // Use provided message or default

  res.status(statusCode).json({
    success: false,
    message,
    // Optionally include the stack trace in development for debugging
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
