const express = require('express');
const router = express.Router();
const { register, login, getAllUsers, googleLogin, updateUserRole, updateProfile, changePassword } = require('../controllers/authController');
const { protect, admin } = require('../middleware/authMiddleware');

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.get('/users', protect, admin, getAllUsers);
router.put('/role/:id', protect, admin, updateUserRole);
router.put('/profile', protect, updateProfile);
router.put('/change-password', protect, changePassword);

module.exports = router;
