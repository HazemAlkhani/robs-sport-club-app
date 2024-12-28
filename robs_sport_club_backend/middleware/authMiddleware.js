const jwt = require('jsonwebtoken');

const authenticateUser = (req, res, next) => {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        console.error('Missing or invalid Authorization header');
        return res.status(401).json({ message: 'Authentication required' });
    }

    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log('Decoded JWT:', decoded); // Debug log
        req.user = decoded; // Attach user info to request
        next();
    } catch (error) {
        console.error('JWT verification failed:', error.message); // Debug log
        res.status(401).json({ message: 'Invalid or expired token' });
    }
};

module.exports = { authenticateUser };
