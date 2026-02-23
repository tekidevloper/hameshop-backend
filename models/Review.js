const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    rating: {
        type: Number,
        required: true,
        min: 1,
        max: 5,
    },
    comment: {
        type: String,
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true,
    },
    userName: {
        type: String,
        required: true,
    }
}, {
    timestamps: true
});

// Add 'id' virtual for frontend compatibility
reviewSchema.virtual('id').get(function () {
    return this._id.toHexString();
});

reviewSchema.set('toJSON', {
    virtuals: true
});

module.exports = mongoose.model('Review', reviewSchema);
