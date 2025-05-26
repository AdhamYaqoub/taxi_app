const express = require('express');
const router = express.Router();
const taxiOfficeMapController = require('../controllers/taxiOfficeMapController');

// لا تحتاج إلى مصادقة إذا كانت الخريطة عامة
router.get('/offices', taxiOfficeMapController.getOfficesForMap);
router.get('/offices/:id', taxiOfficeMapController.getOfficeDetails);

module.exports = router;