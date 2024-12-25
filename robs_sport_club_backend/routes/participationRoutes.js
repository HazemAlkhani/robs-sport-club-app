const express = require('express');
const { body, param } = require('express-validator');
const participationController = require('../controllers/participationController');
const verifyToken = require('../middleware/auth');
const validateRequest = require('../middleware/validateRequest');

const router = express.Router();

// Validation rules for adding or updating participation
const participationValidation = [
  body('ChildName')
    .notEmpty()
    .withMessage('Child name is required'),
  body('ParticipationType')
    .isIn(['Training', 'Match'])
    .withMessage('Participation type must be "Training" or "Match"'),
  body('Date')
    .isISO8601()
    .withMessage('Invalid date format (YYYY-MM-DD expected)'),
  body('TimeStart')
    .matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
    .withMessage('Invalid TimeStart format. Use HH:MM format (e.g., 11:11).'), // Updated to validate HH:MM
  body('Duration')
    .isInt({ min: 1 })
    .withMessage('Duration must be a positive integer.'),
  body('Location')
    .notEmpty()
    .withMessage('Location is required'),
];

// Debugging middleware to log incoming requests
router.use((req, res, next) => {
  const user = req.user ? `User: ${req.user.email} (${req.user.role})` : 'Unauthenticated';
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${user}`);
  console.log('Request Body:', req.body);
  next();
});

// Route: Add participation
router.post(
  '/add',
  verifyToken,
  participationValidation,
  validateRequest,
  participationController.addParticipation
);

// Route: Fetch all participations (Admin only)
router.get(
  '/all',
  verifyToken,
  participationController.getAllParticipations
);

// Route: Fetch participation for children of a parent (Parent only)
router.get(
  '/my-children',
  verifyToken,
  async (req, res, next) => {
    try {
      const participations = await participationController.getParticipationByUser(req);
      if (!participations || participations.length === 0) {
        return res.status(404).json({ message: 'No participation records found for your children.' });
      }
      res.status(200).json({ success: true, data: participations });
    } catch (error) {
      console.error('Error fetching participation by user:', error.message, error.stack);
      next(error);
    }
  }
);

// Route: Update participation
router.put(
  '/update/:id',
  verifyToken,
  participationValidation,
  validateRequest,
  participationController.updateParticipation
);

// Route: Delete participation
router.delete(
  '/delete/:id',
  verifyToken,
  param('id').isInt().withMessage('Participation ID must be an integer'),
  validateRequest,
  participationController.deleteParticipation
);

module.exports = router;
