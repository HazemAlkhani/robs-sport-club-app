module.exports = {
  testEnvironment: 'node', // Use Node.js environment for testing
  testMatch: ['**/test/**/*.test.js'], // Look for test files in the test folder
  transform: {}, // Disable transformation if not using Babel or TypeScript
  verbose: true, // Show detailed test results
  collectCoverage: true, // Enable code coverage reporting
  collectCoverageFrom: [
    '**/*.js', // Collect coverage from all JS files
    '!**/node_modules/**', // Exclude node_modules
    '!**/test/**', // Exclude test files from coverage
  ],
  coverageDirectory: './coverage', // Directory to output coverage reports
  coverageReporters: ['text', 'html'], // Output coverage in text and HTML formats
};
