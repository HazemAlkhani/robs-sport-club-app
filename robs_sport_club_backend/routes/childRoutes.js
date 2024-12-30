const express = require('express');
const { body, param } = require('express-validator');
const childController = require('../controllers/childController');
const validateRequest = require('../middleware/validateRequest');
const { authenticateUser, isAdmin } = require('../middleware/authMiddleware');
const rateLimiter = require('../middleware/rateLimiter');

// Validation rules
const validateChild = [
  body('ChildName').notEmpty().withMessage('Child name is required.'),
  body('TeamNo').notEmpty().withMessage('Team number is required.'),
  body('SportType').notEmpty().withMessage('Sport type is required.'),
];

const validateChildId = [
  param('id').isInt().withMessage('Child ID must be an integer.'),
];

// Router initialization
const router = express.Router();

// Logging middleware
router.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Routes
// Add a new child
router.post(
  '/add',
  authenticateUser,
  rateLimiter,
  validateChild,
  validateRequest,
  childController.addChild
);

// Fetch all children
router.get(
  '/all',
  authenticateUser,
  rateLimiter,
  childController.getChildren
);

// Fetch children by team and sport
router.get('/by-team-and-sport', authenticateUser, childController.getChildrenByTeamAndSport);

// Update child details
router.put(
  '/update/:id',
  authenticateUser,
  rateLimiter,
  validateChild,
  validateChildId,
  validateRequest,
  childController.updateChild
);

// Delete a child
router.delete(
  '/delete/:id',
  authenticateUser,
  rateLimiter,
  validateChildId,
  validateRequest,
  childController.deleteChild
);

module.exports = router;
