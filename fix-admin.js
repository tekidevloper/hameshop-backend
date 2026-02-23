const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const fixAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/hame_shop');

        // Check if tekidevloper@gmail.com exists
        let admin = await User.findOne({ email: 'tekidevloper@gmail.com' });

        if (!admin) {
            console.log('Creating admin: tekidevloper@gmail.com');
            await User.create({
                name: 'Hamee Asdsach',
                email: 'tekidevloper@gmail.com',
                password: 'cyber360',
                role: 'admin',
                phone: '+251911223344'
            });
        } else {
            console.log('Admin already exists, updating name');
            admin.name = 'Hamee Asdsach';
            admin.password = 'cyber360'; // Reset password just in case
            await admin.save();
        }

        // Also update hame@gmail.com if it exists
        let otherAdmin = await User.findOne({ email: 'hame@gmail.com' });
        if (otherAdmin) {
            console.log('Updating hame@gmail.com admin name');
            otherAdmin.name = 'Hamee Asdsach';
            await otherAdmin.save();
        }

        console.log('Admin check complete');
        mongoose.connection.close();
    } catch (error) {
        console.error('Error:', error);
    }
};

fixAdmin();
