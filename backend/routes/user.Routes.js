const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

// استيراد التحكم (controller)
const { createUser, loginUser, getUsers, logoutUser,getPrintFullName } = require('../controllers/userController');

// نقطة النهاية لإضافة مستخدم جديد
router.post('/signup', createUser);

// نقطة النهاية لتسجيل الدخول
router.post('/signin', loginUser);

// نقطة النهاية لاسترجاع جميع المستخدمين
router.get('/', getUsers);  // هذه ستظل كما هي

// router.post('/logout', logoutUser);
router.put('/logout', logoutUser);

router.get('/fullname/:userId', getPrintFullName);

// نقطة النهاية لاسترجاع السائقين فقط
router.get('/drivers', async (req, res) => {
  try {
    // تصفية السائقين فقط
    const users = await getUsers({ role: 'Driver' });
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'حدث خطأ أثناء جلب السائقين' });
  }
});

module.exports = router;
