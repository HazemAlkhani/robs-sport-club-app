const jwt = require('jsonwebtoken');

/**
 * Extract Bearer token from the Authorization header
 * @param {string} authHeader - The Authorization header
 * @returns {string|null} - Extracted token or null if invalid
 */
const extractBearerToken = (authHeader) => {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  return authHeader.split(' ')[1];
};

/**
 * Middleware to verify JWT token
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const verifyToken = (req, res, next) => {
  const token = extractBearerToken(req.header('Authorization')); // Extract token from header
  if (!token) {
    return res.status(401).json({ message: 'Access denied. No token provided or malformed token.' });
  }

  try {
    // Verify token and attach decoded payload to request object
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified; // Add `user` property to request
    next(); // Proceed to next middleware or route handler
  } catch (error) {
    // Handle token verification errors
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token has expired. Please log in again.' });
    }
    res.status(401).json({ message: 'Access denied. Invalid token.' });
  }
};

module.exports = verifyToken;
