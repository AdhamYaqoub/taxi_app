// models/messageModel.js
const mongoose = require('mongoose');

// إنشاء المخطط (Schema) للرسالة
const messageSchema = new mongoose.Schema({
  sender: { type: String, required: true },
  receiver: { type: String, required: true },
  senderType: { 
    type: String, 
    required: true,
    enum: ['driver', 'office_manager', 'user', 'admin']
  },
  receiverType: { 
    type: String, 
    required: true,
    enum: ['driver', 'office_manager', 'user', 'admin']
  },
  message: { type: String, required: false },
  image: { type: String, required: false },
  audio: { type: String, required: false },
  officeId: { type: Number, required: false }, // For office manager-driver messages
  timestamp: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
  readAt: { type: Date }
});

// إنشاء موديل الرسالة باستخدام المخطط
const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
