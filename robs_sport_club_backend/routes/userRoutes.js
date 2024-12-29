const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/userController');
const validateRequest = require('../middleware/validateRequest');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

// Validation rules for creating a user
const createUserValidation = [
  body('parentName').notEmpty().withMessage('Parent name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('mobile').notEmpty().withMessage('Mobile number is required'),
  body('sportType').notEmpty().withMessage('Sport type is required'),
  body('username').notEmpty().withMessage('Username is required'),
];

// Validation rules for updating a user
const updateUserValidation = [
  body('parentName').optional().notEmpty().withMessage('Parent name cannot be empty'),
  body('email').optional().isEmail().withMessage('Valid email is required'),
  body('mobile').optional().notEmpty().withMessage('Mobile number cannot be empty'),
  body('sportType').optional().notEmpty().withMessage('Sport type cannot be empty'),
  body('username').optional().notEmpty().withMessage('Username cannot be empty'),
];

// Define routes
router.post(
  '/add',
  authenticateUser,
  createUserValidation,
  validateRequest,
  userController.createUser
); // Add user

router.get('/all', authenticateUser, userController.getAllUsers); // Get all users

router.put(
  '/update/:id',
  authenticateUser,
  updateUserValidation,
  validateRequest,
  userController.updateUser
); // Update user

router.delete(
  '/delete/:id',
  authenticateUser,
  userController.deleteUser
); // Delete user

module.exports = router;
