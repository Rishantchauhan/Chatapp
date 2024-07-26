const express = require('express');
const Message = require('../models/Message');
const User=require('../models/User');
const authMiddleware = require('../middleware/auth');
const router = express.Router();


router.get('/', async (req, res) => {
  try {
    
    const messages = await Message.find({
      $or: [
        { senderId: req.user._id },
        { receiverId: req.user._id }
      ]
    });

    const userIds = [...new Set(messages.map(m => m.senderId).concat(messages.map(m => m.receiverId)))];
    const uniqueUserIds = userIds.filter(id => id.toString() !== req.user._id.toString());

    const unique_users = await Promise.all(
      uniqueUserIds.map(async (id) => {
        try {
         
          return await User.findById(id).select('-password');
        } catch (error) {
          console.error(`Error fetching user with ID ${id}:`, error);
          return null;
        }
      })
    );
    const filtered_users = unique_users.filter(user => user !== null);
    console.log(filtered_users);
    res.json(filtered_users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



router.get('/:receiverId', async (req, res) => {
  try {

    console.log(req.params.receiverId);
    console.log(req.user);
    const messages = await Message.find({
      $or: [
        { senderId: req.user._id, receiverId: req.params.receiverId },
        { senderId: req.params.receiverId, receiverId: req.user._id }
      ]
    });
    console.log(messages);
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { senderId, receiverId, text } = req.body;
    const message = new Message({ senderId, receiverId, text });
    await message.save();
    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
