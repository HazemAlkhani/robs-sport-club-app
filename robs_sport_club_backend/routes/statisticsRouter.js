const express = require('express');
const { authenticateUser } = require('../middleware/authMiddleware');
const { isAdmin } = require('../middleware/roleMiddleware');
const { validateChildId } = require('../middleware/validationMiddleware');
const { getUserStatistics, getAllStatistics, getChildStatistics } = require('../controllers/statisticsController');

const router = express.Router();

// Routes for statistics
router.get('/all', authenticateUser, isAdmin, getAllStatistics); // Admin: Get all statistics
router.get('/:childId', authenticateUser, validateChildId, getChildStatistics); // Specific child statistics (protected)

module.exports = router;
