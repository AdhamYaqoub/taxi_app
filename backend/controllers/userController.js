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
    officeIdentifier, carModel, carPlateNumber, carColor, carYear,
    licenseNumber, licenseExpiry, profileImageUrl
  } = req.body;

  if (!fullName || !phone || !email || !password || !role || !gender) {
    return res.status(400).json({ message: 'الرجاء تقديم جميع الحقول المطلوبة' });
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'كلمات المرور غير متطابقة' });
  }

  if (role === 'Driver') {
    const requiredDriverFields = ['officeIdentifier', 'licenseNumber', 'licenseExpiry', 'carPlateNumber', 'carModel'];
    const missingFields = requiredDriverFields.filter(field => !req.body[field]);

    if (missingFields.length > 0) {
      return res.status(400).json({
        message: `الحقول المطلوبة للسائق: ${missingFields.join(', ')}`,
        missingFields
      });
    }
  }

  try {
    // تحقق من وجود المستخدم مسبقًا
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'رقم الهاتف أو البريد الإلكتروني موجود مسبقاً'
      });
    }

    // تحقق من وجود المكتب إذا كان سائقًا
    let office = null;
    if (role === 'Driver') {
      office = await TaxiOffice.findOne({ officeIdentifier: officeIdentifier });
      if (!office) {
        return res.status(404).json({
          success: false,
          message: 'مكتب التكاسي غير موجود'
        });
      }
    }

    // كل التحققات ناجحة – نبدأ بإنشاء الكائنات
    const hashedPassword = await bcrypt.hash(password, 12);

    const newUser = new User({
      fullName,
      email,
      phone,
      password: hashedPassword,
      role,
      gender,
      mustChangePassword: role === 'Driver',
      profileImageUrl: profileImageUrl || undefined
    });

    let newDriver = null;
    let newClient = null;

    if (role === 'Driver') {
      newDriver = new Driver({
        user: newUser._id, // مؤقتًا، سيتم تعيينه بعد حفظ المستخدم
        driverUserId: newUser.userId,
        office: office._id,
        officeIdentifier: officeIdentifier,
        carDetails: {
          model: carModel,
          plateNumber: carPlateNumber,
          color: carColor || 'غير محدد',
          year: carYear || new Date().getFullYear()
        },
        licenseNumber,
        licenseExpiry: new Date(licenseExpiry),
        isAvailable: false,
        rating: 80,
        numberOfRatings: 0,
        profileImageUrl: profileImageUrl || undefined,
        earnings: 0
      });
    } else if (role === 'User') {
      newClient = new Client({
        user: newUser._id,
        clientUserId: newUser.userId
      });
    }

    // 🔒 نحفظ المستخدم أولاً
    const savedUser = await newUser.save();

    // 🧾 ثم نحفظ السائق أو العميل
    if (role === 'Driver') {
      newDriver.user = savedUser._id;
      newDriver.driverUserId = savedUser.userId;
      await newDriver.save();
      await sendWelcomeEmail(savedUser, {
        officeName: office.name,
        licenseNumber: licenseNumber
      });
    } else if (role === 'User') {
      newClient.user = savedUser._id;
      newClient.clientUserId = savedUser.userId;
      await newClient.save();
      await sendWelcomeEmail(savedUser);
    }

    // نجهز الرد النهائي
    const userResponse = savedUser.toObject();
    delete userResponse.password;

    res.status(201).json({
      success: true,
      message: 'تم إنشاء المستخدم بنجاح',
      user: userResponse,
      ...(role === 'Driver' && {
        driverDetails: {
          licenseNumber,
          carPlateNumber,
          officeName: office?.name
        }
      })
    });

  } catch (error) {
    console.error("Error during user creation:", error);
    res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء إنشاء المستخدم',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
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