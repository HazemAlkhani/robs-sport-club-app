const express = require('express');
const { body, param } = require('express-validator');
const participationController = require('../controllers/participationController');
const verifyToken = require('../middleware/auth');
const validateRequest = require('../middleware/validateRequest');

const router = express.Router();

// Validation rules for adding participation
const participationValidation = [
  body('ChildName').notEmpty().withMessage('Child name is required'),
  body('ParticipationType').isIn(['Training', 'Match']).withMessage('Participation type must be "Training" or "Match"'),
  body('Date').isISO8601().withMessage('Invalid date format (YYYY-MM-DD expected)'),
  body('TimeStart')
    .matches(/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)(\.\d+)?$/)
    .withMessage('Invalid time format for TimeStart (HH:MM:SS[.fff...] expected)'),
  body('TimeEnd')
    .matches(/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)(\.\d+)?$/)
    .withMessage('Invalid time format for TimeEnd (HH:MM:SS[.fff...] expected)'),
  body('Location').notEmpty().withMessage('Location is required'),
];


// Add participation route
router.post('/add', verifyToken, participationValidation, (req, res, next) => {
  console.log('Request Body:', req.body);
  next();
}, participationController.addParticipation);

router.get(
  '/all',
  verifyToken,
  participationController.getAllParticipations
);

router.get(
  '/my-children',
  verifyToken,
  participationController.getParticipationByUser
);

router.put(
  '/update/:id',
  verifyToken,
  participationValidation,
  validateRequest(participationValidation),
  participationController.updateParticipation
);

router.delete(
  '/delete/:id',
  verifyToken,
  param('id').isInt().withMessage('Participation ID must be an integer'),
  validateRequest([param('id')]),
  participationController.deleteParticipation
);

module.exports = router;
