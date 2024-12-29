// Middleware to check if the user is an admin
exports.isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Admins only.',
    });
  }
  next(); // Proceed to the next middleware or route handler
};

// Middleware to check for a specific role
exports.hasRole = (requiredRole) => {
  return (req, res, next) => {
    if (!req.user || req.user.role !== requiredRole) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Only ${requiredRole}s are allowed.`,
      });
    }
    next();
  };
};
