const User = require('../models/User');
const Driver = require('../models/Driver');
const Client = require('../models/client');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
// إنشاء مستخدم جديد
// إنشاء مستخدم جديد (مع إنشاء ملف سائق إذا كان الدور 'Driver')
// controllers/userController.js (أو authController.js)



const createUser = async (req, res) => {
  const {
    fullName, email, phone, password, confirmPassword, role, gender,
    taxiOffice, carModel, carPlateNumber, carColor,
  } = req.body;

  // التحقق من المدخلات
  if (!fullName || !phone || !email || !password || !role || !gender) {
    return res.status(400).json({ message: 'Please provide all required user fields' });
  }
  if (role === 'Driver' && !taxiOffice) {
    return res.status(400).json({ message: 'Taxi office is required for drivers' });
  }
  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }

  try {
    // التأكد إن المستخدم مش موجود
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) {
      return res.status(400).json({ message: 'Phone number or Email already exists' });
    }

    // تشفير كلمة المرور
    const hashedPassword = await bcrypt.hash(password, 10);

    // إنشاء المستخدم
    const newUser = new User({ fullName, email, phone, password: hashedPassword, role, gender });
    const savedUser = await newUser.save();

    // إنشاء سجل للسائق إذا كان الدور Driver
    if (role === 'Driver') {
      try {
        const newDriver = new Driver({
          user: savedUser._id,
          driverUserId: savedUser.userId,
          taxiOffice: taxiOffice || 'غير محدد',
          carDetails: {
            model: carModel || 'N/A',
            plateNumber: carPlateNumber || 'N/A',
            color: carColor || 'N/A',
          },
        });
        await newDriver.save();
      } catch (driverError) {
        await User.findByIdAndDelete(savedUser._id);
        return res.status(500).json({ message: 'Error creating driver profile', error: driverError.message });
      }
    } else if (role === 'User') {
      // إنشاء سجل للعميل
      try {
        const newClient = new Client({
          user: savedUser._id,
          clientUserId: savedUser.userId,
        });
        await newClient.save();
      } catch (clientError) {
        await User.findByIdAndDelete(savedUser._id);
        return res.status(500).json({ message: 'Error creating client profile', error: clientError.message });
      }
    }

    // const token = jwt.sign(
    //   { id: savedUser._id, role: savedUser.role },
    //   process.env.JWT_SECRET,
    //   { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    // );

        // user.token = token;
        // await user.save();

    const userResponse = { ...savedUser._doc };
    delete userResponse.password;


    res.status(201).json({
      message: 'User created successfully',
      user: userResponse,
      //token,
    });

  } catch (error) {
    console.error("Error during user creation process:", error);
    res.status(500).json({ message: 'Error creating user', error: error.message });
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

    // ✅ توليد JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    );
user.token = token;
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
    const userId = req.body._Id; // استقبل userId من البودي
    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId is required' });
    }

    await User.findByIdAndUpdate(userId, { token: null });

    res.status(200).json({ success: true, message: 'تم تسجيل الخروج بنجاح.' });
  } catch (error) {
    console.error('خطأ في تسجيل الخروج:', error);
    res.status(500).json({ success: false, message: 'فشل تسجيل الخروج.' });
  }
};


module.exports = { logoutUser };


// استرجاع جميع المستخدمين
const getUsers = async (req, res) => {
  try {
    const users = await User.find();
    res.status(200).json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching users', error });
  }
};
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

    const user = await User.findById(userId).select('fullName');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ fullName: user.fullName });

  } catch (error) {
    console.error("Error fetching full name:", error);
    res.status(500).json({ message: 'Failed to get full name', error: error.message });
  }
};

module.exports = { createUser, loginUser, getUsers, logoutUser,getPrintFullName };