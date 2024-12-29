const express = require('express');
const { authenticateUser } = require('../middleware/authMiddleware');
const { isAdmin } = require('../middleware/roleMiddleware');
const { getAllStatistics, getChildStatistics } = require('../controllers/statisticsController');

const router = express.Router();

// Admin-only route
router.get('/all', authenticateUser, isAdmin, getAllStatistics);

// Route accessible to any authenticated user
router.get('/:childId', authenticateUser, getChildStatistics);

module.exports = router;
