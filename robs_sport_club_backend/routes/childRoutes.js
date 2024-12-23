const express = require('express');
const { body, param } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const verifyToken = require('../middleware/auth');
const childController = require('../controllers/childController');

const router = express.Router();

// Validation rules for creating/updating a child
const childValidation = [
  body('childName').notEmpty().withMessage('Child name is required'),
  body('userId').isInt().withMessage('User ID must be an integer'),
  body('teamNo').notEmpty().withMessage('Team number is required'),
];

// Validation rules for fetching or deleting a child by ID
const idValidation = [
  param('id').isInt().withMessage('Child ID must be an integer'),
];

// Create a new child
router.post(
  '/',
  verifyToken,
  childValidation,  // Apply the child-specific validation
  validateRequest,  // Use validateRequest as middleware to handle errors
  childController.createChild  // Call the controller function
);

// Get all children
router.get('/', verifyToken, childController.getAllChildren);

// Get a child by ID
router.get(
  '/:id',
  verifyToken,
  idValidation,  // Apply ID validation
  validateRequest,  // Use validateRequest to handle errors
  childController.getChildById
);

// Update a child by ID
router.put(
  '/:id',
  verifyToken,
  [...idValidation, ...childValidation],  // Combine both ID and child validation
  validateRequest,  // Use validateRequest to handle errors
  childController.updateChild
);

// Delete a child by ID
router.delete(
  '/:id',
  verifyToken,
  idValidation,  // Apply ID validation
  validateRequest,  // Use validateRequest to handle errors
  childController.deleteChild
);

module.exports = router;
