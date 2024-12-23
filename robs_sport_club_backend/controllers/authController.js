const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { sql } = require('../db');

// Register a new user
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    const query = `
      INSERT INTO Users (Email, ParentName, Password, Role, CreatedAt, UpdatedAt)
      VALUES (@Email, @Name, @Password, @Role, GETDATE(), GETDATE())
    `;
    const pool = await sql.connect();
    await pool.request()
      .input('Email', sql.VarChar, email)
      .input('Name', sql.VarChar, name)
      .input('Password', sql.VarChar, hashedPassword)
      .input('Role', sql.VarChar, 'user') // Default role is 'user'
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

    const query = `SELECT * FROM Users WHERE Email = @Email`;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Email', sql.VarChar, email)
      .query(query);

    const user = result.recordset[0];
    if (!user) return res.status(404).json({ message: 'No account associated with this email' });

    const isMatch = await bcrypt.compare(password, user.Password);
    if (!isMatch) return res.status(401).json({ message: 'Incorrect password' });

    const token = jwt.sign(
      { id: user.Id, email: user.Email, role: user.Role },
      process.env.JWT_SECRET,
      { expiresIn: '1h', issuer: 'robs-sport-club' }
    );

    res.status(200).json({
      token,
      user: {
        id: user.Id,
        name: user.ParentName,
        email: user.Email,
        role: user.Role,
      },
    });
  } catch (error) {
    console.error('Error logging in:', error.message);
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
};
