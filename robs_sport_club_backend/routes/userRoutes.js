const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/userController');
const validateRequest = require('../middleware/validateRequest');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

// Define validation rules
const userValidation = [
  body('parentName').notEmpty().withMessage('Parent name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('mobile').notEmpty().withMessage('Mobile number is required'),
  body('sportType').notEmpty().withMessage('Sport type is required'),
  body('username').notEmpty().withMessage('Username is required'),
];

// Define routes
router.post('/add', authenticateUser, userValidation, validateRequest, userController.createUser); // Add user
router.get('/all', authenticateUser, userController.getAllUsers); // Get all users
router.put('/update/:id', authenticateUser, userValidation, validateRequest, userController.updateUser); // Update user
router.delete('/delete/:id', authenticateUser, userController.deleteUser); // Delete user

module.exports = router;
