const Banner = require('../models/Banner');

const getBanners = async (req, res) => {
    try {
        // Fetch all active banners, sorted by 'order' (ascending) or 'createdAt' (descending)
        const banners = await Banner.find({ isActive: true }).sort({ order: 1, createdAt: -1 });
        res.json(banners);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const addBanner = async (req, res) => {
    try {
        console.log('addBanner request received');
        const { imageUrl, title, order, isActive } = req.body;

        if (!imageUrl) {
            console.log('addBanner error: Image URL/Base64 is missing');
            return res.status(400).json({ error: 'Image URL/Base64 is required' });
        }

        console.log('Creating banner in database...');
        const banner = await Banner.create({
            imageUrl,
            title,
            order: order || 0,
            isActive: isActive !== undefined ? isActive : true
        });

        console.log('Banner created successfully:', banner._id);
        res.status(201).json(banner);
    } catch (error) {
        console.error('addBanner error:', error);
        res.status(400).json({ error: error.message });
    }
};

const deleteBanner = async (req, res) => {
    try {
        const { id } = req.params;
        const banner = await Banner.findById(id);

        if (!banner) {
            return res.status(404).json({ error: 'Banner not found' });
        }

        await Banner.findByIdAndDelete(id);
        res.json({ message: 'Banner removed' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = { getBanners, addBanner, deleteBanner };
