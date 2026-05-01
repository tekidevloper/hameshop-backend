require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { sequelize, connectDB } = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const apiRoutes = require('./routes/apiRoutes');

// Models
const User = require('./models/User');
const Product = require('./models/Product');
const Order = require('./models/Order');
const Review = require('./models/Review');
const Request = require('./models/Request');
const Notification = require('./models/Notification');
const Banner = require('./models/Banner');

// Associations
Order.belongsTo(User, { foreignKey: 'userId' });
Review.belongsTo(User, { foreignKey: 'userId' });
Review.belongsTo(Product, { foreignKey: 'productId' });
Request.belongsTo(User, { foreignKey: 'userId' });
Notification.belongsTo(User, { foreignKey: 'userId' });

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Request Logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/health', async (req, res) => {
  let dbStatus = 'disconnected';
  try {
    await sequelize.authenticate();
    dbStatus = 'connected';
  } catch (err) {
    dbStatus = 'error';
  }

  res.status(200).json({ 
    status: 'ok', 
    uptime: process.uptime(),
    database: dbStatus
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api', apiRoutes);

const PORT = process.env.PORT || 5000;

const seedData = async () => {
  try {
    const userCount = await User.count();
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

    const productCount = await Product.count();
    if (productCount === 0) {
      await Product.bulkCreate([
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
  try {
    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on http://0.0.0.0:${PORT}`);
    });

    console.log('Connecting to PostgreSQL...');
    await connectDB();
    
    // Sync models
    console.log('Syncing database models...');
    await sequelize.sync({ alter: true });
    console.log('Database synced');

    await seedData();

    process.on('SIGTERM', () => {
      console.log('SIGTERM signal received: closing HTTP server');
      server.close(async () => {
        console.log('HTTP server closed');
        await sequelize.close();
        console.log('PostgreSQL connection closed');
        process.exit(0);
      });
    });

  } catch (error) {
    console.error('Critical failure during startup:', error);
    process.exit(1);
  }
};

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

startServer();
