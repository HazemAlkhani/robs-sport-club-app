const express = require('express');
const { body, param } = require('express-validator');
const childController = require('../controllers/childController');
const validateRequest = require('../middleware/validateRequest');
const authenticateUser = require('../middleware/auth');
const rateLimiter = require('../middleware/rateLimiter');

// Validation rules for child operations
const validateChild = [
  body('ChildName').notEmpty().withMessage('Child name is required'),
  body('TeamNo').notEmpty().withMessage('Team number is required'),
  body('SportType').notEmpty().withMessage('Sport type is required'),
];

const validateChildId = [
  param('id').isInt().withMessage('Child ID must be an integer'),
];

const router = express.Router();

// Middleware to log incoming requests
router.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Routes for managing children
router.post(
  '/add',
  authenticateUser,
  rateLimiter, // Protect from abuse
  validateChild,
  validateRequest,
  childController.addChild
);

router.get(
  '/all',
  authenticateUser,
  rateLimiter,
  childController.getChildren
);

router.put(
  '/update/:id',
  authenticateUser,
  rateLimiter,
  validateChild,
  validateChildId,
  validateRequest,
  childController.updateChild
);

router.delete(
  '/delete/:id',
  authenticateUser,
  rateLimiter,
  validateChildId,
  validateRequest,
  childController.deleteChild
);

module.exports = router;
