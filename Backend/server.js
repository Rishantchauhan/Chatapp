const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const socketIo = require('socket.io');
const authRoutes = require('./routes/auth');
const messageRoutes = require('./routes/messages');
const userRoutes = require('./routes/users');
const authMiddleware = require('./middleware/auth');
const Message=require('./models/Message');
const jwt = require('jsonwebtoken');
const { SECRET_KEY,MONGO_URI } = require('./config');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/messages', authMiddleware, messageRoutes);
app.use('/api/users', authMiddleware, userRoutes);


io.on('connection', (socket) => {
  console.log('New client connected');
  
  socket.on('message', async (message) => {
    // Save message to the database
      const decoded=jwt.verify(message.senderId,SECRET_KEY);
      console.log(message);
      message.senderId=decoded.userId;
    try {
      const newMessage = new Message(message);
      await newMessage.save();
      
      // Broadcast message to all clients
      io.emit('message', message);
    } catch (error) {
      console.error('Error saving message:', error);
    }
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

mongoose.connect(MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log(err));

server.listen(3000, () => console.log('Server running on port 3000'));
