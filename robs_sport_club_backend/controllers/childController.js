const { sql } = require('../db');

// Add a child
exports.addChild = async (req, res, next) => {
  try {
    const { ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id;

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

    // Check if the insertion was successful
    if (result.recordset.length === 0) {
      console.log('No child added, potential duplication or invalid data.');
      return res.status(400).json({ success: false, message: 'Failed to add child. Check input data or possible duplication.' });
    }

    console.log('Child added successfully:', result.recordset[0]); // Logging
    res.status(201).json({
      success: true,
      message: 'Child added successfully',
      child: result.recordset[0],
    });
  } catch (error) {
    console.error('Error adding child:', error.message);
    next(error);
  }
};

// Update a child
exports.updateChild = async (req, res, next) => {
  try {
    const { ChildId, ChildName, TeamNo, SportType } = req.body;
    const UserId = req.user.id;

    if (!ChildId || isNaN(ChildId)) {
      return res.status(400).json({ message: 'Invalid ChildId provided.' });
    }

    const pool = await sql.connect();
    const ownershipQuery = `SELECT COUNT(*) AS IsOwner FROM Children WHERE Id = @ChildId AND UserId = @UserId`;
    const ownershipResult = await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('UserId', sql.Int, UserId)
      .query(ownershipQuery);

    if (ownershipResult.recordset[0].IsOwner === 0) {
      return res.status(403).json({ message: 'You do not have permission to update this child.' });
    }

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

    console.log('Child updated successfully:', { ChildId, ChildName, TeamNo, SportType });
    res.status(200).json({ message: 'Child updated successfully' });
  } catch (error) {
    console.error('Error updating child:', error.message);
    next(error);
  }
};

// Get children
exports.getChildren = async (req, res) => {
  try {
    const { role, id: userId } = req.user; // Extract role and user ID from the authenticated user
    const { name, userId: queryUserId } = req.query; // Get optional filters: child name and userId

    // Base query for fetching children
    let query = `SELECT * FROM Children`;

    // Adjust query based on role and filters
    if (role !== 'admin' || queryUserId) {
      // Add filter by userId for non-admins or if userId is explicitly provided
      query += ` WHERE UserId = @UserId`;
    }

    if (name) {
      // Add name filter
      query += query.includes('WHERE')
        ? ` AND ChildName LIKE '%' + @ChildName + '%'`
        : ` WHERE ChildName LIKE '%' + @ChildName + '%'`;
    }

    const pool = await sql.connect();
    const request = pool.request();

    // Bind userId from the request or query (prioritize query parameter)
    if (role !== 'admin' || queryUserId) {
      request.input('UserId', sql.Int, queryUserId || userId);
    }

    // Bind name parameter if provided
    if (name) {
      request.input('ChildName', sql.NVarChar, name);
    }

    const result = await request.query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({
        message: role === 'admin'
          ? 'No children found.'
          : 'You have no children matching the criteria.',
      });
    }

    res.status(200).json({
      success: true,
      data: result.recordset,
    });
  } catch (error) {
    console.error('Error fetching children:', error.message);
    res.status(500).json({
      success: false,
      message: 'Error fetching children',
      error: error.message,
    });
  }
};



// Fetch children by team and sport
exports.getChildrenByTeamAndSport = async (req, res) => {
  const { teamNo, sportType } = req.query;

  if (!teamNo || !sportType) {
    return res.status(400).json({ message: 'Team number and sport type are required' });
  }

  try {
    const pool = await sql.connect();
    const query = `
      SELECT * FROM Children
      WHERE TeamNo = @TeamNo AND SportType = @SportType
    `;
    const result = await pool.request()
      .input('TeamNo', sql.NVarChar, teamNo)
      .input('SportType', sql.NVarChar, sportType)
      .query(query);

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'No children found for the specified team and sport.' });
    }

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    console.error('Error fetching children by team and sport:', error.message);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};


// Delete a child
exports.deleteChild = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id || isNaN(id)) {
      return res.status(400).json({ message: 'Invalid ChildId provided.' });
    }

    const pool = await sql.connect();
    const ownershipQuery = `SELECT COUNT(*) AS IsOwner FROM Children WHERE Id = @Id AND UserId = @UserId`;
    const ownershipResult = await pool.request()
      .input('Id', sql.Int, id)
      .input('UserId', sql.Int, req.user.id)
      .query(ownershipQuery);

    if (ownershipResult.recordset[0].IsOwner === 0) {
      return res.status(403).json({ message: 'You do not have permission to delete this child.' });
    }

    const deleteQuery = `DELETE FROM Children WHERE Id = @Id`;
    await pool.request().input('Id', sql.Int, id).query(deleteQuery);

    console.log('Child deleted successfully:', { id });
    res.status(200).json({ message: 'Child deleted successfully' });
  } catch (error) {
    console.error('Error deleting child:', error.message);
    res.status(500).json({ message: 'Error deleting child', error: error.message });
  }
};
