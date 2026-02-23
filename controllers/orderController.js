const Order = require('../models/Order');

const getOrders = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const query = req.user.role === 'admin' ? {} : { userId: req.user.id };

        const total = await Order.countDocuments(query);
        const orders = await Order.find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

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
        const order = await Order.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!order) return res.status(404).json({ error: 'Order not found' });
        res.json(order);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getOrders, createOrder, updateOrderStatus };
