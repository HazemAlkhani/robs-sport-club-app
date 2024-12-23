const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const verifyToken = require('../middleware/auth');
const participationController = require('../controllers/participationController');

const router = express.Router();

// Validation rules for creating/updating participation
const participationValidation = [
  body('childId').isInt().withMessage('Child ID must be an integer'),
  body('participationType').notEmpty().withMessage('Participation type is required'),
  body('teamNo').notEmpty().withMessage('Team number is required'),
  body('date').isISO8601().withMessage('Date must be a valid ISO 8601 format'),
  body('timeStart').isISO8601().withMessage('Start time must be in a valid ISO 8601 format'), // Added time validation
  body('timeEnd').isISO8601().withMessage('End time must be in a valid ISO 8601 format'), // Added time validation
  body('location').notEmpty().withMessage('Location is required'),
];

// Validation rule for fetching or deleting participation by ID
const idValidation = [
  param('id').isInt().withMessage('Participation ID must be an integer'),
];

// Create a new participation record
router.post(
  '/',
  verifyToken,
  participationValidation,
  validateRequest(participationValidation),
  participationController.createParticipation
);

// Get all participation records
router.get('/', verifyToken, participationController.getAllParticipations);

// Get participation by ID
router.get(
  '/:id',
  verifyToken,
  idValidation,
  validateRequest(idValidation),
  participationController.getParticipationById
);

// Update participation by ID
router.put(
  '/:id',
  verifyToken,
  [...idValidation, ...participationValidation],
  validateRequest([...idValidation, ...participationValidation]),
  participationController.updateParticipation
);

// Delete participation by ID
router.delete(
  '/:id',
  verifyToken,
  idValidation,
  validateRequest(idValidation),
  participationController.deleteParticipation
);

module.exports = router;
