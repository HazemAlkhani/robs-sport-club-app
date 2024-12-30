const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const {
  getUserStatistics,
  getChildStatistics,
  getAllStatistics,
} = require('../controllers/statisticsController');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

/**
 * Validation rules
 */

// Validation for childId parameter
const validateChildId = [
  param('childId')
    .isInt({ gt: 0 })
    .withMessage('Child ID must be a positive integer'),
];

// Validation for creating or updating statistics input
const validateStatisticsInput = [
  body('date')
    .isISO8601()
    .withMessage('Date must be in ISO8601 format')
    .custom((value) => {
      if (new Date(value) > new Date()) {
        throw new Error('Date cannot be in the future');
      }
      return true;
    }),
  body('duration')
    .isInt({ min: 1, max: 1440 })
    .withMessage('Duration must be a positive integer and less than 1440 minutes (24 hours)'),
];

/**
 * Routes
 */

// Fetch statistics for a specific child
router.get(
  '/child/:childId',
  authenticateUser, // Ensure user is authenticated
  validateChildId, // Validate childId
  validateRequest, // Validate request input
  async (req, res, next) => {
    try {
      console.log(`[GET /child/${req.params.childId}] Fetching child statistics`); // Debug log
      const data = await getChildStatistics(req); // Fetch data
      res.status(200).json({
        success: true,
        message: 'Child statistics fetched successfully',
        data,
      });
    } catch (error) {
      console.error(`[GET /child/${req.params.childId}] Error:`, error.message); // Log error
      next(error); // Pass error to global error handler
    }
  }
);

// Fetch all statistics for admin with pagination
router.get(
  '/all',
  authenticateUser, // Ensure user is authenticated
  async (req, res, next) => {
    try {
      console.log('[GET /all] Fetching all statistics'); // Debug log

      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;

      const data = await getAllStatistics(req, offset, limit); // Fetch data with pagination

      res.status(200).json({
        success: true,
        message: 'All statistics fetched successfully',
        pagination: {
          page,
          limit,
          total: data.total, // Assuming total count is returned
        },
        data: data.records, // Assuming data is returned as an array
      });
    } catch (error) {
      console.error('[GET /all] Error:', error.message); // Log error
      next(error); // Pass error to global error handler
    }
  }
);

// Create or update user statistics
router.post(
  '/statistics',
  authenticateUser, // Ensure user is authenticated
  validateStatisticsInput, // Validate input
  validateRequest, // Validate request input
  async (req, res, next) => {
    try {
      console.log('[POST /statistics] Creating or updating user statistics:', req.body); // Debug log
      const data = await getUserStatistics(req); // Create or update statistics
      res.status(201).json({
        success: true,
        message: 'User statistics processed successfully',
        data,
      });
    } catch (error) {
      console.error('[POST /statistics] Error:', error.message); // Log error
      next(error); // Pass error to global error handler
    }
  }
);

/**
 * Export the router
 */
module.exports = router;
