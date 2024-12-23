const { validationResult } = require('express-validator');

/**
 * Middleware to validate request data
 * @param {Array} validations - Array of validation rules from express-validator
 * @returns {Function} - Middleware function
 */
const validateRequest = (validations) => async (req, res, next) => {
  // Run all validations
  await Promise.all(validations.map((validation) => validation.run(req)));

  // Gather validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    // Return 400 status with validation error details
    return res.status(400).json({
      success: false,
      errors: errors.array(),
    });
  }

  next(); // Proceed to the next middleware or route handler
};

module.exports = validateRequest;
