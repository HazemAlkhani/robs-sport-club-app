const { validationResult } = require('express-validator');

/**
 * Middleware to validate incoming request data
 * Ensures that all validation rules defined in routes are checked
 */
const validateRequest = (req, res, next) => {
  // Collect validation errors
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    console.error('Validation errors:', errors.array()); // Log validation errors for debugging
    return res.status(400).json({
      success: false,
      message: 'Invalid request data',
      errors: errors.array().map((error) => ({
        field: error.param,
        message: error.msg,
      })), // Format errors for better readability
    });
  }

  next(); // Proceed to the next middleware or route handler if validation passes
};

module.exports = validateRequest;
