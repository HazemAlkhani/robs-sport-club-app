const express = require('express');
const { body } = require('express-validator');
const childController = require('../controllers/childController');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

// Validation rules for Children
const childValidation = [
  body('ChildName').notEmpty().withMessage('Child name is required'),
  body('TeamNo').notEmpty().withMessage('Team number is required'),
  body('SportType').notEmpty().withMessage('Sport type is required'),
];

// Routes for managing children
router.post('/add', authenticateUser, childValidation, childController.addChild); // Add a child
router.get('/all', authenticateUser, childController.getChildren); // Get all children for the authenticated user
router.put('/update/:id', authenticateUser, childValidation, childController.updateChild); // Update child details
router.delete('/delete/:id', authenticateUser, childController.deleteChild); // Delete a child

module.exports = router;
