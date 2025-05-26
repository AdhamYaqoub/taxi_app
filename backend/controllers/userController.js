const User = require('../models/User');
const Driver = require('../models/Driver');
const Client = require('../models/client');
const TaxiOffice = require('../models/TaxiOffice');
const { sendWelcomeEmail } = require('../utils/emailService');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// إنشاء مستخدم جديد
// إنشاء مستخدم جديد (مع إنشاء ملف سائق إذا كان الدور 'Driver')
// controllers/userController.js (أو authController.js)



const createUser = async (req, res) => {
  const {
    fullName, email, phone, password, confirmPassword, role, gender,
    officeId, carModel, carPlateNumber, carColor, carYear,
    licenseNumber, licenseExpiry
  } = req.body;

  // التحقق من المدخلات الأساسية
  if (!fullName || !phone || !email || !password || !role || !gender) {
    return res.status(400).json({ message: 'الرجاء تقديم جميع الحقول المطلوبة' });
  }

  // تحقق من حقول السائق الإضافية
  if (role === 'Driver') {
    if (!officeId || !licenseNumber || !licenseExpiry || !carPlateNumber) {
      return res.status(400).json({ 
        message: 'مطلوب: مكتب التكاسي، رقم الرخصة، تاريخ انتهاء الرخصة، ورقم لوحة السيارة'
      });
    }
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'كلمات المرور غير متطابقة' });
  }

  try {
    // التحقق من وجود المستخدم
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) {
      return res.status(400).json({ message: 'رقم الهاتف أو البريد الإلكتروني موجود مسبقاً' });
    }

    // التحقق من وجود المكتب إذا كان سائقاً
    let office = null;
    if (role === 'Driver') {
      office = await TaxiOffice.findOne({ officeId: officeId });
      if (!office) {
        return res.status(404).json({ message: 'مكتب التكاسي غير موجود' });
      }
    }

    // إنشاء المستخدم
    const hashedPassword = await bcrypt.hash(password, 12);
    const newUser = new User({ 
      fullName, 
      email, 
      phone, 
      password: hashedPassword, 
      role, 
      gender,
      mustChangePassword: role === 'Driver' // إجبار السائقين على تغيير كلمة المرور
    });

    const savedUser = await newUser.save();

    // إنشاء السجل المناسب حسب الدور
    if (role === 'Driver') {
      try {
        const newDriver = new Driver({
          user: savedUser._id,
          driverUserId: savedUser.userId,
          office: office._id,
          officeId: office.officeId,
          carDetails: {
            model: carModel || 'غير محدد',
            plateNumber: carPlateNumber,
            color: carColor || 'غير محدد',
            year: carYear || new Date().getFullYear()
          },
          licenseNumber,
          licenseExpiry: new Date(licenseExpiry),
          isAvailable: false // غير متاح حتى يكمل ملفه الشخصي
        });

        await newDriver.save();

        // تحديث عدد السائقين في المكتب
        await TaxiOffice.findByIdAndUpdate(office._id, {
          $inc: { driversCount: 1 }
        });

      } catch (driverError) {
        await User.findByIdAndDelete(savedUser._id);
        return res.status(500).json({ 
          message: 'خطأ في إنشاء ملف السائق',
          error: driverError.message 
        });
      }
    } else if (role === 'User') {
      try {
        const newClient = new Client({
          user: savedUser._id,
          clientUserId: savedUser.userId,
        });
        await newClient.save();
      } catch (clientError) {
        await User.findByIdAndDelete(savedUser._id);
        return res.status(500).json({ 
          message: 'خطأ في إنشاء ملف العميل',
          error: clientError.message 
        });
      }
    }


    if (role === 'Driver') {
      await sendWelcomeEmail(savedUser, {
        officeName: office.name,
        licenseNumber: licenseNumber
      });
    } else {
      await sendWelcomeEmail(savedUser);
    }

    // إعداد الرد النهائي
    const userResponse = savedUser.toObject();
    delete userResponse.password;

    res.status(201).json({
      success: true,
      message: 'تم إنشاء المستخدم بنجاح',
      user: userResponse
    });

  } catch (error) {
    console.error("Error during user creation:", error);
    res.status(500).json({ 
      success: false,
      message: 'حدث خطأ أثناء إنشاء المستخدم',
      error: error.message 
    });
  }
};

// تسجيل الدخول


const loginUser = async (req, res) => {
  const { phone, password } = req.body;

  if (!phone || !password) {
    return res.status(400).json({ message: 'Please provide phone and password' });
  }

  try {
    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    );

    // ✅ تحديث الحالة
    user.token = token;
    user.isLoggedIn = true;
    await user.save();

    const userResponse = { ...user._doc };
    delete userResponse.password;

    res.status(200).json({ message: 'Login successful', user: userResponse, token });

  } catch (error) {
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
};


// const logoutUser = (req, res) => {
//   res.clearCookie('token'); // اسم الكوكي اللي فيه التوكن
//   res.status(200).json({ message: 'Logged out successfully' });
// };




const logoutUser = async (req, res) => {
  try {
    const userId = req.body.Id; // استقبل userId من البودي
    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId is required' });
    }

    const user = await User.findOneAndUpdate(
      { userId: userId },
      { token: null, isLoggedIn: false }, // ✅ تحديث isLoggedIn
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({ success: true, message: 'تم تسجيل الخروج بنجاح.' });

  } catch (error) {
    console.error('خطأ في تسجيل الخروج:', error);
    res.status(500).json({ success: false, message: 'فشل تسجيل الخروج.' });
  }
};



module.exports = { logoutUser };


// استرجاع جميع المستخدمين
// const getUsers = async (req, res) => {
//   try {
//     const users = await User.find();
//     res.status(200).json(users);
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: 'Error fetching users', error });
//   }
// };
// const getUsers = async (filter = {}) => {
//   try {
//     const users = await User.find(filter);  // تطبيق الفلتر إن وجد
//     return users;
//   } catch (error) {
//     throw new Error('Error fetching users');
//   }
// };

// جلب الاسم الكامل للمستخدم بواسطة ID
const getPrintFullName = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    const user = await User.findOne({userId: userId}).select('fullName');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ fullName: user.fullName });

  } catch (error) {
    console.error("Error fetching full name:", error);
    res.status(500).json({ message: 'Failed to get full name', error: error.message });
  }
};

const getUsers = async (req, res) => {
  try {
    const { loggedInOnly } = req.query;

    let filter = {};
    if (loggedInOnly === 'true') {
      filter.isLoggedIn = true;
    }

    const users = await User.find(filter);
    res.status(200).json(users);

  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Error fetching users', error });
  }
};


const getUserById = async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await User.findOne({userId: userId}).select('role _id isLoggedIn');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      user: {
        id: user._id,
        role: user.role,
        isLoggedIn: user.isLoggedIn
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};



module.exports = { createUser, loginUser, getUsers, logoutUser,getPrintFullName, getUserById };