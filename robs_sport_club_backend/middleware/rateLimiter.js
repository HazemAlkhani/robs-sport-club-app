const rateLimit = require('express-rate-limit');

// Configure the rate limiter
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Maximum number of requests per IP within the window
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
  },
  headers: true, // Include rate limit info in the response headers
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Export the rate limiter middleware
module.exports = rateLimiter;
