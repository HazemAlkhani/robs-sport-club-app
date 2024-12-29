const rateLimit = require('express-rate-limit');

// Define rate limiting rules
const rateLimiter = rateLimit({
  windowMs: process.env.RATE_LIMIT_WINDOW || 15 * 60 * 1000, // 15 minutes
  max: process.env.RATE_LIMIT_MAX || 100, // Limit each IP to 100 requests
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes.',
  },
  headers: true, // Include rate limit info in response headers
  standardHeaders: true, // Enable `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  statusCode: 429, // Explicitly set status code for rate-limiting
  handler: (req, res, next, options) => {
    console.error(`Rate limit exceeded by IP: ${req.ip}`);
    res.status(options.statusCode).json({
      success: false,
      message: options.message,
    });
  },
});

module.exports = rateLimiter;
