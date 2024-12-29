const fs = require('fs');
const path = require('path');

// Create a write stream for logging requests to a file
const logFile = path.join(__dirname, '../logs/requests.log');
const logStream = fs.createWriteStream(logFile, { flags: 'a' });

const requestLogger = (req, res, next) => {
  const timestamp = new Date().toISOString();
  const { method, url, headers, body } = req;

  // Mask sensitive headers
  const sanitizedHeaders = { ...headers };
  if (sanitizedHeaders.authorization) {
    sanitizedHeaders.authorization = '[REDACTED]';
  }

  // Log the request details
  const logEntry = `
[${timestamp}] ${method} ${url}
Headers: ${JSON.stringify(sanitizedHeaders, null, 2)}
Body: ${JSON.stringify(body, null, 2)}
---
  `;

  // Write to console for debugging (toggle via environment variable)
  if (process.env.ENABLE_CONSOLE_LOGGING === 'true') {
    console.log(logEntry);
  }

  // Append log to file with error handling
  logStream.write(logEntry, (err) => {
    if (err) {
      console.error('Failed to write request log:', err.message);
    }
  });

  next(); // Pass control to the next middleware
};

module.exports = requestLogger;
