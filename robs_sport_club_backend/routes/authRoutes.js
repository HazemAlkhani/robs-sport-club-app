const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');

const router = express.Router();

// Validation rules for registration
const registerValidation = [
  body('name').notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
  body('role').isIn(['admin', 'user']).withMessage('Role must be "admin" or "user"'),
];

// Route for registration
router.post('/register', registerValidation, authController.register);

// Validation rules for login
const loginValidation = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Login route
router.post('/login', loginValidation, authController.login);

module.exports = router;
