const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
    },
    message: {
        type: String,
        required: true,
    },
    type: {
        type: String,
        default: 'system',
    },
    isRead: {
        type: Boolean,
        default: false,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    }
}, {
    timestamps: true
});

// Add 'id' virtual for frontend compatibility
notificationSchema.virtual('id').get(function () {
    return this._id.toHexString();
});

notificationSchema.set('toJSON', {
    virtuals: true
});

module.exports = mongoose.model('Notification', notificationSchema);
