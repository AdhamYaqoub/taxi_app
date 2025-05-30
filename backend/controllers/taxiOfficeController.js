const mongoose = require('mongoose');
const TaxiOffice = require('../models/TaxiOffice');
const Driver = require('../models/Driver');
const Trip = require('../models/Trip');
const Manager = require('../models/Manager');

// الحصول على جميع السائقين التابعين لمكتب التاكسي باستخدام managerId
exports.getOfficeDrivers = async (req, res) => {
  try {
    console.log('Fetching drivers for manager with ID:', req.params.id);
    const managerId = parseInt(req.params.id);
    
    if (isNaN(managerId)) {
      return res.status(400).json({ success: false, message: 'معرف المدير غير صالح' });
    }
    
    const manager = await Manager.findOne({ userId: managerId });
    if (!manager) {
      return res.status(404).json({ success: false, message: 'المدير غير موجود' });
    }
    
    const office = await TaxiOffice.findById(manager.office);
    if (!office) {
      return res.status(404).json({ success: false, message: 'المكتب غير موجود' });
    }
    
    const drivers = await Driver.find({ office: office._id })
      .populate({
        path: 'user',
        select: 'fullName phone email userId' // تأكد من تضمين userId هنا
      })
      .select('driverUserId carDetails isAvailable rating profileImageUrl earnings licenseNumber licenseExpiry joinedAt');
    
    res.status(200).json({
      success: true,
      data: drivers
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// حساب إجمالي الأرباح لجميع السائقين في المكتب
exports.getTotalEarnings = async (req, res) => {
  try {
    const managerId = parseInt(req.params.id);
    
    if (isNaN(managerId)) {
      return res.status(400).json({ success: false, message: 'معرف المدير غير صالح' });
    }
    
    // البحث عن المدير
    const manager = await Manager.findOne({ userId: managerId });
    
    if (!manager) {
      return res.status(404).json({ success: false, message: 'المدير غير موجود' });
    }
    
    // البحث عن المكتب
    const office = await TaxiOffice.findById(manager.office);
    
    if (!office) {
      return res.status(404).json({ success: false, message: 'المكتب غير موجود' });
    }
    
    const result = await Driver.aggregate([
      { $match: { office: office._id } },
      { $group: { _id: null, totalEarnings: { $sum: "$earnings" } } }
    ]);
    
    const totalEarnings = result.length > 0 ? result[0].totalEarnings : 0;
    
    res.status(200).json({
      success: true,
      data: { totalEarnings }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// الحصول على إحصائيات المكتب (عدد السائقين وعدد الرحلات)
exports.getOfficeStats = async (req, res) => {
  console.log('Fetching stats for manager with ID:', req.params.id);
  try {
    const managerId = parseInt(req.params.id);
    
    if (isNaN(managerId)) {
      return res.status(400).json({ success: false, message: 'معرف المدير غير صالح' });
    }
    
    // البحث عن المدير
    const manager = await Manager.findOne({ userId: managerId });
    
    if (!manager) {
      return res.status(404).json({ success: false, message: 'المدير غير موجود' });
    }
    
    // البحث عن المكتب
    const office = await TaxiOffice.findById(manager.office);
    
    if (!office) {
      return res.status(404).json({ success: false, message: 'المكتب غير موجود' });
    }
    
    // عدد السائقين
    const driversCount = await Driver.countDocuments({ office: office._id });
    
    // عدد الرحلات
    const drivers = await Driver.find({ office: office._id }).select('_id');
    const driverIds = drivers.map(driver => driver._id);
    
    const tripsCount = await Trip.countDocuments({ driver: { $in: driverIds } });
    
    res.status(200).json({
      success: true,
      data: { driversCount, tripsCount }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// الحصول على إحصائيات اليوم (أرباح اليوم وعدد الرحلات اليومية)
exports.getDailyStats = async (req, res) => {
  console.log('Fetching daily stats for manager with ID:', req.params.id);
  try {
    const managerId = parseInt(req.params.id);
    
    if (isNaN(managerId)) {
      return res.status(400).json({ success: false, message: 'معرف المدير غير صالح' });
    }
    
    // البحث عن المدير
    const manager = await Manager.findOne({ userId: managerId });
    
    if (!manager) {
      return res.status(404).json({ success: false, message: 'المدير غير موجود' });
    }
    
    // البحث عن المكتب
    const office = await TaxiOffice.findById(manager.office);
    
    if (!office) {
      return res.status(404).json({ success: false, message: 'المكتب غير موجود' });
    }
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // الحصول على سائقي المكتب
    const drivers = await Driver.find({ office: office._id }).select('_id');
    const driverIds = drivers.map(driver => driver._id);
    
    // تجميع رحلات اليوم
    const tripsAggregate = await Trip.aggregate([
      {
        $match: {
          driver: { $in: driverIds },
          createdAt: { $gte: today, $lt: tomorrow }
        }
      },
      {
        $group: {
          _id: null,
          dailyTripsCount: { $sum: 1 },
          dailyEarnings: { $sum: "$fare" }
        }
      }
    ]);
    
    const dailyStats = tripsAggregate.length > 0 
      ? { 
          dailyTripsCount: tripsAggregate[0].dailyTripsCount, 
          dailyEarnings: tripsAggregate[0].dailyEarnings 
        }
      : { dailyTripsCount: 0, dailyEarnings: 0 };
    
    res.status(200).json({
      success: true,
      data: dailyStats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};