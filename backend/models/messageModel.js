// models/messageModel.js
const mongoose = require('mongoose');

// إنشاء المخطط (Schema) للرسالة
const messageSchema = new mongoose.Schema({
  sender: { type: String, required: true },
  receiver: { type: String, required: true },
  message: { type: String, required: false },
  image: { type: String, required: false },
  audio: { type: String, required: false },
  timestamp: { type: Date, default: Date.now },
});

// إنشاء موديل الرسالة باستخدام المخطط
const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
