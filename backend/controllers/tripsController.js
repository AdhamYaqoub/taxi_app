const Trip = require('../models/Trip');
const Driver = require('../models/Driver');
const RATE_PER_KM = 10;
const MAX_ACCEPTED_TRIPS = 3;


// إنشاء طلب رحلة جديدة من قبل المستخدم
exports.createTrip = async (req, res) => {
  try {
    const { userId, startLocation, endLocation, distance, startTime, paymentMethod } = req.body;

    // تحويل الموقع من نص إلى إحداثيات (سيتطلب خدمة Geocoding)
    const estimatedFare = distance * RATE_PER_KM;

    const newTrip = new Trip({
      userId,
      startLocation: {
        type: "Point",
        coordinates: [startLocation.longitude, startLocation.latitude],
        address: startLocation.address
      },
      endLocation: {
        type: "Point",
        coordinates: [endLocation.longitude, endLocation.latitude],
        address: endLocation.address
      },
      paymentMethod,
      distance,
      estimatedFare,
      startTime: startTime ? new Date(startTime) : undefined
    });
    await newTrip.save();
    res.status(201).json(newTrip);
  } catch (err) {
    res.status(500).json({ error: 'فشل إنشاء الرحلة', details: err.message });
  }
};

// قبول الرحلة من قبل السائق
// تعديل دالة قبول الرحلة لإضافة الحد الأقصى
exports.acceptTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const { driverId } = req.body;

    // التحقق من عدد الرحلات المقبولة بالفعل
    const acceptedTripsCount = await Trip.countDocuments({ 
      driverId, 
      status: { $in: ['accepted', 'in_progress'] }
    });

    if (acceptedTripsCount >= MAX_ACCEPTED_TRIPS) {
      return res.status(400).json({ 
        error: `لا يمكنك قبول أكثر من ${MAX_ACCEPTED_TRIPS} رحلات في نفس الوقت` 
      });
    }

    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'pending') {
      return res.status(400).json({ 
        error: 'الرحلة غير متاحة للقبول' 
      });
    }

    trip.driverId = driverId;
    trip.status = 'accepted';
    
    await trip.save();
    res.json(trip);
  } catch (err) {
    res.status(500).json({ 
      error: 'فشل قبول الرحلة', 
      details: err.message 
    });
  }
};

// بدء الرحلة (الانتقال من accepted إلى in_progress)
exports.startTrip = async (req, res) => {
  try {
    const { tripId } = req.params;

    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'accepted') {
      return res.status(400).json({
        error: 'لا يمكن بدء الرحلة إلا إذا كانت مقبولة'
      });
    }
    const now = new Date();

    // تأكد من مقارنة التواريخ باستخدام timestamps (بالمللي ثانية)
    if (trip.startTime && now.getTime() < new Date(trip.startTime).getTime()) {
      return res.status(400).json({
        error: 'لا يمكن بدء الرحلة قبل موعدها المجدول'
      });
    }

    // التحقق من وجود رحلة حالية للسائق
    const existingTrip = await Trip.findOne({
      driverId: trip.driverId,
      status: 'in_progress'
    });

    if (existingTrip) {
      return res.status(400).json({
        error: 'لا يمكنك بدء رحلة جديدة قبل إنهاء الرحلة الحالية'
      });
    }

    // تحديث الحالة
    trip.status = 'in_progress';
    trip.startTime = new Date();

    await trip.save();
    res.json(trip);
  } catch (err) {
    res.status(500).json({
      error: 'فشل بدء الرحلة',
      details: err.message
    });
  }
};


// رفض الرحلة من قبل السائق
exports.rejectTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const { cancellationReason } = req.body;

    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'pending') {
      return res.status(400).json({ error: 'الرحلة غير متاحة للرفض' });
    }

    trip.status = 'rejected';
    trip.cancellationReason = cancellationReason || 'رفض من السائق';

    await trip.save();
    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: 'فشل رفض الرحلة', details: err.message });
  }
};

// إتمام الرحلة من قبل السائق (تحديث السعر الفعلي)
// إتمام الرحلة من قبل السائق (تحديث السعر الفعلي وإضافة الأرباح للسائق)
// إتمام الرحلة من قبل السائق (تحديث السعر الفعلي وإضافة الأرباح للسائق)
exports.completeTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'in_progress') {
      return res.status(400).json({ error: 'لا يمكن إنهاء الرحلة في هذه الحالة' });
    }

    const fare = trip.distance * RATE_PER_KM;
    trip.status = 'completed';
    trip.endTime = new Date();
    trip.actualFare = fare;

    if (trip.driverId) {
      const driver = await Driver.findOne({ driverUserId: trip.driverId });
      if (driver) {
        // زيادة أرباح السائق
        driver.earnings += fare;
        await driver.save();
      }
    }

    await trip.save();
    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: 'فشل إنهاء الرحلة', details: err.message });
  }
};

// جميع رحلات سائق معيّن
// exports.getDriverTrips = async (req, res) => {
//   try {
//     const { driverId } = req.params;
//     const trips = await Trip.find({ driverId })
//     res.json(trips);
//   } catch (err) {
//     res.status(500).json({ error: 'فشل جلب الرحلات', details: err.message });
//   }
// };

