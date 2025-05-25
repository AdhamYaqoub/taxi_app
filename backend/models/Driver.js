// models/Driver.js
const mongoose = require('mongoose');

const driverSchema = new mongoose.Schema({
  user: { // <-- حقل العلاقة الأساسي (يستخدم _id/ObjectId)
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
    index: true,
  },
  driverUserId: { // <-- الحقل الجديد لتخزين userId الرقمي للمستخدم
    type: Number,
    required: true, // اجعله مطلوبًا لضمان وجوده دائمًا
    index: true,    // من الجيد فهرسته إذا كنت ستبحث بناءً عليه أحيانًا
  },
  taxiOffice: {
    type: String,
    required: true, // أو حسب متطلباتك
  },

  carDetails: {
    model: String,
    plateNumber: String,
    color: String,
  },
  isAvailable: {
    type: Boolean,
    default: true,
    index: true,
  },
 rating: {
    type: Number,
    default: 80,
    min: 0,
    max: 100 
  },
  numberOfRatings: {
      type: Number,
      default: 0,
  },
  profileImageUrl: {
    type: String,
    trim: true,
    default: null,
  },
    earnings: {
    type: Number,
    default: 0,
  },
}, { timestamps: true });

const Driver = mongoose.model('Driver', driverSchema);

module.exports = Driver;