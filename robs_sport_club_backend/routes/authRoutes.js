const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const validateRequest = require('../middleware/validateRequest'); // Middleware to handle validation errors
const rateLimiter = require('../middleware/rateLimiter');


const router = express.Router();

// Validation rules for registration
const registerValidation = [
  body('name').notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Invalid email format'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters')
    .matches(/\d/)
    .withMessage('Password must contain a number'),
  body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
  body('role').isIn(['admin', 'user']).withMessage('Role must be "admin" or "user"'),
];


// Registration route
router.post(
  '/register',
  registerValidation,
  validateRequest, // Middleware to handle validation errors
  authController.register
);

// Validation rules for login
const loginValidation = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Login route with optional rate limiter
router.post(
  '/login',
  rateLimiter, // Prevent brute force attacks
  loginValidation,
  validateRequest, // Middleware to handle validation errors
  authController.login
);

module.exports = router;