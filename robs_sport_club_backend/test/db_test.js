const { connectDB, healthCheck } = require('../db');

(async () => {
  try {
    console.log('Starting database test...');
    await connectDB();
    await healthCheck();
    console.log('Database is operational.');
  } catch (error) {
    console.error('Database test failed:', error);
  } finally {
    process.exit(0); // Ensure the process exits after the test
  }
})();
