// controllers/driverController.js
const User = require('../models/User');
const AppError = require('../utils/appError');
const catchAsync = require('../utils/catchAsync');

// تحديث معلومات السائق
const updateDriverProfile = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const updateData = req.body;

  // منع تحديث بعض الحقول
  if (updateData.role || updateData.email || updateData.phone) {
    return next(new AppError('لا يمكن تحديث هذه البيانات', 400));
  }

  const driver = await User.findByIdAndUpdate(
    id,
    { $set: updateData },
    { new: true, runValidators: true }
  ).select('-password');

  if (!driver || driver.role !== 'driver') {
    return next(new AppError('لم يتم العثور على السائق', 404));
  }

  res.status(200).json({
    status: 'success',
    data: {
      driver
    }
  });
});

// الحصول على معلومات السائق
const getDriverProfile = catchAsync(async (req, res, next) => {
  const driver = await User.findById(req.params.id)
    .select('-password')
    .populate('taxiOffice');

  if (!driver || driver.role !== 'driver') {
    return next(new AppError('لم يتم العثور على السائق', 404));
  }

  res.status(200).json({
    status: 'success',
    data: {
      driver
    }
  });
});

// تغيير حالة السائق (اونلاين/اوفلاين)
const updateDriverStatus = catchAsync(async (req, res, next) => {
  const { isOnline, lastLocation } = req.body;

  const driver = await User.findByIdAndUpdate(
    req.user.id,
    {
      isOnline,
      lastLocation: lastLocation ? {
        type: 'Point',
        coordinates: [lastLocation.lng, lastLocation.lat]
      } : undefined
    },
    { new: true }
  ).select('-password');

  res.status(200).json({
    status: 'success',
    data: {
      driver
    }
  });
});

// الحصول على جميع السائقين
const getAllDrivers = catchAsync(async (req, res, next) => {
  const drivers = await User.find({ role: 'driver' })
    .select('-password')
    .populate('taxiOffice');

  res.status(200).json({
    status: 'success',
    results: drivers.length,
    data: {
      drivers
    }
  });
});

module.exports = {
  updateDriverProfile,
  getDriverProfile,
  updateDriverStatus,
  getAllDrivers
};