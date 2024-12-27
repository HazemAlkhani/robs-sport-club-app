const { sql } = require('../db');

// Helper to parse time from HH:MM to INT and vice versa
const parseTimeToInt = (time) => {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 100 + minutes;
};

const parseTimeToHHMM = (timeInt) => {
  const hours = Math.floor(timeInt / 100).toString().padStart(2, '0');
  const minutes = (timeInt % 100).toString().padStart(2, '0');
  return `${hours}:${minutes}`;
};

// Fetch distinct teams
exports.getTeams = async (req) => {
  try {
    const pool = await sql.connect();
    const query = `SELECT DISTINCT TeamNo FROM Children`;
    const result = await pool.request().query(query);
    return result.recordset; // Return data
  } catch (error) {
    console.error('Error fetching teams:', error.message);
    throw new Error('Error fetching teams'); // Throw error for route to handle
  }
};


// Fetch all participations based on user role
exports.getAllParticipations = async (req, res) => {
  try {
    const pool = await sql.connect();
    const isAdmin = req.user.role === 'admin';
    let query;

    if (isAdmin) {
      // Admin: Fetch all participations
      query = `
        SELECT P.*, C.ChildName, C.TeamNo
        FROM Participation P
        LEFT JOIN Children C ON P.ChildId = C.Id
        ORDER BY P.Date DESC
      `;
    } else {
      // User: Fetch participations for their children
      query = `
        SELECT P.*, C.ChildName, C.TeamNo
        FROM Participation P
        INNER JOIN Children C ON P.ChildId = C.Id
        WHERE C.UserId = @UserId
        ORDER BY P.Date DESC
      `;
    }

    const request = pool.request();
    if (!isAdmin) {
      request.input('UserId', sql.Int, req.user.id); // Add UserId for non-admin users
    }

    const result = await request.query(query);
    const formattedResult = result.recordset.map((row) => ({
      ...row,
      TimeStart: row.TimeStart,
    }));

    res.status(200).json({ success: true, data: formattedResult });
  } catch (error) {
    console.error('Error fetching participations:', error.message);
    res.status(500).json({ success: false, message: 'Error fetching participations', error: error.message });
  }
};

// Add participation (Admin only)
exports.addParticipation = async (req, res) => {
  try {
    const { ChildName, ParticipationType, Date, TimeStart, Duration, Location } = req.body;
    const adminId = req.user.id;

    if (!ChildName || !ParticipationType || !Date || !TimeStart || !Duration || !Location) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

    const pool = await sql.connect();
    const childQuery = `
      SELECT Id AS ChildId, TeamNo
      FROM Children
      WHERE ChildName = @ChildName
    `;
    const childResult = await pool.request()
      .input('ChildName', sql.VarChar, ChildName)
      .query(childQuery);

    if (childResult.recordset.length === 0) {
      return res.status(404).json({ message: `Child '${ChildName}' not found.` });
    }

    const { ChildId, TeamNo } = childResult.recordset[0];

    const participationQuery = `
      INSERT INTO Participation (ChildId, ChildName, ParticipationType, TeamNo, Date, TimeStart, Duration, Location, CreatedBy, CreatedAt, UpdatedAt)
      VALUES (@ChildId, @ChildName, @ParticipationType, @TeamNo, @Date, @TimeStart, @Duration, @Location, @CreatedBy, GETDATE(), GETDATE())
    `;
    await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('ChildName', sql.VarChar, ChildName)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .input('TeamNo', sql.VarChar, TeamNo)
      .input('Date', sql.Date, Date)
      .input('TimeStart', sql.NVarChar, TimeStart) // Ensure no conversion here
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .input('CreatedBy', sql.Int, adminId)
      .query(participationQuery);

    res.status(201).json({ message: 'Participation added successfully.' });
  } catch (error) {
    console.error('Error adding participation:', error.message);
    res.status(500).json({ message: 'Error adding participation', error: error.message });
  }
};



// Update participation
exports.updateParticipation = async (req, res) => {
  try {
    const { id } = req.params;
    const { ChildId, ParticipationType, TeamNo, Date, TimeStart, Duration, Location } = req.body;

    if (!id || !ChildId || !ParticipationType || !TeamNo || !Date || !TimeStart || !Duration || !Location) {
      return res.status(400).json({ message: 'All fields are required for update.' });
    }

    const timeStartInt = parseTimeToInt(TimeStart);

    const query = `
      UPDATE Participation
      SET ChildId = @ChildId, ParticipationType = @ParticipationType, TeamNo = @TeamNo, Date = @Date,
          TimeStart = @TimeStart, Duration = @Duration, Location = @Location, UpdatedAt = GETDATE()
      WHERE Id = @Id
    `;
    const pool = await sql.connect();
    await pool.request()
      .input('Id', sql.Int, id)
      .input('ChildId', sql.Int, ChildId)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .input('TeamNo', sql.VarChar, TeamNo)
      .input('Date', sql.Date, Date)
      .input('TimeStart', sql.NVarChar, TimeStart)
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .query(query);

    res.status(200).json({ message: 'Participation updated successfully.' });
  } catch (error) {
    console.error('Error updating participation:', error.message);
    res.status(500).json({ message: 'Error updating participation', error: error.message });
  }
};

// Delete participation
exports.deleteParticipation = async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied. Only admins can delete participation.' });
    }

    const query = 'DELETE FROM Participation WHERE Id = @Id';
    const pool = await sql.connect();
    await pool.request().input('Id', sql.Int, id).query(query);

    res.status(200).json({ message: 'Participation deleted successfully.' });
  } catch (error) {
    console.error('Error deleting participation:', error.message);
    res.status(500).json({ message: 'Error deleting participation', error: error.message });
  }
};
