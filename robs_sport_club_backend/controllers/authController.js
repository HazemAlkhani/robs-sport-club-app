const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { sql } = require('../db');
const User = require('../models/User');


// Register a new user
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user into the database with parameterized query
    const query = `
      INSERT INTO Users (Email, ParentName, Password, CreatedAt, UpdatedAt)
      VALUES (@Email, @Name, @Password, GETDATE(), GETDATE())
    `;
    const pool = await sql.connect();
    await pool.request()
      .input('Email', sql.VarChar, email)
      .input('Name', sql.VarChar, name)
      .input('Password', sql.VarChar, hashedPassword)
      .query(query);

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error('Error registering user:', error.message);
    res.status(500).json({ message: 'Error registering user', error: error.message });
  }
};



// Login an existing user
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Retrieve user from the database
    const query = `SELECT * FROM Users WHERE Email = @Email`;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Email', sql.VarChar, email)
      .query(query);

    const user = result.recordset[0];

    if (!user) return res.status(400).json({ message: 'User not found' });

    // Compare hashed passwords
    const isMatch = await bcrypt.compare(password, user.Password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    // Generate JWT token
    const token = jwt.sign({ id: user.Id, email: user.Email }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(200).json({ token });
  } catch (error) {
    console.error('Error logging in:', error.message);
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
};
