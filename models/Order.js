const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Order = sequelize.define('Order', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    customerName: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    customerEmail: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    totalAmount: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    status: {
        type: DataTypes.ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled'),
        defaultValue: 'Pending',
    },
    paymentStatus: {
        type: DataTypes.ENUM('Paid', 'Unpaid'),
        defaultValue: 'Unpaid',
    },
    items: {
        type: DataTypes.JSONB,
        allowNull: false,
    },
    shippingAddress: {
        type: DataTypes.JSONB,
    },
    phoneNumber: {
        type: DataTypes.STRING
    }
}, {
    timestamps: true,
    indexes: [
        { fields: ['userId'] },
        { fields: ['status'] },
        { fields: ['createdAt'] }
    ]
});

module.exports = Order;
