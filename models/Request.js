const mongoose = require('mongoose');

const requestSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    message: {
        type: String,
        required: true,
    },
    category: {
        type: String,
        enum: ['Support', 'Product Inquiry', 'Order Issue', 'Other'],
        default: 'Support',
    },
    status: {
        type: String,
        enum: ['Open', 'Responded', 'Closed'],
        default: 'Open',
    },
    adminResponse: {
        type: String,
    }
}, {
    timestamps: true
});

// Add 'id' virtual for frontend compatibility
requestSchema.virtual('id').get(function () {
    return this._id.toHexString();
});

requestSchema.set('toJSON', {
    virtuals: true
});

module.exports = mongoose.model('Request', requestSchema);
