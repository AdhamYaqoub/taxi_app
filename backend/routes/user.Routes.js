const express = require('express');
const router = express.Router();

// استيراد التحكم (controller)
const { createUser, loginUser, getUsers } = require('../controllers/userController');

// نقطة النهاية لإضافة مستخدم جديد
router.post('/signup', createUser);

// نقطة النهاية لتسجيل الدخول
router.post('/signin', loginUser);

// نقطة النهاية لاسترجاع جميع المستخدمين
router.get('/', getUsers);

module.exports = router;
