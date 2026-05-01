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
          name: 'iPhone 15 Pro Max',
          description: 'The ultimate iPhone with titanium design and A17 Pro chip.',
          price: 185000.0,
          imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?auto=format&fit=crop&q=80&w=400',
          category: 'Phones',
          isRecommended: true,
          rating: 4.9,
          reviewCount: 450,
        },
        {
          name: 'MacBook Pro M3',
          description: 'Unleash your creativity with the most powerful MacBook ever.',
          price: 245000.0,
          imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=400',
          category: 'Computers',
          isRecommended: true,
          rating: 4.9,
          reviewCount: 320,
        },
        {
          name: 'Sony WH-1000XM5',
          description: 'Industry-leading noise canceling headphones with amazing sound.',
          price: 35000.0,
          imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
          category: 'Accessories',
          rating: 4.8,
          reviewCount: 890,
        },
        {
          name: 'Smart Watch Pro V2',
          description: 'Advanced health tracking, GPS, and cellular connectivity.',
          price: 22000.0,
          imageUrl: 'https://images.unsplash.com/photo-1546868871-70c122469d8b?auto=format&fit=crop&q=80&w=400',
          category: 'Wearables',
          isRecommended: true,
          rating: 4.7,
          reviewCount: 156,
        },
        {
          name: 'Wireless Gaming Mouse',
          description: 'Ultra-lightweight mouse with sub-1ms response time.',
          price: 8500.0,
          imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&q=80&w=400',
          category: 'Accessories',
          rating: 4.6,
          reviewCount: 230,
        },
        {
          name: '4K Ultra HD Monitor',
          description: '32-inch professional display with stunning color accuracy.',
          price: 65000.0,
          imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&q=80&w=400',
          category: 'Computers',
          rating: 4.7,
          reviewCount: 85,
        },
        {
          name: 'Premium Leather Sofa',
          description: 'Elegant and comfortable Italian leather sofa for your living room.',
          price: 150000.0,
          imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=400',
          category: 'Home',
          rating: 4.5,
          reviewCount: 42,
        },
        {
          name: 'Minimalist Coffee Table',
          description: 'Sleek wooden coffee table that fits any modern home.',
          price: 12500.0,
          imageUrl: 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?auto=format&fit=crop&q=80&w=400',
          category: 'Home',
          rating: 4.4,
          reviewCount: 67,
        }
      ]);
      console.log('Premium Seed data added');
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
