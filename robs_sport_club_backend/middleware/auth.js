const jwt = require('jsonwebtoken');

/**
 * Extract Bearer token from the Authorization header
 * @param {string} authHeader - The Authorization header
 * @returns {string|null} - Extracted token or null if invalid
 */
const extractBearerToken = (authHeader) => {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  return authHeader.split(' ')[1];
};

/**
 * Middleware to verify JWT token
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const verifyToken = (req, res, next) => {
  const authHeader = req.header('Authorization');
  const token = extractBearerToken(authHeader);

  if (!token) {
    return res.status(401).json({
      message: 'Access denied. No token provided or malformed token.',
    });
  }

  try {
    // Verify the token using the secret key
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified; // Attach decoded token payload to the request object

    console.log('Token verified successfully:', verified); // Debugging purpose

    next(); // Pass control to the next middleware or route handler
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        message: 'Token has expired. Please log in again.',
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        message: 'Access denied. Invalid token.',
      });
    }

    console.error('Token verification error:', error); // Log unexpected errors
    return res.status(500).json({
      message: 'An unexpected error occurred during token verification.',
    });
  }
};

module.exports = verifyToken;
