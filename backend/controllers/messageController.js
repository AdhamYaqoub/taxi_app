// controllers/messageController.js
const Message = require('../models/messageModel');

// إرسال رسالة
exports.sendMessage = async (req, res) => {
  try {
    const { sender, receiver, senderType, receiverType, message, image, audio, officeId } = req.body;
    
    // إنشاء رسالة جديدة
    const newMessage = new Message({
      sender,
      receiver,
      senderType,
      receiverType,
      message,
      image,
      audio,
      officeId
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
    const { receiver, officeId } = req.query;
    
    let query = { receiver };
    
    // إذا كان هناك officeId، أضفه إلى الاستعلام
    if (officeId) {
      query.officeId = officeId;
    }
    
    // جلب الرسائل الخاصة بالمستقبل
    const messages = await Message.find(query)
      .sort({ timestamp: -1 })
      .limit(50); // Limit to last 50 messages for performance
    
    res.status(200).json(messages);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load messages' });
  }
};

// تحديث حالة القراءة للرسائل
exports.markMessagesAsRead = async (req, res) => {
  try {
    const { receiver, sender } = req.body;
    
    await Message.updateMany(
      { receiver, sender, read: false },
      { 
        $set: { 
          read: true,
          readAt: new Date()
        }
      }
    );
    
    res.status(200).json({ message: 'Messages marked as read' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to mark messages as read' });
  }
};

// الحصول على عدد الرسائل غير المقروءة
exports.getUnreadCount = async (req, res) => {
  try {
    const { receiver } = req.params;
    
    const count = await Message.countDocuments({
      receiver,
      read: false
    });
    
    res.status(200).json({ unreadCount: count });
  } catch (err) {
    res.status(500).json({ error: 'Failed to get unread count' });
  }
};
