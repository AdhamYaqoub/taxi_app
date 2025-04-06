// models/TripRequest.js
const mongoose = require('mongoose');
const AutoIncrement = require('mongoose-sequence')(mongoose);

const tripRequestSchema = new mongoose.Schema({
  requestId: { type: Number, unique: true }, // سيتم توليده تلقائياً
  userId: { type: Number, required: true },
  driverId: { type: Number },
  startLocation: { type: String, required: true },
  endLocation: { type: String, required: true },
  distance: { type: Number, required: true },
  estimatedFare: { type: Number, required: true },
  status: { 
    type: String, 
    enum: ['pending', 'accepted', 'rejected', 'timeout'], 
    default: 'pending' 
  },
  requestedAt: { type: Date, default: Date.now }
});

// إضافة المسلسل التلقائي
tripRequestSchema.plugin(AutoIncrement, { inc_field: 'requestId' });

module.exports = mongoose.model('TripRequest', tripRequestSchema);