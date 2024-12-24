const { sql } = require('../db');

// Add participation
exports.addParticipation = async (req, res) => {
  try {
    const { ChildName, ParticipationType, ParticipationDate, TimeStart, TimeEnd, Location } = req.body;
    const adminId = req.user.id; // Authenticated admin ID from the token

    // Validate ParticipationType
    if (!['Training', 'Match'].includes(ParticipationType)) {
      return res.status(400).json({ message: 'Invalid ParticipationType. Must be "Training" or "Match".' });
    }

    const pool = await sql.connect();

    // Fetch ChildId and TeamNo from the Children table
    const childQuery = `
      SELECT Id AS ChildId, TeamNo
      FROM Children
      WHERE ChildName = @ChildName
    `;
    const childResult = await pool.request()
      .input('ChildName', sql.VarChar, ChildName)
      .query(childQuery);

    if (childResult.recordset.length === 0) {
      return res.status(404).json({ message: 'Child not found' });
    }

    const { ChildId, TeamNo } = childResult.recordset[0];

    // Insert into Participation table
    const participationQuery = `
      INSERT INTO Participation (ChildId, ChildName, ParticipationType, TeamNo, Date, TimeStart, TimeEnd, Location, CreatedBy, CreatedAt, UpdatedAt)
      VALUES (@ChildId, @ChildName, @ParticipationType, @TeamNo, @ParticipationDate, @TimeStart, @TimeEnd, @Location, @CreatedBy, GETDATE(), GETDATE());
      SELECT DATEDIFF(MINUTE, @TimeStart, @TimeEnd) / 60.0 AS Hours
    `;
    const participationResult = await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('ChildName', sql.VarChar, ChildName)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .input('TeamNo', sql.VarChar, TeamNo)
      .input('ParticipationDate', sql.Date, ParticipationDate) // Updated parameter
      .input('TimeStart', sql.Time, TimeStart)
      .input('TimeEnd', sql.Time, TimeEnd)
      .input('Location', sql.VarChar, Location)
      .input('CreatedBy', sql.Int, adminId)
      .query(participationQuery);

    const hours = participationResult.recordset[0]?.Hours;

    if (!hours) {
      return res.status(500).json({ message: 'Failed to calculate hours for participation' });
    }

    // Update ChildrinStatistics table
    const columnToUpdate = ParticipationType === 'Training' ? 'TotalTrainingHours' : 'TotalMatchHours';
    const statsQuery = `
      MERGE INTO ChildrinStatistics AS target
      USING (SELECT @ChildId AS ChildId, FORMAT(GETDATE(), 'yyyy-MM') AS MonthYear) AS source
      ON target.ChildId = source.ChildId AND target.MonthYear = source.MonthYear
      WHEN MATCHED THEN
        UPDATE SET ${columnToUpdate} = ${columnToUpdate} + @Hours
      WHEN NOT MATCHED THEN
        INSERT (ChildId, MonthYear, TotalTrainingHours, TotalMatchHours)
        VALUES (@ChildId, FORMAT(GETDATE(), 'yyyy-MM'),
        CASE WHEN @ParticipationType = 'Training' THEN @Hours ELSE 0 END,
        CASE WHEN @ParticipationType = 'Match' THEN @Hours ELSE 0 END);
    `;
    await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('Hours', sql.Float, hours)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .query(statsQuery);

    res.status(201).json({ message: 'Participation added successfully' });
  } catch (error) {
    console.error('Error adding participation:', error.message);
    res.status(500).json({ message: 'Error adding participation', error: error.message });
  }
};


// Fetch all participations (Admin only)
exports.getAllParticipations = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const query = 'SELECT * FROM Participation';
    const pool = await sql.connect();
    const result = await pool.request().query(query);

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching participations:', error.message);
    res.status(500).json({ message: 'Error fetching participations', error: error.message });
  }
};

// Fetch participation for children of a parent (Parent only)
exports.getParticipationByUser = async (req, res) => {
  try {
    const userId = req.user.id;

    const query = `
      SELECT P.* FROM Participation P
      INNER JOIN Children C ON P.ChildId = C.Id
      WHERE C.UserId = @UserId
    `;
    const pool = await sql.connect();
    const result = await pool.request().input('UserId', sql.Int, userId).query(query);

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching participation:', error.message);
    res.status(500).json({ message: 'Error fetching participation', error: error.message });
  }
};

// Update participation (Admin only)
exports.updateParticipation = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const { id } = req.params;
    const { ChildId, ParticipationType, TeamNo, Date, TimeStart, TimeEnd, Location } = req.body;

    const query = `
      UPDATE Participation
      SET ChildId = @ChildId, ParticipationType = @ParticipationType, TeamNo = @TeamNo, Date = @Date,
          TimeStart = @TimeStart, TimeEnd = @TimeEnd, Location = @Location, UpdatedAt = GETDATE()
      WHERE Id = @Id
    `;
    const pool = await sql.connect();
    await pool.request()
      .input('Id', sql.Int, id)
      .input('ChildId', sql.Int, ChildId)
      .input('ParticipationType', sql.NVarChar, ParticipationType)
      .input('TeamNo', sql.NVarChar, TeamNo)
      .input('Date', sql.Date, Date)
      .input('TimeStart', sql.Time, TimeStart)
      .input('TimeEnd', sql.Time, TimeEnd)
      .input('Location', sql.NVarChar, Location)
      .query(query);

    res.status(200).json({ message: 'Participation updated successfully' });
  } catch (error) {
    console.error('Error updating participation:', error.message);
    res.status(500).json({ message: 'Error updating participation', error: error.message });
  }
};

// Delete participation (Admin only)
exports.deleteParticipation = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const { id } = req.params;

    const query = 'DELETE FROM Participation WHERE Id = @Id';
    const pool = await sql.connect();
    await pool.request().input('Id', sql.Int, id).query(query);

    res.status(200).json({ message: 'Participation deleted successfully' });
  } catch (error) {
    console.error('Error deleting participation:', error.message);
    res.status(500).json({ message: 'Error deleting participation', error: error.message });
  }
};
