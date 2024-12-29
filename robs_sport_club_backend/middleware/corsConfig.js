const allowedOrigins = [
  /^http:\/\/localhost:\d+$/ // Allow any localhost with a port
];

const corsOptions = {
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.some((allowed) => allowed.test(origin))) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
};
