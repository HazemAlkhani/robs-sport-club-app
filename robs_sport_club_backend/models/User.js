const sql = require('../db');

class User {
  constructor(id, parentName, email, mobile, sportType, username, role, createdAt, updatedAt) {
    this.id = id;
    this.parentName = parentName;
    this.email = email;
    this.mobile = mobile;
    this.sportType = sportType;
    this.username = username;
    this.role = role || 'user'; // Default role is 'user'
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
  }

  // Create a new user
  static async createUser(parentName, email, mobile, sportType, username, hashedPassword, role = 'user') {
    try {
      const query = `
        INSERT INTO Users (ParentName, Email, Mobile, SportType, Username, Password, Role, CreatedAt, UpdatedAt)
        OUTPUT INSERTED.*
        VALUES (@ParentName, @Email, @Mobile, @SportType, @Username, @Password, @Role, GETDATE(), GETDATE())
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ParentName', sql.VarChar, parentName)
        .input('Email', sql.VarChar, email)
        .input('Mobile', sql.VarChar, mobile)
        .input('SportType', sql.VarChar, sportType)
        .input('Username', sql.VarChar, username)
        .input('Password', sql.VarChar, hashedPassword)
        .input('Role', sql.VarChar, role)
        .query(query);

      return result.recordset[0]; // Return the created user
    } catch (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }
  }

  // Get all users
  static async getAllUsers() {
    try {
      const query = `SELECT * FROM Users`;
      const pool = await sql.connect();
      const result = await pool.request().query(query);

      return result.recordset; // Return all users
    } catch (error) {
      throw new Error(`Error fetching users: ${error.message}`);
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
      throw new Error(`Error fetching user by ID: ${error.message}`);
    }
  }

  // Find user by email
  static async findByEmail(email) {
    try {
      const query = `SELECT * FROM Users WHERE Email = @Email`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Email', sql.VarChar, email)
        .query(query);

      return result.recordset[0] || null; // Return the user or null if not found
    } catch (error) {
      throw new Error(`Error finding user by email: ${error.message}`);
    }
  }

  // Update a user
  static async updateUser(id, parentName, email, mobile, sportType, username, role) {
    try {
      const query = `
        UPDATE Users
        SET ParentName = @ParentName, Email = @Email, Mobile = @Mobile,
            SportType = @SportType, Username = @Username, Role = @Role, UpdatedAt = GETDATE()
        WHERE Id = @Id
        OUTPUT INSERTED.*
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('ParentName', sql.VarChar, parentName)
        .input('Email', sql.VarChar, email)
        .input('Mobile', sql.VarChar, mobile)
        .input('SportType', sql.VarChar, sportType)
        .input('Username', sql.VarChar, username)
        .input('Role', sql.VarChar, role)
        .query(query);

      return result.recordset[0] || null; // Return the updated user or null if not found
    } catch (error) {
      throw new Error(`Error updating user: ${error.message}`);
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
      throw new Error(`Error deleting user: ${error.message}`);
    }
  }
}

module.exports = User;
