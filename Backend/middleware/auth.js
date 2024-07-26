const jwt = require('jsonwebtoken');
const { SECRET_KEY } = require('../config');
const User=require('../models/User');

const authMiddleware = async(req, res, next) => {
  const token = req.header('Authorization');
  if (!token) return res.status(401).json({ error: 'No token, authorization denied' });
  // console.log(token);
  
  try {
    const decoded =jwt.verify(token, SECRET_KEY);
    // console.log(decoded);
    req.user = await User.findById(decoded.userId).select('-password');
    
    next();
  } catch (err) {
    res.status(401).json({ error: 'Token is not valid' });
  }
};

module.exports = authMiddleware;
