const cors = require('cors');

const allowedOrigins = [
  'http://localhost:5000', // The only allowed origin for your app
];

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      // Allow requests with no origin (e.g., mobile apps, Postman) or allowed origins
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  exposedHeaders: ['Authorization'], // Allow the client to access the Authorization header
  credentials: true,                // Allow credentials (e.g., cookies, authorization headers)
  optionsSuccessStatus: 204,        // Response status for successful preflight requests
};

module.exports = cors(corsOptions);
