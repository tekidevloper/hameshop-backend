const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Request = sequelize.define('Request', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    message: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    category: {
        type: DataTypes.ENUM('Support', 'Product Inquiry', 'Order Issue', 'Other'),
        defaultValue: 'Support',
    },
    status: {
        type: DataTypes.ENUM('Open', 'Responded', 'Closed'),
        defaultValue: 'Open',
    },
    adminResponse: {
        type: DataTypes.TEXT,
    }
}, {
    timestamps: true
});

module.exports = Request;
