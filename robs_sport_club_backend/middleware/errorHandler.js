const errorHandler = (err, req, res, next) => {
  console.error('Error:', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : 'Hidden',
  });

  // Set default status code and message
  let statusCode = err.status || 500;
  let message = err.message || 'Internal Server Error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400; // Bad Request
    message = 'Validation Error: ' + Object.values(err.errors).map(val => val.message).join(', ');
  } else if (err.name === 'CastError') {
    statusCode = 400; // Bad Request
    message = `Invalid ${err.path}: ${err.value}`;
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401; // Unauthorized
    message = 'Unauthorized Access';
  }

  // Handle CORS errors
  if (err.message === 'Not allowed by CORS') {
    statusCode = 403; // Forbidden
  }

  // Send JSON response
  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }), // Include stack in development mode
  });
};

module.exports = errorHandler;
