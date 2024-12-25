const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  console.log('Verifying token...');
  console.log('Authorization Header:', req.header('Authorization'));

  const authHeader = req.header('Authorization');

  // Check if Authorization header exists and has the Bearer token
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.error('No token provided.');
    return res.status(401).json({ message: 'No token provided.' });
  }

  // Extract the token from the Authorization header
  const token = authHeader.split(' ')[1];

  // Ensure the JWT_SECRET is set in the environment variables
  if (!process.env.JWT_SECRET) {
    console.error('JWT_SECRET is not defined in environment variables.');
    process.exit(1); // Exit the server if the secret is missing
  }

  try {
    // Verify the token and attach the decoded payload to the request object
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    console.log('Token verified successfully:', decoded);
    next(); // Pass control to the next middleware or route handler
  } catch (err) {
    console.error('Token verification failed:', err.message);
    return res.status(401).json({ message: 'Invalid token.' });
  }
};

module.exports = verifyToken;
