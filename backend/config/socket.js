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
    
    socket.on('driver_online', (data) => {
      socket.join(`driver_${data.driverId}`);
      console.log(`Driver ${data.driverId} is now online`);
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