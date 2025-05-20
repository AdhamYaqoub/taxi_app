
const Driver = require('../models/Driver');

exports.getAllDrivers = async (req, res) => {
  try {
    // نستخدم find({}) بدون شروط لجلب كل السائقين
    const allDrivers = await Driver.find({})
      .populate({
        path: 'user',
        select: 'fullName userId email phone' // اختر الحقول التي تريدها من نموذج User
      })
      // اختر الحقول التي تريدها من نموذج Driver
      .select('user carDetails rating numberOfRatings profileImageUrl taxiOffice isAvailable earnings')
      .lean(); // .lean() للحصول على كائنات JavaScript بسيطة أسرع
    res.status(200).json(allDrivers); // أرسل قائمة جميع السائقين

  } catch (error) {
    console.error("Error fetching all drivers:", error);
    res.status(500).json({ message: "حدث خطأ أثناء جلب جميع السائقين", error: error.message });
  }
};

exports.getAvailableDrivers = async (req, res) => {
  try {
    const availableDrivers = await Driver.find({ isAvailable: true })
  
      .populate({
        path: 'user',           
        select: 'fullName userId email phone' 
                                    
      })
      .select('user carDetails rating numberOfRatings profileImageUrl taxiOffice isAvailable')
      .lean();

    res.status(200).json(availableDrivers);

  } catch (error) {
    console.error("Error fetching available drivers:", error);
    res.status(500).json({ message: "حدث خطأ أثناء جلب السائقين المتاحين", error: error.message });
  }
};


exports.getDriverById = async (req, res) => {
  try {
    const driverId = req.params.id;

    // البحث باستخدام driverUserId بدلاً من _id
    const driver = await Driver.findOne({ driverUserId: driverId })
      .populate({
        path: 'user',
        select: 'fullName userId email phone profilePhoto'
      })
      .select('user carDetails rating taxiOffice isAvailable currentLocation')
      .lean();

    if (!driver) {
      return res.status(404).json({ message: "لم يتم العثور على السائق" });
    }

    // تحسين هيكل البيانات المرتجع
    const response = {
      ...driver,
      user: {
        ...driver.user,
        profilePhoto: driver.user.profilePhoto 
          ? `${req.protocol}://${req.get('host')}/uploads/${driver.user.profilePhoto}`
          : null
      }
    };

    res.status(200).json(response);

  } catch (error) {
    console.error("Error fetching driver by ID:", error);
    res.status(500).json({ 
      message: "حدث خطأ أثناء جلب بيانات السائق",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// في ملف routes/drivers.js
exports.updateAvailability = async (req, res) => {
  try {
    const { id } = req.params;
    const { isAvailable } = req.body;

    // البحث باستخدام findById أولاً للتحقق
    // التحديث
    const updatedDriver = await Driver.findOneAndUpdate(
      {driverUserId: id},
      { isAvailable },
      { new: true }
    );
    if (!updatedDriver) {
      return res.status(404).json({ message: 'Driver not found' });
    }


    res.status(200).json(updatedDriver);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateDriverProfileImage = async (req, res) => {
  try {
    const { id } = req.params;
    const { profileImageUrl } = req.body;

    const updatedDriver = await Driver.findOneAndUpdate(
      { driverUserId: id },
      { profileImageUrl },
      { new: true }
    );

    if (!updatedDriver) {
      return res.status(404).json({ message: 'Driver not found' });
    }

    res.status(200).json(updatedDriver);
  } catch (error) {
    console.error("Error updating driver profile image:", error);
    res.status(500).json({ message: error.message });
  }
};

