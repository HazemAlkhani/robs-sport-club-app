const { sql } = require('../db');

// Add a child
exports.addChild = async (req, res) => {
  try {
    const { ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id;

    // Validate required fields
    if (!ChildName || !TeamNo || !SportType) {
      return res.status(400).json({ message: 'ChildName, TeamNo, and SportType are required.' });
    }

    // SQL Query
    const query = `
      INSERT INTO Children (ChildName, UserId, TeamNo, SportType, CreatedAt, UpdatedAt)
      VALUES (@ChildName, @UserId, @TeamNo, @SportType, GETDATE(), GETDATE())
    `;

    const pool = await sql.connect();
    await pool.request()
      .input('ChildName', sql.NVarChar, ChildName)
      .input('UserId', sql.Int, UserId)
      .input('TeamNo', sql.NVarChar, TeamNo)
      .input('SportType', sql.NVarChar, SportType)
      .query(query);

    res.status(201).json({ message: 'Child added successfully' });
  } catch (error) {
    console.error('Error adding child:', error.message);
    res.status(500).json({ message: 'Error adding child', error: error.message });
  }
};

exports.updateChild = async (req, res) => {
  try {
    const { ChildId, ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id;

    if (!ChildId || isNaN(ChildId)) {
      return res.status(400).json({ message: 'Invalid ChildId provided.' });
    }

    const pool = await sql.connect();

    // Ensure ownership
    const ownershipQuery = `SELECT COUNT(*) AS IsOwner FROM Children WHERE Id = @ChildId AND UserId = @UserId`;
    const ownershipResult = await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('UserId', sql.Int, UserId)
      .query(ownershipQuery);

    if (ownershipResult.recordset[0].IsOwner === 0) {
      return res.status(403).json({ message: 'You do not have permission to update this child.' });
    }

    // Update child
    const updateQuery = `
      UPDATE Children
      SET ChildName = @ChildName, TeamNo = @TeamNo, SportType = @SportType, UpdatedAt = GETDATE()
      WHERE Id = @ChildId
    `;
    await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('ChildName', sql.NVarChar, ChildName)
      .input('TeamNo', sql.NVarChar, TeamNo)
      .input('SportType', sql.NVarChar, SportType)
      .query(updateQuery);

    res.status(200).json({ message: 'Child updated successfully' });
  } catch (error) {
    console.error('Error updating child:', error.message);
    res.status(500).json({ message: 'Error updating child', error: error.message });
  }
};


// Get children
exports.getChildren = async (req, res) => {
  try {
    const UserId = req.user.id;

    const query = `SELECT * FROM Children WHERE UserId = @UserId`;
    const pool = await sql.connect();
    const result = await pool.request().input('UserId', sql.Int, UserId).query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'No children found for this user.' });
    }

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching children:', error.message);
    res.status(500).json({ message: 'Error fetching children', error: error.message });
  }
};

// Update a child
exports.addChild = async (req, res, next) => {
  try {
    const { ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id;

    // Validate required fields
    if (!ChildName || !TeamNo || !SportType) {
      return res.status(400).json({ message: 'ChildName, TeamNo, and SportType are required.' });
    }

    const query = `
      INSERT INTO Children (ChildName, UserId, TeamNo, SportType, CreatedAt, UpdatedAt)
      OUTPUT INSERTED.*
      VALUES (@ChildName, @UserId, @TeamNo, @SportType, GETDATE(), GETDATE())
    `;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('ChildName', sql.NVarChar, ChildName)
      .input('UserId', sql.Int, UserId)
      .input('TeamNo', sql.NVarChar, TeamNo)
      .input('SportType', sql.NVarChar, SportType)
      .query(query);

    res.status(201).json({
      success: true,
      message: 'Child added successfully',
      child: result.recordset[0],
    });
  } catch (error) {
    console.error('Error adding child:', error.message);
    next(error); // Pass to error handler
  }
};

// Delete a child
exports.deleteChild = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || isNaN(id)) {
      return res.status(400).json({ message: 'Invalid ChildId provided.' });
    }

    // Ensure ownership
    const ownershipQuery = `SELECT COUNT(*) AS IsOwner FROM Children WHERE Id = @Id AND UserId = @UserId`;
    const pool = await sql.connect();
    const ownershipResult = await pool.request()
      .input('Id', sql.Int, id)
      .input('UserId', sql.Int, req.user.id)
      .query(ownershipQuery);

    if (ownershipResult.recordset[0].IsOwner === 0) {
      return res.status(403).json({ message: 'You do not have permission to delete this child.' });
    }

    // Delete child
    const deleteQuery = 'DELETE FROM Children WHERE Id = @Id';
    await pool.request().input('Id', sql.Int, id).query(deleteQuery);

    res.status(200).json({ message: 'Child deleted successfully' });
  } catch (error) {
    console.error('Error deleting child:', error.message);
    res.status(500).json({ message: 'Error deleting child', error: error.message });
  }
};
