const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const validateRequest = require('../middleware/validateRequest');
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
  validateRequest,
  authController.register
);

// Validation rules for login
const loginValidation = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Login route
router.post(
  '/login',
  rateLimiter,
  loginValidation,
  validateRequest,
  authController.login
);

// Validation rules for updating profile
const updateValidation = [
  body('id').isInt().withMessage('ID is required and must be an integer'),
  body('role').isIn(['admin', 'user']).withMessage('Role must be "admin" or "user"'),
  body('name').notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Invalid email format'),
  body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
  body('password')
    .optional()
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters')
    .matches(/\d/)
    .withMessage('Password must contain a number'),
];

// Update profile route
router.put(
  '/update-profile',
  updateValidation,
  validateRequest,
  authController.updateProfile
);


// Fetch Admin Details
router.get('/:adminId', authController.getAdminById);

// Update Admin Details
router.put(
  '/update/:adminId',
  [
    body('email').isEmail().withMessage('Invalid email format'),
    body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
    body('password').optional().isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  validateRequest,
  authController.updateAdmin
);

module.exports = router;
