const express = require('express');
const { body, param } = require('express-validator');
const participationController = require('../controllers/participationController');
const { authenticateUser } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validateRequest');

const router = express.Router();

/**
 * Middleware to log incoming requests
 */
router.use((req, res, next) => {
  const userInfo = req.user ? `User: ${req.user.email} (${req.user.role})` : 'Unauthenticated';
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${userInfo}`);
  console.log('Request Body:', req.body);
  next();
});

/**
 * Validation rules
 */
const participationValidation = [
  body('ChildName').notEmpty().withMessage('Child name is required'),
  body('ParticipationType')
    .isIn(['Training', 'Match'])
    .withMessage('Participation type must be "Training" or "Match"'),
  body('Date').isISO8601().withMessage('Invalid date format (YYYY-MM-DD expected)'),
  body('TimeStart').matches(/^([01]\d|2[0-3]):([0-5]\d)$/).withMessage('Invalid TimeStart format. Use HH:MM.'),
  body('Duration').isInt({ min: 1 }).withMessage('Duration must be a positive integer.'),
  body('Location').notEmpty().withMessage('Location is required'),
];

/**
 * Routes
 */

// Add a new participation (Admin only)
router.post(
  '/add',
  authenticateUser,
  participationValidation,
  validateRequest,
  participationController.addParticipation
);

// Get all participations (Admin: all, User: own)
router.get(
  '/all',
  authenticateUser,
  participationController.getAllParticipations
);

// Update participation by ID (Admin only)
router.put(
  '/update/:id',
  authenticateUser,
  [
    param('id').isInt().withMessage('Participation ID must be an integer'),
    ...participationValidation,
  ],
  validateRequest,
  participationController.updateParticipation
);

// Delete participation by ID (Admin only)
router.delete(
  '/delete/:id',
  authenticateUser,
  param('id').isInt().withMessage('Participation ID must be an integer'),
  validateRequest,
  participationController.deleteParticipation
);

module.exports = router;
