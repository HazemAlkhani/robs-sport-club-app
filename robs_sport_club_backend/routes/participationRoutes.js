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
    .withMessage('Invalid TimeStart format. Use HH:MM format (e.g., 11:11).'),
  body('Duration')
    .isInt({ min: 1 })
    .withMessage('Duration must be a positive integer.'),
  body('Location')
    .notEmpty()
    .withMessage('Location is required'),
];

// Middleware to log incoming requests
router.use((req, res, next) => {
  const user = req.user ? `User: ${req.user.email} (${req.user.role})` : 'Unauthenticated';
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${user}`);
  console.log('Request Body:', req.body);
  next();
});

// Admin routes
router.post(
  '/add',
  verifyToken,
  participationValidation,
  validateRequest,
  participationController.addParticipation
);

router.get('/all', verifyToken, participationController.getAllParticipations);

router.put(
  '/update/:id',
  verifyToken,
  participationValidation,
  validateRequest,
  participationController.updateParticipation
);

router.delete(
  '/delete/:id',
  verifyToken,
  param('id').isInt().withMessage('Participation ID must be an integer'),
  validateRequest,
  participationController.deleteParticipation
);

router.get('/teams', verifyToken, async (req, res, next) => {
  try {
    const teams = await participationController.getTeams(req);
    if (!teams || teams.length === 0) {
      return res.status(404).json({ message: 'No teams found.' });
    }
    res.status(200).json({ success: true, data: teams });
  } catch (error) {
    console.error('Error fetching teams:', error.message, error.stack);
    next(error); // Use global error handler
  }
});



router.get('/children/:teamNo', verifyToken, async (req, res, next) => {
  try {
    const teamNo = req.params.teamNo;
    const children = await participationController.getChildrenByTeam(teamNo); // Replace with your DB query logic
    if (!children || children.length === 0) {
      return res.status(404).json({ success: false, message: 'No children found for the selected team.' });
    }
    res.status(200).json({ success: true, data: children });
  } catch (error) {
    console.error('Error fetching children:', error.message, error.stack);
    next(error);
  }
});

// User-specific routes
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

router.get(
  '/child-statistics',
  verifyToken,
  async (req, res, next) => {
    try {
      const statistics = await participationController.getChildStatistics(req, res);
      if (!statistics || statistics.length === 0) {
        return res.status(404).json({ message: 'No child statistics found.' });
      }
      res.status(200).json({ success: true, data: statistics });
    } catch (error) {
      console.error('Error fetching child statistics:', error.message, error.stack);
      next(error);
    }
  }
);

module.exports = router;
