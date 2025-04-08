const express = require('express');
const router = express.Router();
const Message = require('../models/messageModel');

// إرسال رسالة
router.post('/', async (req, res) => {
  const { sender, receiver, message, image, audio } = req.body;

  try {
    const newMessage = new Message({ sender, receiver, message, image, audio });
    await newMessage.save();
    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: 'Error sending message', error });
  }
});

// جلب الرسائل بين المستخدم والسائق
router.get('/', async (req, res) => {
  const { receiver } = req.query;

  try {
    const messages = await Message.find({ receiver }).sort({ createdAt: 1 });
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching messages', error });
  }
});

module.exports = router;
