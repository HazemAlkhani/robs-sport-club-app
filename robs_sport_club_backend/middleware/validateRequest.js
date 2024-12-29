const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { getUserStatistics, getChildStatistics } = require('../controllers/statisticsController');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

// Reusable validation logic
const validateFutureDate = (value) => {
  if (new Date(value) > new Date()) {
    throw new Error('Date cannot be in the future');
  }
  return true;
};

// Validation rules
const validateChildId = [
  param('childId').isInt({ gt: 0 }).withMessage('Child ID must be a positive integer'),
];

const validateStatisticsInput = [
  body('date')
    .isISO8601().withMessage('Date must be in ISO8601 format')
    .custom(validateFutureDate),
  body('duration')
    .isInt({ min: 1, max: 1440 }).withMessage('Duration must be a positive integer and less than 1440 minutes (24 hours)'),
];

// Route for fetching statistics for a specific child
router.get(
  '/child/:childId',
  authenticateUser, // Ensure the user is authenticated
  validateChildId,
  validateRequest,
  async (req, res, next) => {
    try {
      const data = await getChildStatistics(req);
      res.status(200).json({
        success: true,
        message: 'Child statistics fetched successfully',
        data,
      });
    } catch (error) {
      console.error(`[GET /child/${req.params.childId}] Error:`, error.message);
      next(error); // Pass error to the global error handler
    }
  }
);

// Route for creating user statistics
router.post(
  '/statistics',
  authenticateUser, // Ensure the user is authenticated
  validateStatisticsInput,
  validateRequest,
  async (req, res, next) => {
    try {
      const data = await getUserStatistics(req);
      res.status(201).json({
        success: true,
        message: 'User statistics created successfully',
        data,
      });
    } catch (error) {
      console.error('[POST /statistics] Error:', error.message);
      next(error); // Pass error to the global error handler
    }
  }
);

module.exports = router;
