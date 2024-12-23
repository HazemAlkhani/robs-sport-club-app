const { connectDB, healthCheck } = require('../db');

(async () => {
  try {
    console.log('Starting database connection test...');

    // Attempt to connect to the database
    await connectDB();
    console.log('Database connection successful.');

    // Perform a health check query
    await healthCheck();
    console.log('Database health check passed. Database is operational.');
  } catch (error) {
    console.error('Database test failed:', error.message);
  } finally {
    process.exit(0); // Ensure the process exits after the test
  }
})();
