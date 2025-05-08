const mongoose = require('mongoose');
const AutoIncrement = require('mongoose-sequence')(mongoose);

const userSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true,
    trim: true,
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  role: {
    type: String,
    enum: ['User', 'Driver', 'Admin','Manager'],
    default: 'User',
    enum: ['User', 'Driver', 'Manager', 'Admin'],
    required: true,
  },
  gender: {
    type: String,
    enum: ['Male', 'Female'],
    required: true,
  },
  // taxiOffice: {
  //   type: String,
  //   required: function() { return this.role === 'Driver'; }
  // },
  // carDetails: {
  //   model: String,
  //   plateNumber: String,
  //   color: String,
  // },
  // earnings: {
  //   type: Number,
  //   default: 0,
  // },
  // isAvailable: {
  //   type: Boolean,
  //   default: true,
  // }
  
}, { timestamps: true });

userSchema.plugin(AutoIncrement, { inc_field: 'userId' });

const User = mongoose.model('User', userSchema);

module.exports = User;
