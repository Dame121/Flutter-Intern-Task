// backend/user-service/src/models/userModel.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    displayName: {
      type: String,
      required: true,
    },
    profilePhotoUrl: String,
    bio: String,
    role: {
      type: String,
      enum: ['caller', 'host'],
      required: true,
    },
    status: {
      type: String,
      enum: ['online', 'busy', 'offline', 'in-call'],
      default: 'offline',
    },
    // Host-specific fields
    audioCallRate: {
      type: Number,
      minimum: 0,
      default: 0,
    },
    videoCallRate: {
      type: Number,
      minimum: 0,
      default: 0,
    },
    messageRate: {
      type: Number,
      minimum: 0,
      default: 0,
    },
    totalEarnings: {
      type: Number,
      default: 0,
    },
    isAvailable: {
      type: Boolean,
      default: false,
    },
    rating: {
      average: { type: Number, default: 0 },
      count: { type: Number, default: 0 },
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('User', userSchema);
