const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { sql } = require('../db');

// Register
exports.register = async (req, res) => {
  try {
    const { name, email, password, role, mobile } = req.body;

    const pool = await sql.connect();

    // Check if email already exists in Admins or Users
    const existingEmailQuery = `
      SELECT Email FROM Admins WHERE Email = @Email
      UNION
      SELECT Email FROM Users WHERE Email = @Email
    `;
    const existingEmailResult = await pool.request()
      .input('Email', sql.VarChar, email)
      .query(existingEmailQuery);

    if (existingEmailResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Build query and values based on role
    const query = role === 'admin'
      ? `
        INSERT INTO Admins (Name, Email, Password, Mobile, Role, CreatedAt, UpdatedAt)
        VALUES (@Name, @Email, @Password, @Mobile, @Role, GETDATE(), GETDATE())
      `
      : `
        INSERT INTO Users (ParentName, Email, Password, Mobile, Role, CreatedAt, UpdatedAt)
        VALUES (@Name, @Email, @Password, @Mobile, @Role, GETDATE(), GETDATE())
      `;

    const values = {
      Name: name,
      Email: email,
      Password: hashedPassword,
      Mobile: mobile,
      Role: role,
    };

    // Execute the query
    await pool.request()
      .input('Name', sql.VarChar, values.Name)
      .input('Email', sql.VarChar, values.Email)
      .input('Password', sql.VarChar, values.Password)
      .input('Mobile', sql.VarChar, values.Mobile)
      .input('Role', sql.VarChar, values.Role)
      .query(query);

    res.status(201).json({ message: `${role === 'admin' ? 'Admin' : 'User'} registered successfully` });
  } catch (error) {
    console.error('Error registering:', error.message);
    res.status(500).json({ message: 'Error registering', error: error.message });
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const query = `
      SELECT Id, ParentName AS Name, Mobile, Email, Password, Role
      FROM Users
      WHERE Email = @Email
      UNION
      SELECT Id, Name, Mobile, Email, Password, Role
      FROM Admins
      WHERE Email = @Email
    `;
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
        name: user.Name,
        email: user.Email,
        role: user.Role,
        mobile: user.Mobile,
      },
    });
  } catch (error) {
    console.error('Error logging in:', error.message);
    res.status(500).json({ message: 'Error logging in', error: error.message });
  }
};