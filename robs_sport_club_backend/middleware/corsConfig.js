const cors = require('cors');

const corsOptions = {
  origin: 'https://your-frontend-domain.com', // Replace with your frontend's URL
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

module.exports = cors(corsOptions);
