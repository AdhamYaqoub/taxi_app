// routes/driverRoutes.js
const express = require('express');
const driverController = require('../controllers/driverController');
// قد تحتاج إلى middleware للتحقق من المصادقة في مسارات أخرى
// const { protect, isUser } = require('../middleware/authMiddleware');

const router = express.Router();


// GET /api/drivers/
router.get('/', driverController.getAllDrivers);

// GET /api/drivers/available
router.get('/available', driverController.getAvailableDrivers);

router.get('/:id', driverController.getDriverById);


// في ملف routes/drivers.js
router.put('/:id/availability',driverController.updateAvailability);

// تحديث صورة السائق
router.put('/:id/profile-image', driverController.updateDriverProfileImage);

router.put('/driver/:driverId', driverController.updateDriverProfile);


module.exports = router;