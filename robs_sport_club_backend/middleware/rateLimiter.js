const rateLimit = require('express-rate-limit');

// Configure the rate limiter
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes in milliseconds
  max: 100, // Maximum number of requests per IP in the windowMs
  message: {
    message: 'Too many requests from this IP, please try again later.',
  },
  headers: true, // Include rate limit info in the response headers
});

// Export the rate limiter middleware
module.exports = rateLimiter;