// آخر 3 رحلات فقط لسائق معيّن
exports.getDriverRecentTrips = async (req, res) => {
  try {
    const { driverId } = req.params;
    const trips = await Trip.find({ driverId })
                            .sort({ createdAt: -1 })
                            .limit(3);
    res.json(trips);
  } catch (err) {
    res.status(500).json({ error: 'فشل جلب الرحلات الأخيرة', details: err.message });
  }
};
exports.getDriverTripsByStatus = async (req, res) => {
  try {
    const { driverId } = req.params;
    const { status } = req.query;

    const query = { driverId };
    if (status) query.status = status;

    const trips = await Trip.find(query).sort({ createdAt: -1 });
    res.json(trips);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getUserTripsByStatus = async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.query;
    console.log('User ID:', userId, 'Status:', status); // Log the userId and status for debugging

    const query = { userId };
    if (status) query.status = status;

    const trips = await Trip.find(query)
      .populate('driverId', 'name phone carModel licensePlate')
      .sort({ createdAt: -1 });
      
    res.json(trips);
    console.log('User trips:', trips); // Log the trips for debugging
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};



exports.getDriverTrips = async (req, res) => {
  try {
    const query = { driverId: req.params.driverId };
    // Add status filter if provided
    if (req.query.status) {
      query.status = req.query.status;
    }


    const trips = await Trip.find(query) // Sort by newest first

    res.json(trips);
  } catch (error) {
    console.error('Error getting trips:', error);
    res.status(500).json({ error: 'فشل جلب الرحلات', details: err.message });
  }
};
////////////////////////////
////////////////////////////
// exports.getDriverTrips = async (req, res) => {
//   try {
//     const { driverId } = req.params;
//     const trips = await Trip.find({ driverId })
//     res.json(trips);
//   } catch (err) {
//     res.status(500).json({ error: 'فشل جلب الرحلات', details: err.message });
//   }
// };

exports.updateTripStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['pending', 'accepted', 'rejected', 'in_progress', 'completed', 'canceled'];

    // Validate status
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status value'
      });
    }

    const trip = await Trip.findByIdAndUpdate(
      req.params.tripId,
      { status },
      { new: true, runValidators: true }
    );

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    res.status(200).json({
      success: true,
      data: trip
    });
  } catch (error) {
    console.error('Error updating trip status:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

 exports.getPendingTrips = async (req, res) => {
  try {
    const trips = await Trip.find({ 
      status: 'pending',
      driverId: { $exists: false } // التأكد من عدم وجود سائق معين
    })
    res.json(trips);
  } catch (error) {
    console.error('Error getting pending trips:', error);
    res.status(500).json({ error: 'فشل جلب الرحلات', details: err.message });
  }
};

// دالة مساعدة لحساب المسافة بين نقطتين
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // نصف قطر الأرض بالكيلومترات
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}


// الحصول على الرحلات القريبة من موقع السائق
exports.getNearbyTrips = async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    console.log('Latitude:', latitude, 'Longitude:', longitude);
    const maxDistance = req.query.maxDistance || 90; // المسافة القصوى بالكيلومترات (5 كم افتراضياً)

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'يجب توفير خط الطول والعرض' });
    }

    // جلب جميع الرحلات المعلقة
    const pendingTrips = await Trip.find({ 
      status: 'pending',
      driverId: { $exists: false }
    });

    // تصفية الرحلات بناءً على المسافة
    const nearbyTrips = pendingTrips.filter(trip => {
      if (!trip.startLocation || !trip.startLocation.coordinates) return false;
      
      const [tripLon, tripLat] = trip.startLocation.coordinates;
      const distance = calculateDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        tripLat,
        tripLon
      );
      
      return distance <= maxDistance;
    });

    // إذا لم توجد رحلات قريبة، نعيد جميع الرحلات مع توسيع نطاق البحث
    if (nearbyTrips.length === 0) {
      const allPendingTrips = await Trip.find({
        status: 'pending',
        driverId: { $exists: false }
      }).limit(10); // تحديد عدد الرحلات المراد عرضها
      console.log('No nearby trips found, showing all pending trips:', allPendingTrips.length);
      return res.json({
        message: 'لا توجد رحلات قريبة، تم عرض رحلات من مناطق أخرى',
        trips: allPendingTrips
      });
    }

    console.log('Nearby trips found:', nearbyTrips.length);

    res.json({
      message: `تم العثور على ${nearbyTrips.length} رحلة ضمن ${maxDistance} كم`,
      trips: nearbyTrips
    });
  } catch (err) {
    res.status(500).json({ 
      error: 'فشل جلب الرحلات القريبة', 
      details: err.message 
    });
  }
};
exports.getPendingUserTrips = async (req, res) => {
  try {
    const { userId } = req.query;
    const trips = await Trip.find({ 
      userId,
      status: 'pending'
    });
    res.json(trips);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.cancelTrip = async (req, res) => {
  try {
    const { id } = req.params;
    const trip = await Trip.findOneAndDelete({ tripId: id });
    if (!trip) {
      return res.status(404).json({ message: 'الرحلة غير موجودة' });
    }
    
    res.json({ message: 'تم إلغاء الرحلة' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateTrip = async (req, res) => {
  try {
    const { id } = req.params;
    const { startLocation, endLocation } = req.body;


    const updateData = {
      updatedAt: new Date()
    };

    if (startLocation.address) {
      updateData['startLocation.address'] = startLocation.address;
    }

    // تحديث موقع النهاية إذا وجد
    if (endLocation.address) {
      updateData['endLocation.address'] = endLocation.address;
    }

    const trip = await Trip.findOneAndUpdate(
      { tripId: id }, 
      { $set: updateData }, 
      { 
        new: true,
        runValidators: true 
      }
    );

    if (!trip) {
      return res.status(404).json({ message: 'الرحلة غير موجودة' });
    }

    console.log('Trip updated successfully:', trip);
    res.json({ 
      success: true,
      message: 'تم تحديث الرحلة بنجاح',
      data: trip 
    });

  } catch (error) {
    console.error('Error updating trip:', error);
    res.status(500).json({ 
      success: false,
      message: 'فشل في تحديث الرحلة',
      error: error.message 
    });
  }
};