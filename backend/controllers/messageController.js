// controllers/messageController.js
const Message = require('../models/messageModel');

// إرسال رسالة
exports.sendMessage = async (req, res) => {
  try {
    const { sender, receiver, message, image, audio } = req.body;
    
    // إنشاء رسالة جديدة
    const newMessage = new Message({
      sender,
      receiver,
      message,
      image,
      audio,
    });

    // حفظ الرسالة في قاعدة البيانات
    await newMessage.save();
    res.status(201).json({ message: 'Message sent successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to send message' });
  }
};

// الحصول على الرسائل لمستخدم معين
exports.getMessages = async (req, res) => {
  try {
    const { receiver } = req.params;
    
    // جلب الرسائل الخاصة بالمستقبل
    const messages = await Message.find({ receiver }).sort({ timestamp: -1 });
    res.status(200).json(messages);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load messages' });
  }
};
