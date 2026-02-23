const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    imageUrl: {
        type: String,
        required: true,
    },
    category: {
        type: String,
        required: true,
    },
    isRecommended: {
        type: Boolean,
        default: false,
    },
    rating: {
        type: Number,
        default: 0,
    },
    reviewCount: {
        type: Number,
        default: 0,
    }
}, {
    timestamps: true
});

// Indexes for performance
productSchema.index({ category: 1 });
productSchema.index({ isRecommended: -1 });
productSchema.index({ name: 'text', description: 'text' }); // Search optimization

// Add 'id' virtual for frontend compatibility
productSchema.virtual('id').get(function () {
    return this._id.toHexString();
});

productSchema.set('toJSON', {
    virtuals: true
});

module.exports = mongoose.model('Product', productSchema);
