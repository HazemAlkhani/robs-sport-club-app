const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const verifyToken = require('../middleware/auth');
const userController = require('../controllers/userController');

const router = express.Router();

// Validation rules for creating/updating a user
const userValidation = [
  body('parentName').notEmpty().withMessage('Parent name is required'),
  body('email').isEmail().withMessage('Invalid email format'),
  body('mobile').notEmpty().withMessage('Mobile number is required'),
  body('sportType').notEmpty().withMessage('Sport type is required'),
  body('username').notEmpty().withMessage('Username is required'),
  body('role').optional().isIn(['user', 'admin']).withMessage('Role must be either "user" or "admin"'),
];

// Validation rules for fetching or deleting a user by ID
const idValidation = [
  param('id').isInt().withMessage('User ID must be an integer'),
];

// Create a new user
router.post(
  '/',
  verifyToken,
  userValidation,
  validateRequest(userValidation),
  userController.createUser
);

// Get all users
router.get('/', verifyToken, userController.getAllUsers);

// Get a user by ID
router.get(
  '/:id',
  verifyToken,
  idValidation,
  validateRequest(idValidation),
  userController.getUserById
);

// Update a user by ID
router.put(
  '/:id',
  verifyToken,
  [...idValidation, ...userValidation],
  validateRequest([...idValidation, ...userValidation]),
  userController.updateUser
);

// Delete a user by ID
router.delete(
  '/:id',
  verifyToken,
  idValidation,
  validateRequest(idValidation),
  userController.deleteUser
);

module.exports = router;
