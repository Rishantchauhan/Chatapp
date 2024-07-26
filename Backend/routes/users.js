const express = require('express');
const User = require('../models/User');
const router = express.Router();



router.get('/get', async (req, res) => {
  console.log(req.user);
  try {
    const users = await User.find({ _id: { $ne: req.user._id } });
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/search', async (req, res) => {
  try {
    // console.log(req.query.name);
    const users = await User.find({ name:req.query.name });
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
