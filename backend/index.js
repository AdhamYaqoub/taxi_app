// استيراد الحزم
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const bodyParser = require('body-parser');

// استيراد اتصال قاعدة البيانات
const db = require('./config/db');

// استيراد المسارات (routes)
const userRoutes = require('./routes/userRoutes');

const driverRoutes = require('./routes/tripsRoutes');

const tripRoutes = require('./routes/tripsRoutes');


// تحميل ملف البيئة
dotenv.config();

// إعداد السيرفر
const app = express();
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// الاتصال بقاعدة البيانات
db();

// استخدام المسارات الخاصة بالمستخدم
app.use('/api/users', userRoutes);
// استخدام المسارات الخاصة بالسائق
app.use('/api/drivers', driverRoutes);

// استخدام المسارات الخاصة بالرحلات
app.use('/api', tripRoutes);  // مسارات الرحلات

// بدء السيرفر
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
