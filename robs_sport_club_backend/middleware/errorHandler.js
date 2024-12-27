const errorHandler = (err, req, res, next) => {
  if (res.headersSent) {
    console.error('Headers already sent:', err.message);
    return next(err); // Delegate to default error handler
  }
  console.error('Error:', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : 'Hidden',
  });

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
