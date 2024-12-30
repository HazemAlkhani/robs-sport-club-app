const { sql } = require('../db');

// Enhanced helper function with error handling
const executeQuery = async (query, params = []) => {
  try {
    const pool = await sql.connect();
    const request = pool.request();

    params.forEach(({ name, type, value }) => {
      request.input(name, type, value);
    });

    return await request.query(query);
  } catch (error) {
    console.error('Database query failed:', error.message);
    throw new Error('Database operation failed.');
  }
};

// Get statistics for a specific child
exports.getChildStatistics = async (req, res) => {
  try {
    const { childId } = req.params;

    if (!childId || isNaN(childId)) {
      console.warn('Invalid childId provided:', childId);
      return res.status(400).json({ success: false, message: 'Valid Child ID is required.' });
    }

    const query = `
      SELECT ChildId,
             ISNULL(TotalTrainingHours, 0) AS TrainingHours,
             ISNULL(TotalMatchHours, 0) AS MatchHours
      FROM ChildrinStatistics
      WHERE ChildId = @ChildId
    `;

    const result = await executeQuery(query, [{ name: 'ChildId', type: sql.Int, value: childId }]);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found for this child.' });
    }

    res.status(200).json({ success: true, data: result.recordset[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};

// Get all statistics (admin only)
exports.getAllStatistics = async (req, res) => {
  try {
    const { childName, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    const query = childName
      ? `
        SELECT cs.ChildId, c.ChildName,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
        WHERE c.ChildName LIKE '%' + @ChildName + '%'
        ORDER BY c.ChildName
        OFFSET @Offset ROWS FETCH NEXT @Limit ROWS ONLY
      `
      : `
        SELECT cs.ChildId, c.ChildName,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
        ORDER BY c.ChildName
        OFFSET @Offset ROWS FETCH NEXT @Limit ROWS ONLY
      `;

    const params = childName
      ? [
          { name: 'ChildName', type: sql.VarChar, value: childName },
          { name: 'Offset', type: sql.Int, value: offset },
          { name: 'Limit', type: sql.Int, value: parseInt(limit) },
        ]
      : [
          { name: 'Offset', type: sql.Int, value: offset },
          { name: 'Limit', type: sql.Int, value: parseInt(limit) },
        ];

    const result = await executeQuery(query, params);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found.' });
    }

    res.status(200).json({
      success: true,
      data: result.recordset,
      pagination: {
        currentPage: parseInt(page),
        itemsPerPage: parseInt(limit),
        totalItems: result.recordset.length,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};

// Get statistics for a user's children
exports.getUserStatistics = async (req, res) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized access.' });
    }

    const query = `
      SELECT cs.ChildId, c.ChildName,
             ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
             ISNULL(cs.TotalMatchHours, 0) AS MatchHours
      FROM ChildrinStatistics cs
      INNER JOIN Children c ON cs.ChildId = c.Id
      WHERE c.UserId = @UserId
    `;

    const result = await executeQuery(query, [{ name: 'UserId', type: sql.Int, value: userId }]);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found for your children.' });
    }

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};
