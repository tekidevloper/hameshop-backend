require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const apiRoutes = require('./routes/apiRoutes');

// Models (to ensure they are registered)
const User = require('./models/User');
const Product = require('./models/Product');
const Order = require('./models/Order');
const Review = require('./models/Review');
require('./models/Request');
const Notification = require('./models/Notification');
const Banner = require('./models/Banner');

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Request Logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Connect to Database
connectDB();

// Routes
app.use('/api/auth', authRoutes);
app.use('/api', apiRoutes);

const PORT = process.env.PORT || 5000;

const seedData = async () => {
  try {
    const userCount = await User.countDocuments();
    if (userCount === 0) {
      await User.create({
        name: 'Hamee Asdsach',
        email: 'tekidevloper@gmail.com',
        password: 'cyber360',
        role: 'admin',
        phone: '+251911223344'
      });
      console.log('Admin user seeded');
    }

    const productCount = await Product.countDocuments();
    if (productCount === 0) {
      await Product.insertMany([
        {
          name: 'Smart Watch Pro',
          description: 'Advanced health tracking and notifications.',
          price: 2500.0,
          imageUrl: 'https://images.unsplash.com/photo-1546868871-70c122469d8b?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Electronics',
          isRecommended: true,
          rating: 4.8,
          reviewCount: 124,
        },
        {
          name: 'Wireless Earbuds',
          description: 'Noise cancelling with long battery life.',
          price: 1200.0,
          imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Electronics',
          rating: 4.5,
          reviewCount: 89,
        },
        {
          name: 'Running Shoes',
          description: 'Comfortable shoes for daily jogging.',
          price: 1800.0,
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Fashion',
          rating: 4.2,
          reviewCount: 56,
        },
        {
          name: 'Designer Hoodie',
          description: 'Stylish and warm hoodie for winter.',
          price: 900.0,
          imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Fashion',
          isRecommended: true,
          rating: 4.7,
          reviewCount: 230,
        },
        {
          name: 'Coffee Maker',
          description: 'Brew the perfect cup of coffee every morning.',
          price: 3500.0,
          imageUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Home',
          rating: 4.6,
          reviewCount: 45,
        },
        {
          name: 'Bluetooth Speaker',
          description: 'Portable speaker with amazing bass.',
          price: 1500.0,
          imageUrl: 'https://images.unsplash.com/photo-1608156639585-34a0a597aa75?auto=format&fit=crop&q=80&w=300&h=300',
          category: 'Electronics',
          rating: 4.4,
          reviewCount: 72,
        }
      ]);
      console.log('Seed data added');
    }
  } catch (error) {
    console.error('Seeding error:', error);
  }
};

const startServer = async () => {
  await seedData();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
    console.log('Body parser limit set to 50mb');
  });
};

startServer();
