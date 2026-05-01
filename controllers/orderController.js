const Order = require('../models/Order');

const getOrders = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        const whereClause = req.user.role === 'admin' ? {} : { userId: req.user.id };

        const { count: total, rows: orders } = await Order.findAndCountAll({
            where: whereClause,
            order: [['createdAt', 'DESC']],
            offset,
            limit
        });

        res.json({
            orders,
            page,
            limit,
            total,
            pages: Math.ceil(total / limit)
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createOrder = async (req, res) => {
    try {
        const { items, totalAmount, customerName, customerEmail, shippingAddress, phoneNumber } = req.body;
        const order = await Order.create({
            userId: req.user.id,
            customerName,
            customerEmail,
            totalAmount,
            items,
            shippingAddress,
            phoneNumber
        });
        res.status(201).json(order);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const updateOrderStatus = async (req, res) => {
    try {
        const order = await Order.findByPk(req.params.id);
        if (!order) return res.status(404).json({ error: 'Order not found' });
        
        await order.update(req.body);
        res.json(order);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getOrders, createOrder, updateOrderStatus };
