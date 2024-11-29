const errorHandler = (err, req, res, next) => {
  console.error(err.stack); // Log the error stack for debugging
  const statusCode = err.status || 500; // Default to internal server error
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({ message });
};

module.exports = errorHandler;
