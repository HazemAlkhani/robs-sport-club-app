const express = require('express');
const router = express.Router();
const participationController = require('../controllers/participationController');
const verifyToken = require('../middleware/auth'); // Import token verification middleware

// Protected routes for managing participation
router.post('/', verifyToken, participationController.createParticipation);
router.get('/:childId', verifyToken, participationController.getParticipationByChild);

module.exports = router;
