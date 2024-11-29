const sql = require('../db');

class User {
  constructor(id, parentName, mobile, email, sportType, createdAt, updatedAt, username, password) {
    this.id = id;
    this.parentName = parentName;
    this.mobile = mobile;
    this.email = email;
    this.sportType = sportType;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.username = username;
    this.password = password;
  }

  // Method to create a new user in the database
  static async createUser(parentName, mobile, email, sportType, username, hashedPassword) {
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ParentName', sql.NVarChar, parentName)
        .input('Mobile', sql.NVarChar, mobile)
        .input('Email', sql.NVarChar, email)
        .input('SportType', sql.NVarChar, sportType)
        .input('Username', sql.NVarChar, username)
        .input('Password', sql.NVarChar, hashedPassword) // Store hashed password only
        .query(`
          INSERT INTO Users (ParentName, Mobile, Email, SportType, Username, Password, CreatedAt, UpdatedAt)
          VALUES (@ParentName, @Mobile, @Email, @SportType, @Username, @Password, GETDATE(), GETDATE());
        `);
      return result.rowsAffected[0] > 0; // Return true if insertion was successful
    } catch (error) {
      throw new Error('Error creating user: ' + error.message);
    }
  }

  // Method to find a user by email
  static async findByEmail(email) {
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Email', sql.NVarChar, email)
        .query(`
          SELECT * FROM Users WHERE Email = @Email;
        `);
      if (result.recordset[0]) {
        const user = result.recordset[0];
        return new User(
          user.Id,
          user.ParentName,
          user.Mobile,
          user.Email,
          user.SportType,
          user.CreatedAt,
          user.UpdatedAt,
          user.Username,
          user.Password // Returning the hashed password
        );
      }
      return null; // Return null if no user is found
    } catch (error) {
      throw new Error('Error finding user by email: ' + error.message);
    }
  }

  // Method to get all user records
  static async getAllUsers() {
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .query(`SELECT * FROM Users`);
      return result.recordset.map(user => new User(
        user.Id,
        user.ParentName,
        user.Mobile,
        user.Email,
        user.SportType,
        user.CreatedAt,
        user.UpdatedAt,
        user.Username,
        user.Password
      ));
    } catch (error) {
      throw new Error('Error retrieving users: ' + error.message);
    }
  }
}

module.exports = User;
