// استيراد الحزم
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');  // استيراد مكتبة CORS

// تحميل ملف البيئة
dotenv.config();

// إعداد السيرفر
const app = express();
app.use(express.json());  // لتفسير البيانات المرسلة من العميل

// تفعيل CORS لجميع المصادر (أو يمكنك تحديد مصادر معينة)
app.use(cors());  // تفعيل CORS لجميع المصادر

// الاتصال بقاعدة البيانات
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected successfully'))
  .catch(err => console.log('MongoDB connection error:', err));

// تعريف نموذج المستخدم
const User = mongoose.model('User', new mongoose.Schema({
  fullName: String,
  phone: String,
}));

// نقطة النهاية لإضافة مستخدم جديد
app.post('/signup', async (req, res) => {
  const { fullName, phone } = req.body;
  try {
    const newUser = new User({ fullName, phone });
    await newUser.save();
    res.status(201).json({ message: 'User created successfully', newUser });
  } catch (error) {
    res.status(500).json({ message: 'Error creating user', error });
  }
});

// بدء السيرفر
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
