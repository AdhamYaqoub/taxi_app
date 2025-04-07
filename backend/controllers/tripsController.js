const Trip = require('../models/Trip');

const RATE_PER_KM = 10;

// إنشاء طلب رحلة جديدة من قبل المستخدم
exports.createTrip = async (req, res) => {
  try {
    const { userId, startLocation, endLocation, distance } = req.body;
    const estimatedFare = distance * RATE_PER_KM;

    const newTrip = new Trip({
      userId,
      startLocation,
      endLocation,
      distance,
      estimatedFare
    });

    await newTrip.save();
    res.status(201).json(newTrip);
  } catch (err) {
    res.status(500).json({ error: 'فشل إنشاء الرحلة', details: err.message });
  }
};

// قبول الرحلة من قبل السائق
exports.acceptTrip = async (req, res) => {
  try {
    const { tripId } = req.params;
    const { driverId } = req.body;

    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'pending') {
      return res.status(400).json({ 
        error: 'الرحلة غير متاحة للقبول' 
      });
    }

    trip.driverId = driverId;
    trip.status = 'accepted';
    trip.startTime = new Date(); // يمكن نقله لمرحلة startTrip إذا أردت
    
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

    trip.status = 'in_progress';
    trip.startTime = new Date(); // إذا لم يتم تحديده سابقاً
    
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
exports.completeTrip = async (req, res) => {
  try {
    const { tripId } = req.params;

    const trip = await Trip.findOne({ tripId });

    if (!trip || trip.status !== 'in_progress') {
      return res.status(400).json({ error: 'لا يمكن إنهاء الرحلة في هذه الحالة' });
    }

    trip.status = 'completed';
    trip.endTime = new Date();
    trip.actualFare = trip.distance * RATE_PER_KM;

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
    console.log(trips);
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
