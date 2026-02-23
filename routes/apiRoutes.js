const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const orderController = require('../controllers/orderController');
const reviewController = require('../controllers/reviewController');
const notificationController = require('../controllers/notificationController');
const requestController = require('../controllers/requestController');
const bannerController = require('../controllers/bannerController');
const { protect, admin } = require('../middleware/authMiddleware');

// Product Routes
router.get('/products', productController.getProducts);
router.post('/products', protect, admin, productController.createProduct);
router.put('/products/:id', protect, admin, productController.updateProduct);
router.delete('/products/:id', protect, admin, productController.deleteProduct);

// Order Routes
router.get('/orders', protect, orderController.getOrders);
router.post('/orders', protect, orderController.createOrder);
router.put('/orders/:id', protect, admin, orderController.updateOrderStatus);

// Review Routes
router.get('/products/:productId/reviews', reviewController.getProductReviews);
router.post('/reviews', protect, reviewController.createReview);

// Notification Routes
router.get('/notifications', protect, notificationController.getUserNotifications);
router.put('/notifications/:id/read', protect, notificationController.markAsRead);
router.post('/notifications', protect, notificationController.createNotification);

// Request Routes
router.get('/requests', protect, admin, requestController.getRequests);
router.get('/requests/my', protect, requestController.getUserRequests);
router.post('/requests', protect, requestController.createRequest);
router.put('/requests/:id', protect, admin, requestController.respondToRequest);

// Banner Routes
router.get('/banners', bannerController.getBanners);
router.post('/banners', protect, admin, bannerController.addBanner);
router.delete('/banners/:id', protect, admin, bannerController.deleteBanner);

module.exports = router;
