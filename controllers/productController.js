const Product = require('../models/Product');

const getProducts = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        const { count: total, rows: products } = await Product.findAndCountAll({
            order: [['createdAt', 'DESC']],
            offset,
            limit
        });

        res.setHeader('X-Debug-Source', 'productController.getProducts');
        res.json({
            products,
            page,
            limit,
            total,
            pages: Math.ceil(total / limit)
        });
    } catch (error) {
        console.error('Fetch Products Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const createProduct = async (req, res) => {
    try {
        const product = await Product.create(req.body);
        res.status(201).json(product);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const updateProduct = async (req, res) => {
    try {
        const product = await Product.findByPk(req.params.id);
        if (!product) return res.status(404).json({ error: 'Product not found' });
        
        await product.update(req.body);
        res.json(product);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const deleteProduct = async (req, res) => {
    try {
        const product = await Product.findByPk(req.params.id);
        if (!product) return res.status(404).json({ error: 'Product not found' });
        
        await product.destroy();
        res.json({ message: 'Product deleted' });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getProducts, createProduct, updateProduct, deleteProduct };
