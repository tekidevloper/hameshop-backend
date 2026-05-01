const { Sequelize } = require('sequelize');

const databaseUrl = process.env.DATABASE_URL || 'postgresql://localhost:5432/hame_shop';

const sequelize = new Sequelize(databaseUrl, {
  dialect: 'postgres',
  logging: false,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false // Required for Render
    }
  }
});

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('PostgreSQL Connected via Sequelize');
    return sequelize;
  } catch (error) {
    console.error('PostgreSQL Connection Error:', error.message);
    throw error;
  }
};

module.exports = { sequelize, connectDB };
