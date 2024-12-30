const express = require('express');
const { param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { authenticateUser } = require('../middleware/authMiddleware');
const {
  getUserStatistics,
  getAllStatistics,
  getChildStatistics,
} = require('../controllers/statisticsController');

const router = express.Router();

// Validation for childId parameter
const validateChildId = [
  param('childId')
    .isInt({ gt: 0 })
    .withMessage('Child ID must be a positive integer'),
];

// Fetch all statistics (admin) or by childName
router.get('/all', authenticateUser, getAllStatistics);

// Fetch statistics for the logged-in user
router.get('/user', authenticateUser, getUserStatistics);

// Fetch statistics for a specific child
router.get(
  '/child/:childId',
  authenticateUser,
  validateChildId,
  validateRequest,
  getChildStatistics // Direct call to controller function
);

module.exports = router;
