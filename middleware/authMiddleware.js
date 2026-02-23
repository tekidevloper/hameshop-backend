const jwt = require('jsonwebtoken');

const protect = (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
        return res.status(401).json({ error: 'Not authorized to access this route' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Not authorized to access this route' });
    }
};

const admin = (req, res, next) => {
    console.log(`Admin Check for user: ${req.user?.email}, Role: ${req.user?.role}`);
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        console.log('Admin check failed');
        res.status(403).json({ error: 'Require Admin Role' });
    }
};

module.exports = { protect, admin };
