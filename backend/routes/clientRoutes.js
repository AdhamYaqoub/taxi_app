const express = require('express');
const clientController = require('../controllers/clientController');

const router = express.Router();

// GET /api/clients/
router.get('/', clientController.getAllClients);

// GET /api/ /:id
router.get('/:id', clientController.getClientById);

// PUT /api/clients/:id/status
router.put('/:id/availability', clientController.updateAvailability);

// تحديث صورة العميل
router.put('/:id/profile-image', clientController.updateClientProfileImage);


module.exports = router;
