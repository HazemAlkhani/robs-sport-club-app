const { sql } = require('../db');

// Helper for consistent responses
const sendResponse = (res, success, message, data = null) => {
  res.status(success ? 200 : 500).json({ success, message, data });
};

// Register a User or Admin
exports.register = async (req, res) => {
  try {
    const { name, email, password, mobile, role } = req.body;

    if (!['admin', 'user'].includes(role)) {
      return sendResponse(res, false, 'Invalid role. Role must be "admin" or "user".');
    }

    const tableName = role === 'admin' ? 'Admins' : 'Users';
    const columns = role === 'admin'
      ? 'Name, Email, Password, Mobile, Role, CreatedAt, UpdatedAt'
      : 'ParentName, Email, Password, Mobile, Role, CreatedAt, UpdatedAt';

    const query = `
      INSERT INTO ${tableName} (${columns})
      VALUES (@Name, @Email, @Password, @Mobile, @Role, GETDATE(), GETDATE())
    `;

    const pool = await sql.connect();
    await pool.request()
      .input('Name', sql.VarChar, name)
      .input('Email', sql.VarChar, email)
      .input('Password', sql.VarChar, password)
      .input('Mobile', sql.VarChar, mobile)
      .input('Role', sql.VarChar, role)
      .query(query);

    sendResponse(res, true, `${role.charAt(0).toUpperCase() + role.slice(1)} registered successfully.`);
  } catch (error) {
    console.error('Error registering user/admin:', error.message);
    sendResponse(res, false, 'Error registering user/admin', error.message);
  }
};

// Get all users with pagination
exports.getAllUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const query = `
      SELECT * FROM Users
      ORDER BY CreatedAt DESC
      OFFSET @Offset ROWS FETCH NEXT @Limit ROWS ONLY
    `;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('Offset', sql.Int, offset)
      .input('Limit', sql.Int, limit)
      .query(query);

    sendResponse(res, true, 'Users fetched successfully', {
      users: result.recordset,
      pagination: { page, limit },
    });
  } catch (error) {
    console.error('Error fetching users:', error.message);
    sendResponse(res, false, 'Error fetching users', error.message);
  }
};

// Other methods (getUserById, updateUser, deleteUser) remain similar

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
