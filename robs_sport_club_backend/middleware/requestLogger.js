const requestLogger = (req, res, next) => {
  const { method, url } = req; // Extract method and URL
  const timestamp = new Date().toISOString(); // Get the current timestamp

  console.log(`[${timestamp}] ${method} ${url}`); // Log the request details

  next(); // Pass control to the next middleware or route handler
};

module.exports = requestLogger;
