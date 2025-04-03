const User = require('../models/User');
const bcrypt = require('bcryptjs');

// إنشاء مستخدم جديد
const createUser = async (req, res) => {
  const { fullName, email, phone, password, confirmPassword, role, gender, taxiOffice } = req.body;

  if (!fullName || !phone || !email || !password || !role || !gender) {
    return res.status(400).json({ message: 'Please provide all required fields' });
  }

  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }

  try {
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) {
      return res.status(400).json({ message: 'Phone number or Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ fullName, email, phone, password: hashedPassword, role, gender, taxiOffice });
    await newUser.save();
    res.status(201).json({ message: 'User created successfully', newUser });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating user', error });
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

module.exports = { createUser, loginUser, getUsers };