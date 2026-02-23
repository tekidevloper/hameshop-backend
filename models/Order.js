const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    customerName: {
        type: String,
        required: true,
    },
    customerEmail: {
        type: String,
        required: true,
    },
    totalAmount: {
        type: Number,
        required: true,
    },
    status: {
        type: String,
        enum: ['Pending', 'Shipped', 'Delivered', 'Cancelled'],
        default: 'Pending',
    },
    paymentStatus: {
        type: String,
        enum: ['Paid', 'Unpaid'],
        default: 'Unpaid',
    },
    items: {
        type: Array, // Stores array of items
        required: true,
    },
    shippingAddress: {
        fullName: String,
        phone: String,
        street: String,
        city: String,
        region: String,
        postalCode: String
    },
    phoneNumber: {
        type: String
    }
}, {
    timestamps: true
});

// Indexes for performance
orderSchema.index({ userId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });

// Add 'id' virtual for frontend compatibility
orderSchema.virtual('id').get(function () {
    return this._id.toHexString();
});

orderSchema.set('toJSON', {
    virtuals: true
});

module.exports = mongoose.model('Order', orderSchema);
