const Trip = require('../models/Trip');
const User = require('../models/User');

// إضافة رحلة جديدة
const addTrip = async (req, res) => {
  const { driverUserId, startLocation, endLocation, distance, startTime, endTime } = req.body;

  try {
    // البحث عن السائق باستخدام userId بدلًا من _id
    const driver = await User.findOne({ userId: driverUserId });

    if (!driver || driver.role !== 'Driver') {
      return res.status(400).json({ message: 'Invalid driver' });
    }

    const trip = new Trip({
      driverId: driver.userId,
      startLocation,
      endLocation,
      distance,
      startTime,
      endTime,
      earnings: distance * 10, // فرضًا أن الأرباح هي 10 لكل كيلومتر
    });

    await trip.save();
    res.status(201).json({ message: 'Trip added successfully', trip });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding trip' });
  }
};

// تحديث حالة الرحلة
const updateTripStatus = async (req, res) => {
  const { tripId, status } = req.body;


  try {
   const trip = await Trip.findOne({ tripId: Number(tripId) });

    // const driver = await User.findOne({ userId: driverUserId });
    if (!trip) {
      return res.status(400).json({ message: 'Trip not found' });
    }

    trip.status = status;
    await trip.save();
    res.status(200).json({ message: 'Trip status updated', trip });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating trip status' });
  }
};

// الحصول على جميع الرحلات الخاصة بسائق باستخدام userId
const getDriverTrips = async (req, res) => {
    try {
        const driverUserId = Number(req.params.userId); // تحويل الرقم إلى عدد صحيح

        if (isNaN(driverUserId)) {
            return res.status(400).json({ message: "Invalid driver ID" });
        }

        // البحث عن السائق باستخدام `userId`
        const driver = await User.findOne({ userId: driverUserId });

        if (!driver) {
            return res.status(404).json({ message: "Driver not found" });
        }

        // جلب الرحلات باستخدام `userId` كسائق
        const trips = await Trip.find({ driverId: driver.userId });

        res.status(200).json({ trips });
    } catch (error) {
        console.error("Error fetching trips:", error);
        res.status(500).json({ message: "Error fetching trips" });
    }
};


module.exports = { addTrip, updateTripStatus, getDriverTrips };
