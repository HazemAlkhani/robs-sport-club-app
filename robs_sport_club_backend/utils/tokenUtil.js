const jwt = require('jsonwebtoken');

class TokenUtil {
  /**
   * Generate a new JWT
   * @param {Object} payload - The payload to encode in the token
   * @param {string} expiresIn - Token expiration time (e.g., '1h', '7d')
   * @returns {string} - The generated JWT
   */
  static generateToken(payload, expiresIn = '1h') {
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
  }

  /**
   * Verify a JWT
   * @param {string} token - The token to verify
   * @returns {Object} - The decoded payload
   * @throws {Error} - If the token is invalid or expired
   */
  static verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new Error('Invalid or expired token');
    }
  }

  /**
   * Decode a JWT without verification (useful for inspecting payload)
   * @param {string} token - The token to decode
   * @returns {Object} - The decoded payload
   */
  static decodeToken(token) {
    return jwt.decode(token);
  }
}

module.exports = TokenUtil;
