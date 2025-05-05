const User = require('../models/User');
const Driver = require('../models/Driver');
const bcrypt = require('bcryptjs');

// إنشاء مستخدم جديد
// إنشاء مستخدم جديد (مع إنشاء ملف سائق إذا كان الدور 'Driver')
// controllers/userController.js (أو authController.js)


const createUser = async (req, res) => {
  const {
    fullName, email, phone, password, confirmPassword, role, gender,
    taxiOffice, carModel, carPlateNumber, carColor,
  } = req.body;

  // --- التحقق الأساسي (نفسه كما كان) ---
  if (!fullName || !phone || !email || !password || !role || !gender) {
     return res.status(400).json({ message: 'Please provide all required user fields' });
  }
  // ملاحظة: تأكد من إزالة التحقق من taxiOffice من نموذج User.js
  if (role === 'Driver' && !taxiOffice) {
     return res.status(400).json({ message: 'Taxi office is required for drivers' });
  }
  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }

  try {
    // --- التحقق من وجود المستخدم ---
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) {
      return res.status(400).json({ message: 'Phone number or Email already exists' });
    }

    // --- تشفير كلمة المرور ---
    const hashedPassword = await bcrypt.hash(password, 10);

    // --- إنشاء وحفظ المستخدم الأساسي ---
    const newUser = new User({ fullName, email, phone, password: hashedPassword, role, gender });
    const savedUser = await newUser.save(); // *** هنا يتم إنشاء userId الرقمي بواسطة mongoose-sequence ***

    // --- إنشاء سجل السائق إذا كان الدور 'Driver' ---
    if (role === 'Driver') {
      console.log(`User role is Driver. Creating driver profile for user ID: ${savedUser._id}, Numeric UserID: ${savedUser.userId}`); // <-- إضافة userId للسجل
      try {
        const newDriverData = {
          user: savedUser._id,              // <-- الربط الأساسي باستخدام ObjectId
          driverUserId: savedUser.userId,   // <-- *** تخزين userId الرقمي هنا ***
          taxiOffice: taxiOffice || 'غير محدد',
          carDetails: {
            model: carModel || 'N/A',
            plateNumber: carPlateNumber || 'N/A',
            color: carColor || 'N/A',
          },
          // باقي الحقول ستأخذ قيمها الافتراضية
        };

        const newDriver = new Driver(newDriverData);
        await newDriver.save();
        console.log(`Driver profile created successfully for user ID: ${savedUser._id}`);

      } catch (driverError) {
        console.error(`Failed to create driver profile for user ${savedUser._id}:`, driverError);
        await User.findByIdAndDelete(savedUser._id); // Rollback user creation
        console.log(`User ${savedUser._id} deleted due to failed driver profile creation.`);
        return res.status(500).json({ message: 'Error creating driver profile, user registration rolled back.', error: driverError.message });
      }
    }

    // --- إرجاع استجابة النجاح ---
    const userResponse = { ...savedUser._doc };
    delete userResponse.password;
    res.status(201).json({ message: 'User created successfully', user: userResponse });

  } catch (error) {
    console.error("Error during user creation process:", error);
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
};

// تسجيل الدخول
const loginUser = async (req, res) => {
  const { phone, email, password } = req.body;

  if (!phone && !email) {
    return res.status(400).json({ message: 'Please provide either phone or email' });
  }

  try {
    const user = await User.findOne({ $or: [{ phone }, { email }] });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({ message: 'User signed in successfully', user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error signing in', error });
  }
};

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
module.exports = { createUser, loginUser, getUsers };