// استيراد الحزم
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const bodyParser = require('body-parser');
const http = require('http');

// استيراد اتصال قاعدة البيانات
const db = require('./config/db');

// استيراد المسارات (routes)
const userRoutes = require('./routes/userRoutes');
// const driverRoutes = require('./routes/driverRoutes');
const tripRoutes = require('./routes/tripsRoutes');
// const tripRequestRoutes = require('./routes/tripRequests'); 
const driver = require('./routes/driverRoutes');

// إعداد السوكيت
const { init } = require('./config/socket');

// تحميل ملف البيئة
dotenv.config();

// إعداد السيرفر
const app = express();
const server = http.createServer(app); 

// تهيئة السوكيت
init(server); 

// Middlewares
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE']
}));

// الاتصال بقاعدة البيانات
db();

// مسارات API
app.use('/api/users', userRoutes);
// app.use('/api/drivers', driverRoutes);
app.use('/api/trips', tripRoutes);
// app.use('/api/trip-requests', tripRequestRoutes); 
app.use('/api/drivers', driver);

// Route for health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// معالجة الأخطاء المركزية
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// بدء السيرفر
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});