const { sql } = require('../db');

// Create a new user
exports.createUser = async (req, res) => {
  try {
    const { parentName, email, mobile, sportType, username } = req.body;

    // Validate required fields
    if (!parentName || !email || !mobile || !sportType || !username) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const query = `
      INSERT INTO Users (ParentName, Email, Mobile, SportType, Username, CreatedAt, UpdatedAt)
      VALUES (@ParentName, @Email, @Mobile, @SportType, @Username, GETDATE(), GETDATE())
    `;
    const pool = await sql.connect();
    await pool.request()
      .input('ParentName', sql.VarChar, parentName)
      .input('Email', sql.VarChar, email)
      .input('Mobile', sql.VarChar, mobile)
      .input('SportType', sql.VarChar, sportType)
      .input('Username', sql.VarChar, username)
      .query(query);

    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    console.error('Error creating user:', error.message);
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
};

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const query = `SELECT * FROM Users`;
    const pool = await sql.connect();
    const result = await pool.request().query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'No users found' });
    }

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching users:', error.message);
    res.status(500).json({ message: 'Error fetching users', error: error.message });
  }
};

// Get user by ID
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `SELECT * FROM Users WHERE Id = @Id`;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(result.recordset[0]);
  } catch (error) {
    console.error('Error fetching user by ID:', error.message);
    res.status(500).json({ message: 'Error fetching user by ID', error: error.message });
  }
};

// Update a user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { parentName, email, mobile, sportType, username } = req.body;

    // Validate required fields
    if (!parentName || !email || !mobile || !sportType || !username) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const query = `
      UPDATE Users
      SET ParentName = @ParentName, Email = @Email, Mobile = @Mobile,
          SportType = @SportType, Username = @Username, UpdatedAt = GETDATE()
      WHERE Id = @Id
    `;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .input('ParentName', sql.VarChar, parentName)
      .input('Email', sql.VarChar, email)
      .input('Mobile', sql.VarChar, mobile)
      .input('SportType', sql.VarChar, sportType)
      .input('Username', sql.VarChar, username)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User updated successfully' });
  } catch (error) {
    console.error('Error updating user:', error.message);
    res.status(500).json({ message: 'Error updating user', error: error.message });
  }
};

// Delete a user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `DELETE FROM Users WHERE Id = @Id`;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error.message);
    res.status(500).json({ message: 'Error deleting user', error: error.message });
  }
};
