const sql = require('../db');
const bcrypt = require('bcrypt');

class User {
  constructor(id, email, password, role, createdAt, updatedAt) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.role = role;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
  }

  // Create a new user
  static async createUser(email, password, role) {
    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      const query = `
        INSERT INTO Users (Email, Password, Role, CreatedAt, UpdatedAt)
        OUTPUT INSERTED.*
        VALUES (@Email, @Password, @Role, GETDATE(), GETDATE())
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Email', sql.NVarChar, email)
        .input('Password', sql.NVarChar, hashedPassword)
        .input('Role', sql.NVarChar, role)
        .query(query);

      return result.recordset[0]; // Return the created user
    } catch (error) {
      console.error('Error creating user:', error.message);
      throw new Error('Failed to create user');
    }
  }

  // Get user by email
  static async getUserByEmail(email) {
    try {
      const query = `SELECT * FROM Users WHERE Email = @Email`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Email', sql.NVarChar, email)
        .query(query);

      return result.recordset[0] || null; // Return the user or null if not found
    } catch (error) {
      console.error('Error fetching user by email:', error.message);
      throw new Error('Failed to fetch user by email');
    }
  }

  // Get user by ID
  static async getUserById(id) {
    try {
      const query = `SELECT * FROM Users WHERE Id = @Id`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the user or null if not found
    } catch (error) {
      console.error('Error fetching user by ID:', error.message);
      throw new Error('Failed to fetch user by ID');
    }
  }

  // Update a user
  static async updateUser(id, email, password, role) {
    try {
      const hashedPassword = password ? await bcrypt.hash(password, 10) : null;
      const query = `
        UPDATE Users
        SET Email = @Email, Password = COALESCE(@Password, Password), Role = @Role, UpdatedAt = GETDATE()
        WHERE Id = @Id
        OUTPUT INSERTED.*
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('Email', sql.NVarChar, email)
        .input('Password', sql.NVarChar, hashedPassword)
        .input('Role', sql.NVarChar, role)
        .query(query);

      return result.recordset[0] || null; // Return the updated user or null if not found
    } catch (error) {
      console.error('Error updating user:', error.message);
      throw new Error('Failed to update user');
    }
  }

  // Delete a user
  static async deleteUser(id) {
    try {
      const query = `DELETE FROM Users WHERE Id = @Id OUTPUT DELETED.*`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the deleted user or null if not found
    } catch (error) {
      console.error('Error deleting user:', error.message);
      throw new Error('Failed to delete user');
    }
  }

  // Validate user credentials
  static async validateUser(email, password) {
    try {
      const user = await this.getUserByEmail(email);
      if (!user) {
        throw new Error('Invalid email or password');
      }

      const isValidPassword = await bcrypt.compare(password, user.Password);
      if (!isValidPassword) {
        throw new Error('Invalid email or password');
      }

      return user; // Return the user if credentials are valid
    } catch (error) {
      console.error('Error validating user:', error.message);
      throw new Error('Failed to validate user');
    }
  }
}

module.exports = User;
