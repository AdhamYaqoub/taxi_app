// routes/driverRoutes.js
const express = require('express');
const driverController = require('../controllers/driverController');
const upload = require('../middleware/multerCloudinary');

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
router.put(
  '/:id/profile-image',
  (req, res, next) => {
    upload.single('image')(req, res, function (err) {
      if (err) {
        console.error('Multer error:', err);
        return res.status(400).json({ 
          success: false,
          message: err.message 
        });
      }
      next();
    });
  },
  driverController.uploadDriverImage
);

router.put('/:driverId', driverController.updateDriverProfile);
router.get('/status/:userId', driverController.getDriverStatusByUserId); // ✅ هذا هو الراوت الجديد

const { updateDriverLocation } = require('../controllers/driverLocationController'); // تأكد من المسار

// راوت لتحديث موقع السائق
// يجب أن يكون هذا الراوت محمياً بـ authMiddleware
router.post('/:driverUserId/location', updateDriverLocation);

module.exports = router;