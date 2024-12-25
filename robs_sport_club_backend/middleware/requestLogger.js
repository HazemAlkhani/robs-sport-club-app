const fs = require('fs');
const path = require('path');

// Create a write stream for logging requests to a file
const logFile = path.join(__dirname, '../logs/requests.log');
const logStream = fs.createWriteStream(logFile, { flags: 'a' });

const requestLogger = (req, res, next) => {
  const timestamp = new Date().toISOString();
  const { method, url, headers, body } = req;

  // Log the request details
  const logEntry = `
[${timestamp}] ${method} ${url}
Headers: ${JSON.stringify(headers, null, 2)}
Body: ${JSON.stringify(body, null, 2)}
---
  `;

  // Write to console for real-time debugging
  console.log(logEntry);

  // Append log to file
  logStream.write(logEntry);

  next(); // Pass control to the next middleware
};

module.exports = requestLogger;
