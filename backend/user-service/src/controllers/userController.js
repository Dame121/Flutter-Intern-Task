// backend/user-service/src/controllers/userController.js

const User = require('../models/userModel');

/**
 * Get user profile
 * GET /api/users/profile
 */
async function getProfile(req, res) {
  try {
    const { userId } = req.user; // From auth middleware

    let user = await User.findOne({ userId });

    if (!user) {
      return res.status(404).json({ message: 'User profile not found' });
    }

    res.json({
      id: user._id,
      userId: user.userId,
      displayName: user.displayName,
      profilePhotoUrl: user.profilePhotoUrl,
      bio: user.bio,
      role: user.role,
      status: user.status,
      audioCallRate: user.audioCallRate,
      videoCallRate: user.videoCallRate,
      messageRate: user.messageRate,
      totalEarnings: user.totalEarnings,
      isAvailable: user.isAvailable,
      rating: user.rating,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Failed to get profile', error: error.message });
  }
}

/**
 * Create or update user profile
 * POST /api/users/profile
 */
async function updateProfile(req, res) {
  try {
    const { userId } = req.user;
    const { displayName, profilePhotoUrl, bio, audioCallRate, videoCallRate, messageRate } = req.body;

    // Validation for host rates
    if (videoCallRate && audioCallRate && videoCallRate < audioCallRate) {
      return res.status(400).json({ message: 'Video rate must be higher than audio rate' });
    }

    let user = await User.findOne({ userId });

    if (!user) {
      // Create new profile
      const roleFromHeader = req.headers['user-role'] || 'caller';
      user = new User({
        userId,
        displayName: displayName || `User_${userId.substring(0, 8)}`,
        profilePhotoUrl,
        bio,
        role: roleFromHeader,
        audioCallRate: audioCallRate || 0,
        videoCallRate: videoCallRate || 0,
        messageRate: messageRate || 0,
      });
    } else {
      // Update existing profile
      if (displayName) user.displayName = displayName;
      if (profilePhotoUrl) user.profilePhotoUrl = profilePhotoUrl;
      if (bio) user.bio = bio;
      if (audioCallRate !== undefined) user.audioCallRate = audioCallRate;
      if (videoCallRate !== undefined) user.videoCallRate = videoCallRate;
      if (messageRate !== undefined) user.messageRate = messageRate;
    }

    await user.save();

    res.json({
      message: 'Profile updated successfully',
      user: {
        userId: user.userId,
        displayName: user.displayName,
        profilePhotoUrl: user.profilePhotoUrl,
        bio: user.bio,
        role: user.role,
        audioCallRate: user.audioCallRate,
        videoCallRate: user.videoCallRate,
        messageRate: user.messageRate,
      },
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Failed to update profile', error: error.message });
  }
}

/**
 * Get host profile by ID
 * GET /api/users/host/:id
 */
async function getHostProfile(req, res) {
  try {
    const { id } = req.params;

    const user = await User.findOne({ userId: id });

    if (!user || user.role !== 'host') {
      return res.status(404).json({ message: 'Host not found' });
    }

    res.json({
      id: user._id,
      userId: user.userId,
      displayName: user.displayName,
      profilePhotoUrl: user.profilePhotoUrl,
      bio: user.bio,
      status: user.status,
      audioCallRate: user.audioCallRate,
      videoCallRate: user.videoCallRate,
      messageRate: user.messageRate,
      rating: user.rating,
      isAvailable: user.isAvailable,
    });
  } catch (error) {
    console.error('Get host profile error:', error);
    res.status(500).json({ message: 'Failed to get host profile', error: error.message });
  }
}

/**
 * Update user availability status
 * PUT /api/users/status
 */
async function updateStatus(req, res) {
  try {
    const { userId } = req.user;
    const { status } = req.body;

    if (!['online', 'busy', 'offline', 'in-call'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const user = await User.findOneAndUpdate(
      { userId },
      { status },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'Status updated', status: user.status });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ message: 'Failed to update status', error: error.message });
  }
}

module.exports = {
  getProfile,
  updateProfile,
  getHostProfile,
  updateStatus,
};
