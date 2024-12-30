const { sql } = require('../db');

// Helper function to execute queries
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

// Get all statistics (admin only) or statistics by child name
exports.getAllStatistics = async (req, res, next) => {
  try {
    const { childName } = req.query;

    const query = childName
      ? `
        SELECT cs.Id, cs.ChildId, c.ChildName, cs.Year,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
        WHERE c.ChildName LIKE '%' + @ChildName + '%'
      `
      : `
        SELECT cs.Id, cs.ChildId, c.ChildName, cs.Year,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
      `;

    const params = childName ? [{ name: 'ChildName', type: sql.VarChar, value: childName }] : [];
    const result = await executeQuery(query, params);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found.' });
    }

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    next(error);
  }
};

// Get user-specific statistics
exports.getUserStatistics = async (req, res, next) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized access.' });
    }

    const query = `
      SELECT cs.Id, cs.ChildId, c.ChildName, cs.Year,
             ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
             ISNULL(cs.TotalMatchHours, 0) AS MatchHours
      FROM ChildrinStatistics cs
      INNER JOIN Children c ON cs.ChildId = c.Id
      WHERE c.UserId = @UserId
    `;

    const params = [{ name: 'UserId', type: sql.Int, value: userId }];
    const result = await executeQuery(query, params);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found for your children.' });
    }

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    next(error);
  }
};

exports.getChildStatistics = async (req, res) => {
  try {
    const { childId } = req.params;

    const query = `
      SELECT ChildId, ISNULL(TotalTrainingHours, 0) AS TrainingHours, ISNULL(TotalMatchHours, 0) AS MatchHours
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
