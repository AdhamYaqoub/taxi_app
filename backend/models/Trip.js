const mongoose = require('mongoose');
const AutoIncrement = require('mongoose-sequence')(mongoose);

const tripSchema = new mongoose.Schema({
  driverId: {
    type: Number,
    ref: 'User', // ارتباط السائق
    required: true,
  },
  startLocation: {
    type: String,
    required: true,
  },
  endLocation: {
    type: String,
    required: true,
  },
  distance: {
    type: Number, // المسافة بالكيلومتر أو الميل
    required: true,
  },
  startTime: {
    type: Date,
    required: true,
  },
  endTime: {
    type: Date,
    required: true,
  },
  status: {
    type: String,
    enum: ['Pending', 'In Progress', 'Completed', 'Cancelled'],
    default: 'Pending',
  },
  earnings: {
    type: Number, // الأرباح الناتجة عن الرحلة
    default: 0,
  },
}, { timestamps: true });

tripSchema.plugin(AutoIncrement, { inc_field: 'tripId' });
const Trip = mongoose.model('Trip', tripSchema);

module.exports = Trip;
