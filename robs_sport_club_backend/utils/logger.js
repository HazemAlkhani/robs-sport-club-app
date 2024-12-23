const { createLogger, transports, format } = require('winston');

const logger = createLogger({
  level: 'info', // Default logging level
  format: format.combine(
    format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    format.printf(({ timestamp, level, message }) => `[${timestamp}] ${level.toUpperCase()}: ${message}`)
  ),
  transports: [
    new transports.Console({ format: format.colorize({ all: true }) }), // Log to the console with colors
    new transports.File({ filename: 'logs/app.log', level: 'info' }), // Log info and above to a file
    new transports.File({ filename: 'logs/error.log', level: 'error' }), // Log errors to a separate file
  ],
});

// Log uncaught exceptions and rejections
logger.exceptions.handle(
  new transports.File({ filename: 'logs/exceptions.log' })
);
logger.rejections.handle(
  new transports.File({ filename: 'logs/rejections.log' })
);

module.exports = logger;
