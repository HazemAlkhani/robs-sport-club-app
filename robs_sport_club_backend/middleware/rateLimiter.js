const rateLimit = require('express-rate-limit');

// Define rate limiting rules
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes.',
  },
  headers: true, // Include rate limit info in response headers
  standardHeaders: true, // Enable `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  handler: (req, res, next, options) => {
    res.status(options.statusCode).json({
      success: false,
      message: options.message,
    });
  },
});

// Export the middleware
module.exports = rateLimiter;
