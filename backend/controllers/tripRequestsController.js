// controllers/tripRequestsController.js
const TripRequest = require('../models/TripRequest');

// إنشاء طلب رحلة جديد
exports.createRequest = async (req, res) => {
  try {
    const { userId, startLocation, endLocation, distance } = req.body;
    
    const request = new TripRequest({
      userId,
      startLocation,
      endLocation,
      distance,
      estimatedFare: distance * 10 // 10 لكل كيلومتر
    });

    await request.save();
    
    res.status(201).json({
      success: true,
      requestId: request.requestId,
      data: request
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ 
      success: false,
      message: 'Error creating trip request' 
    });
  }
};

// الحصول على طلبات السائق
exports.getDriverRequests = async (req, res) => {
  try {
    const requests = await TripRequest.find({
      driverId: req.params.driverId,
      status: 'pending'
    }).sort({ requestedAt: -1 });

    res.status(200).json({
      success: true,
      count: requests.length,
      data: requests
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching requests' 
    });
  }
};

// الحصول على جميع الطلبات غير المخصصة (بدون سائق)
exports.getPendingRequests = async (req, res) => {
    const requests = await TripRequest.find({ 
      status: 'pending',
      driverId: { $exists: false } 
    });
    res.json(requests);
  };

// قبول الطلب
exports.acceptRequest = async (req, res) => {
  try {
    const request = await TripRequest.findOneAndUpdate(
      { requestId: req.params.requestId },
      { 
        status: 'accepted',
        driverId: req.body.driverId 
      },
      { new: true }
    );

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Request not found'
      });
    }

    res.status(200).json({
      success: true,
      data: request
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Error accepting request'
    });
  }
};

// رفض الطلب
exports.rejectRequest = async (req, res) => {
  try {
    const request = await TripRequest.findOneAndUpdate(
      { requestId: req.params.requestId },
      { status: 'rejected' },
      { new: true }
    );

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Request not found'
      });
    }

    res.status(200).json({
      success: true,
      data: request
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Error rejecting request'
    });
  }
};