const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Notification = sequelize.define('Notification', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    message: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    type: {
        type: DataTypes.STRING,
        defaultValue: 'system',
    },
    isRead: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    userId: {
        type: DataTypes.UUID,
        allowNull: false,
    }
}, {
    timestamps: true
});

module.exports = Notification;
