const jwt = require('jsonwebtoken');

/**
 * Middleware to authenticate user based on JWT token
 */
const authenticateUser = (req, res, next) => {
    const authHeader = req.header('Authorization');

    // Check for Authorization header
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        console.error('Missing or invalid Authorization header');
        return res.status(401).json({ message: 'Authentication required' });
    }

    // Extract the token from the Authorization header
    const token = authHeader.split(' ')[1];

    if (!process.env.JWT_SECRET) {
        console.error('JWT_SECRET is missing in environment variables');
        return res.status(500).json({ message: 'Server misconfiguration. Please contact support.' });
    }

    try {
        // Verify the token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (process.env.NODE_ENV === 'development') {
            console.log(`Decoded JWT: ${JSON.stringify(decoded)}`);
        }
        req.user = decoded; // Attach user information to the request
        next(); // Proceed to the next middleware or route handler
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            console.error('JWT verification failed: Token has expired');
            return res.status(401).json({ message: 'Token expired. Please login again.' });
        } else if (error.name === 'JsonWebTokenError') {
            console.error('JWT verification failed: Invalid token');
            return res.status(401).json({ message: 'Invalid token. Please login again.' });
        } else {
            console.error('JWT verification failed:', error.message); // General error log
            return res.status(401).json({ message: 'Authentication failed. Please login again.' });
        }
    }
};

/**
 * Middleware to check if the authenticated user is an admin
 */
const isAdmin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next(); // User is an admin, proceed
    } else {
        console.error('Access denied: User is not an admin');
        return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
    }
};

module.exports = { authenticateUser, isAdmin };
