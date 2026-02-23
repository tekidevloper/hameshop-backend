const Notification = require('../models/Notification');

const getUserNotifications = async (req, res) => {
    try {
        const userId = req.user.id;
        const notifications = await Notification.find({ userId }).sort({ createdAt: -1 });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const markAsRead = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await Notification.findById(id);

        if (!notification) {
            return res.status(404).json({ error: 'Notification not found' });
        }

        notification.isRead = true;
        await notification.save();
        res.json(notification);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const createNotification = async (req, res) => {
    try {
        const { title, message, type, userId } = req.body;
        const notification = await Notification.create({
            title,
            message,
            type,
            userId,
        });
        res.status(201).json(notification);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getUserNotifications, markAsRead, createNotification };
