module.exports = {
  env: {
    browser: false, // Since this is a Node.js project
    node: true,
    es2021: true,
  },
  extends: [
    'eslint:recommended', // ESLint recommended rules
    'plugin:react/recommended', // React-specific rules (optional, for React projects)
    'prettier', // Disable conflicting rules with Prettier
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  rules: {
    // Add or override specific rules here
    'no-console': 'off', // Allow console logs
    'semi': ['error', 'always'], // Require semicolons
  },
};
