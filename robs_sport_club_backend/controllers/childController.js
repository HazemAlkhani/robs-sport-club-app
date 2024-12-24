const { sql } = require('../db');

// Add a child
exports.addChild = async (req, res) => {
  try {
    // Extract data from the request body and authenticated user's ID
    const { ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id; // Get UserId from the authenticated user token

    // SQL query to insert the child into the database
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



// Get  children
exports.getChildren = async (req, res) => {
  try {
    const UserId = req.user.id; // Get UserId from authenticated user token

    // Fetch children for the authenticated user
    const query = `SELECT * FROM Children WHERE UserId = @UserId`;
    const pool = await sql.connect();
    const result = await pool.request()
      .input('UserId', sql.Int, UserId)
      .query(query);

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching children:', error.message);
    res.status(500).json({ message: 'Error fetching children', error: error.message });
  }
};



// Update a child
exports.updateChild = async (req, res) => {
  try {
    const { ChildId, ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id; // Get UserId from authenticated user token

    // Ensure the child belongs to the authenticated user
    const ownershipQuery = `SELECT COUNT(*) AS IsOwner FROM Children WHERE Id = @ChildId AND UserId = @UserId`;
    const pool = await sql.connect();
    const ownershipResult = await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('UserId', sql.Int, UserId)
      .query(ownershipQuery);

    if (ownershipResult.recordset[0].IsOwner === 0) {
      return res.status(403).json({ message: 'You do not have permission to update this child' });
    }

    // Update child data
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


// Delete a child
exports.deleteChild = async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'DELETE FROM Children WHERE Id = @Id';
    const pool = await sql.connect();
    await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    res.status(200).json({ message: 'Child deleted successfully' });
  } catch (error) {
    console.error('Error deleting child:', error.message);
    res.status(500).json({ message: 'Error deleting child', error: error.message });
  }
};
