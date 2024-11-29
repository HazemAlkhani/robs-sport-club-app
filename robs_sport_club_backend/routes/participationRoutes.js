const express = require('express');
const router = express.Router();
const participationController = require('../controllers/participationController');
const verifyToken = require('../middleware/auth');
const { param, validationResult } = require('express-validator');

// Middleware for validating childId
const validateChildId = [
  param('childId').isNumeric().withMessage('Child ID must be a numeric value'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

// Protected routes for managing participation
router.post('/', verifyToken, participationController.createParticipation);
router.get('/:childId', verifyToken, validateChildId, participationController.getParticipationByChild);

module.exports = router;
