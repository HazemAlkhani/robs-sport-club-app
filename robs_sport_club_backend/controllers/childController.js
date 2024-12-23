const { sql } = require('../db'); // Import database connection

// Create a new child
exports.createChild = async (req, res) => {
  try {
    const { childName, userId, teamNo } = req.body;

    // Assuming you're inserting the new child into the database
    const query = `
      INSERT INTO Children (ChildName, UserId, TeamNo, CreatedAt, UpdatedAt)
      VALUES (@ChildName, @UserId, @TeamNo, GETDATE(), GETDATE())
    `;

    const pool = await sql.connect();
    await pool.request()
      .input('ChildName', sql.VarChar, childName)
      .input('UserId', sql.Int, userId)
      .input('TeamNo', sql.VarChar, teamNo)
      .query(query);

    res.status(201).json({ message: 'Child created successfully' });
  } catch (error) {
    console.error('Error creating child:', error.message);
    res.status(500).json({ message: 'Error creating child', error: error.message });
  }
};

// Get all children
exports.getAllChildren = async (req, res) => {
  try {
    const query = `SELECT * FROM Children`;

    const pool = await sql.connect();
    const result = await pool.request().query(query);

    res.status(200).json(result.recordset);  // Return all children records
  } catch (error) {
    console.error('Error fetching children:', error.message);
    res.status(500).json({ message: 'Error fetching children', error: error.message });
  }
};

// Get a child by ID
exports.getChildById = async (req, res) => {
  try {
    const { id } = req.params; // Get child ID from the URL parameters

    const query = `SELECT * FROM Children WHERE Id = @Id`;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Child not found' });
    }

    res.status(200).json(result.recordset[0]); // Return the child record
  } catch (error) {
    console.error('Error fetching child:', error.message);
    res.status(500).json({ message: 'Error fetching child', error: error.message });
  }
};

// Update a child by ID
exports.updateChild = async (req, res) => {
  try {
    const { id } = req.params;  // Get child ID from the URL
    const { childName, userId, teamNo } = req.body;  // Get updated child data from request body

    const query = `
      UPDATE Children
      SET ChildName = @ChildName, UserId = @UserId, TeamNo = @TeamNo, UpdatedAt = GETDATE()
      WHERE Id = @Id
    `;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('ChildName', sql.VarChar, childName)
      .input('UserId', sql.Int, userId)
      .input('TeamNo', sql.VarChar, teamNo)
      .input('Id', sql.Int, id)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'Child not found to update' });
    }

    res.status(200).json({ message: 'Child updated successfully' });
  } catch (error) {
    console.error('Error updating child:', error.message);
    res.status(500).json({ message: 'Error updating child', error: error.message });
  }
};

// Delete a child by ID
exports.deleteChild = async (req, res) => {
  try {
    const { id } = req.params;  // Get child ID from the URL

    const query = `DELETE FROM Children WHERE Id = @Id`;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'Child not found to delete' });
    }

    res.status(204).send();  // Send "no content" response after successful deletion
  } catch (error) {
    console.error('Error deleting child:', error.message);
    res.status(500).json({ message: 'Error deleting child', error: error.message });
  }
};
