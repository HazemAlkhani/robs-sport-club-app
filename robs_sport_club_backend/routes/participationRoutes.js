const express = require('express');
const { body, param, query } = require('express-validator');
const participationController = require('../controllers/participationController');
const { authenticateUser } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validateRequest');

const router = express.Router();

// Middleware to log incoming requests
router.use((req, res, next) => {
  const user = req.user ? `User: ${req.user.email} (${req.user.role})` : 'Unauthenticated';
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${user}`);
  console.log('Request Body:', req.body);
  next();
});

// Validation rules
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

// Admin routes
router.post(
  '/add',
  authenticateUser,
  participationValidation,
  validateRequest,
  participationController.addParticipation
);

router.get('/all', authenticateUser, participationController.getAllParticipations);

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

router.delete(
  '/delete/:id',
  authenticateUser,
  param('id').isInt().withMessage('Participation ID must be an integer'),
  validateRequest,
  participationController.deleteParticipation
);

router.get('/teams', authenticateUser, async (req, res, next) => {
  try {
    const teams = await participationController.getTeams(req);
    res.status(200).json({ success: true, data: teams });
  } catch (error) {
    console.error('Error fetching teams:', error.message);
    next(error);
  }
});

router.get('/children/:teamNo', authenticateUser, async (req, res, next) => {
  try {
    const { teamNo } = req.params;
    const children = await participationController.getChildrenByTeam(teamNo);
    res.status(200).json({ success: true, data: children });
  } catch (error) {
    console.error('Error fetching children:', error.message);
    next(error);
  }
});

// User-specific routes
router.get('/my-children', authenticateUser, async (req, res, next) => {
  try {
    const participations = await participationController.getParticipationByUser(req);
    res.status(200).json({ success: true, data: participations });
  } catch (error) {
    console.error('Error fetching participation by user:', error.message);
    next(error);
  }
});

router.get('/child-statistics', authenticateUser, async (req, res, next) => {
  try {
    const statistics = await participationController.getChildStatistics(req, res);
    res.status(200).json({ success: true, data: statistics });
  } catch (error) {
    console.error('Error fetching child statistics:', error.message);
    next(error);
  }
});

module.exports = router;
