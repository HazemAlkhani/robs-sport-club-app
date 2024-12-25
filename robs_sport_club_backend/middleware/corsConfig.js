const cors = require('cors');

const allowedOrigins = [
  'http://localhost:5000', // Adjust this for other environments if needed
];

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      // Allow requests with no origin (e.g., Postman) or allowed origins
      callback(null, true);
    } else {
      console.error(`Blocked by CORS: Origin ${origin} is not allowed.`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'], // Allowed HTTP methods
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'Accept',
  ], // Allowed headers in the requests
  exposedHeaders: ['Authorization'], // Expose Authorization header for the client
  credentials: true, // Allow credentials (e.g., cookies, authorization headers)
  optionsSuccessStatus: 204, // Response status for successful preflight requests
};

module.exports = cors(corsOptions);
