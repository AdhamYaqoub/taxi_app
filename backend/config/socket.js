// config/socket.js
const { Server } = require('socket.io');

let io; // لتخزين instance الـ Socket.IO

module.exports = {
  init: (httpServer) => {
    // تهيئة Socket.IO مع خيارات CORS
    io = new Server(httpServer, {
      cors: {
        origin: process.env.CORS_ORIGIN || '*', // السماح بكل المصادر في التطوير، وتحديدها في الإنتاج
        methods: ['GET', 'POST']
      }
    });

    io.on('connection', (socket) => {
      console.log('A user connected to Socket.IO');

      // يمكنك إضافة منطق للانضمام إلى غرف (rooms) هنا
      // مثال:
      // socket.on('join_trip', (tripId) => {
      //   socket.join(`trip-${tripId}`);
      //   console.log(`Socket ${socket.id} joined trip-${tripId}`);
      // });

      socket.on('disconnect', () => {
        console.log('A user disconnected from Socket.IO');
      });
    });
    return io;
  },
  getIo: () => {
    if (!io) {
      throw new Error('Socket.IO not initialized!');
    }
    return io;
  },
};