const jwt = require('jsonwebtoken');

// Extract Bearer token from Authorization header
const extractBearerToken = (authHeader) => {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  return authHeader.split(' ')[1];
};

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = extractBearerToken(req.header('Authorization'));
  if (!token) {
    return res.status(401).json({ message: 'Access denied. No token provided or malformed token.' });
  }

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified; // Attach decoded token payload to the request object
    next(); // Proceed to the next middleware or route handler
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token has expired. Please log in again.' });
    }
    res.status(401).json({ message: 'Access denied. Invalid token.' });
  }
};

module.exports = verifyToken;
