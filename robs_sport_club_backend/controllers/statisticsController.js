const { sql } = require('../db');

// Helper function to fetch data from the database
const executeQuery = async (query, params = []) => {
  const pool = await sql.connect();
  const request = pool.request();

  params.forEach(({ name, type, value }) => {
    request.input(name, type, value);
  });

  return request.query(query);
};

// Get statistics for a specific child
exports.getChildStatistics = async (req, res) => {
  try {
    const { childId } = req.params;

    if (!childId) {
      return res.status(400).json({ success: false, message: 'Child ID is required.' });
    }

    const query = `
      SELECT ChildId, ISNULL(TotalTrainingHours, 0) AS TrainingHours,
             ISNULL(TotalMatchHours, 0) AS MatchHours
      FROM ChildrinStatistics
      WHERE ChildId = @ChildId
    `;

    const result = await executeQuery(query, [{ name: 'ChildId', type: sql.Int, value: childId }]);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, message: 'No statistics found for this child.' });
    }

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    console.error('Error fetching child statistics:', error.message);
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};

// Get all statistics (admin only)
exports.getAllStatistics = async (req, res) => {
  try {
    const { childName } = req.query;

    const query = childName
      ? `
        SELECT cs.ChildId, c.ChildName,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
        WHERE c.ChildName LIKE '%' + @ChildName + '%'
      `
      : `
        SELECT cs.ChildId, c.ChildName,
               ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
               ISNULL(cs.TotalMatchHours, 0) AS MatchHours
        FROM ChildrinStatistics cs
        INNER JOIN Children c ON cs.ChildId = c.Id
      `;

    const params = childName ? [{ name: 'ChildName', type: sql.VarChar, value: childName }] : [];

    const result = await executeQuery(query, params);

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    console.error('Error fetching all statistics:', error.message);
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};

// Get statistics for a user's children
exports.getUserStatistics = async (req, res) => {
  try {
    const userId = req.user.id;

    const query = `
      SELECT cs.ChildId, c.ChildName,
             ISNULL(cs.TotalTrainingHours, 0) AS TrainingHours,
             ISNULL(cs.TotalMatchHours, 0) AS MatchHours
      FROM ChildrinStatistics cs
      INNER JOIN Children c ON cs.ChildId = c.Id
      WHERE c.UserId = @UserId
    `;

    const result = await executeQuery(query, [{ name: 'UserId', type: sql.Int, value: userId }]);

    res.status(200).json({ success: true, data: result.recordset });
  } catch (error) {
    console.error('Error fetching user statistics:', error.message);
    res.status(500).json({ success: false, message: 'Error fetching statistics', error: error.message });
  }
};
