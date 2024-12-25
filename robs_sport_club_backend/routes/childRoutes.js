const express = require('express');
const { body } = require('express-validator');
const childController = require('../controllers/childController');
const validateRequest = require('../middleware/validateRequest');
const authenticateUser = require('../middleware/auth');



// Validation rules for child operations
const validateChild = [
  body('ChildName').notEmpty().withMessage('Child name is required'),
  body('TeamNo').notEmpty().withMessage('Team number is required'),
  body('SportType').notEmpty().withMessage('Sport type is required'),
];

const router = express.Router();

// Routes for managing children
router.post('/add', authenticateUser, validateChild, validateRequest, childController.addChild);
router.get('/all', authenticateUser, childController.getChildren);
router.put('/update/:id', authenticateUser, validateChild, validateRequest, childController.updateChild);
router.delete('/delete/:id', authenticateUser, childController.deleteChild);

module.exports = router;
