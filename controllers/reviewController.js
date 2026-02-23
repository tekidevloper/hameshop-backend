const Review = require('../models/Review');
const Product = require('../models/Product');

const getProductReviews = async (req, res) => {
    try {
        const { productId } = req.params;
        const reviews = await Review.find({ productId }).sort({ createdAt: -1 });
        res.json(reviews);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const createReview = async (req, res) => {
    try {
        const { rating, comment, productId, userName } = req.body;
        const userId = req.user.id; // From auth middleware

        const review = await Review.create({
            rating,
            comment,
            productId,
            userId,
            userName,
        });

        // Update product rating and review count
        const product = await Product.findById(productId);
        if (product) {
            const reviews = await Review.find({ productId });
            const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;

            product.rating = parseFloat(avgRating.toFixed(1));
            product.reviewCount = reviews.length;
            await product.save();
        }

        res.status(201).json(review);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getProductReviews, createReview };
