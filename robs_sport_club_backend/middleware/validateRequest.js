const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { getUserStatistics, getChildStatistics } = require('../controllers/statisticsController');

const router = express.Router();

// Route with validation
router.get('/child/:childId',
  [
    param('childId')
      .isInt().withMessage('Child ID must be an integer')
      .notEmpty().withMessage('Child ID is required'),
  ],
  validateRequest, // Middleware to handle validation results
  getChildStatistics
);

// Another route example
router.post('/statistics',
  [
    body('date').isISO8601().withMessage('Date must be in ISO8601 format'),
    body('duration').isInt({ min: 1 }).withMessage('Duration must be a positive integer'),
  ],
  validateRequest,
  getUserStatistics
);

module.exports = router;
