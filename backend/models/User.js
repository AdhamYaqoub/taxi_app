const mongoose = require('mongoose');

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
    required: true,
  },
  gender: {
    type: String,
    enum: ['Male', 'Female'],
    required: true,
  },
  taxiOffice: {
    type: String,
    required: function() { return this.role === 'Driver'; }
  },
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

module.exports = User;
