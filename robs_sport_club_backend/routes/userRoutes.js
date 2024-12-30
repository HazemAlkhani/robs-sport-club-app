const express = require('express');
const { body, param } = require('express-validator');
const userController = require('../controllers/userController');
const validateRequest = require('../middleware/validateRequest');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

// Validation rules for registration
const registrationValidation = [
  body('name').notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  body('mobile').notEmpty().withMessage('Mobile number is required'),
  body('role').isIn(['user', 'admin']).withMessage('Role must be either "user" or "admin"'),
];

// Validation rules for updating a user
const updateUserValidation = [
  body('parentName').optional().notEmpty().withMessage('Parent name cannot be empty'),
  body('email').optional().isEmail().withMessage('Valid email is required'),
  body('mobile').optional().notEmpty().withMessage('Mobile number cannot be empty'),
  body('sportType').optional().notEmpty().withMessage('Sport type cannot be empty'),
];

// Validation rule for deleting a user by ID
const deleteUserValidation = [
  param('id').isInt().withMessage('User ID must be a valid integer'),
];

// Define routes
// Register user or admin
router.post(
  '/register',
  registrationValidation,
  validateRequest,
  userController.register
);

// Get all users
router.get('/all', authenticateUser, userController.getAllUsers);

// Update user
router.put(
  '/update/:id',
  authenticateUser,
  updateUserValidation,
  validateRequest,
  userController.updateUser
);

// Delete user
router.delete(
  '/delete/:id',
  authenticateUser,
  deleteUserValidation,
  validateRequest,
  userController.deleteUser
);

module.exports = router;
