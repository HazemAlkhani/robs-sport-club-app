const isDevelopment = process.env.NODE_ENV === 'development';

const errorHandler = (err, req, res, next) => {
  if (res.headersSent) {
    console.error('Headers already sent:', err.message);
    return next(err); // Delegate to default error handler
  }

  console.error('Error:', {
    message: err.message,
    stack: isDevelopment ? err.stack : 'Hidden',
  });

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(isDevelopment && { stack: err.stack }),
  });
};

module.exports = errorHandler;
