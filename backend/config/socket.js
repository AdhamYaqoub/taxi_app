// config/socket.js
const socketIO = require('socket.io');

let io;

const init = (httpServer) => {
  io = socketIO(httpServer, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });

  io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);
    
    // Join user to their personal room
    socket.on('join_user', (data) => {
      socket.join(`user_${data.userId}`);
      console.log(`User ${data.userId} joined their room`);
    });

    // Join driver to their personal room
    socket.on('join_driver', (data) => {
      socket.join(`driver_${data.driverId}`);
      console.log(`Driver ${data.driverId} joined their room`);
    });

    // Join admin to their personal room
    socket.on('join_admin', (data) => {
      socket.join(`admin_${data.adminId}`);
      console.log(`Admin ${data.adminId} joined their room`);
    });

    // Handle user-driver chat
    socket.on('user_driver_message', (data) => {
      io.to(`driver_${data.receiverId}`).emit('new_message', {
        senderId: data.senderId,
        senderType: 'user',
        message: data.message,
        timestamp: new Date()
      });
    });

    // Handle user-admin chat
    socket.on('user_admin_message', (data) => {
      io.to(`admin_${data.receiverId}`).emit('new_message', {
        senderId: data.senderId,
        senderType: 'user',
        message: data.message,
        timestamp: new Date()
      });
    });

    // Handle driver-admin chat
    socket.on('driver_admin_message', (data) => {
      io.to(`admin_${data.receiverId}`).emit('new_message', {
        senderId: data.senderId,
        senderType: 'driver',
        message: data.message,
        timestamp: new Date()
      });
    });

    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.id);
    });
  });

  return io;
};

const getIO = () => {
  if (!io) throw new Error('Socket.io not initialized');
  return io;
};

module.exports = { init, getIO };