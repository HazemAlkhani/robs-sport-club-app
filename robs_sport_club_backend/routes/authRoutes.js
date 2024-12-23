const express = require('express');
const { body } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const authController = require('../controllers/authController');

const router = express.Router();

// Validation rules for registration
const registerValidation = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('name').notEmpty().withMessage('Name is required'),
];

// Validation rules for login
const loginValidation = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Register route
router.post('/register', registerValidation, validateRequest(registerValidation), authController.register);

// Login route
router.post('/login', loginValidation, validateRequest(loginValidation), authController.login);

module.exports = router;
