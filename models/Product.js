const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Product = sequelize.define('Product', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    price: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    imageUrl: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    category: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    isRecommended: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    rating: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
    },
    reviewCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    }
}, {
    timestamps: true,
    indexes: [
        { fields: ['category'] },
        { fields: ['isRecommended'] }
    ]
});

module.exports = Product;
