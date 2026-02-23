const Request = require('../models/Request');

const createRequest = async (req, res) => {
    try {
        const { title, message, category } = req.body;
        const request = await Request.create({
            userId: req.user.id,
            title,
            message,
            category: category || 'Support'
        });
        res.status(201).json(request);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const getRequests = async (req, res) => {
    try {
        const requests = await Request.find({}).populate('userId', 'name email').sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getUserRequests = async (req, res) => {
    try {
        const requests = await Request.find({ userId: req.user.id }).sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const respondToRequest = async (req, res) => {
    try {
        const { adminResponse, status } = req.body;
        const request = await Request.findByIdAndUpdate(
            req.params.id,
            { adminResponse, status: status || 'Responded' },
            { new: true }
        );
        if (!request) return res.status(404).json({ error: 'Request not found' });
        res.json(request);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { createRequest, getRequests, getUserRequests, respondToRequest };
