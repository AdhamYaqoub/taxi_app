const express = require('express');
const { addTrip, updateTripStatus, getDriverTrips, getRecentTrips} = require('../controllers/tripsController');
const router = express.Router();

// إضافة رحلة جديدة
router.post('/trips', addTrip);

// تحديث حالة الرحلة
router.patch('/trips/status', updateTripStatus);

// الحصول على جميع الرحلات الخاصة بسائق
router.get('/trips/driver/:userId', getDriverTrips);

// الحصول على آخر الرحلات للسائق مع تحديد الحد
router.get('/trips/driver/:userId/recent', getRecentTrips);



module.exports = router;
