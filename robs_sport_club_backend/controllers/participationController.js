const moment = require('moment');
const { sql } = require('../db');

// Helper to validate and format dates
const validateDate = (date) => {
  const parsedDate = moment(date, 'YYYY-MM-DD', true);
  if (!parsedDate.isValid()) {
    throw new Error('Invalid date format. Expected format: YYYY-MM-DD');
  }
  return parsedDate.toDate();
};

// Fetch all participations (Admin gets all, User gets their own)
exports.getAllParticipations = async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin';

    const query = isAdmin
      ? `
        SELECT P.Id, P.ChildId, C.ChildName, P.ParticipationType, C.TeamNo,
               CONVERT(VARCHAR, P.Date, 23) AS Date, P.TimeStart, P.Duration, P.Location, A.Name AS Coach
        FROM Participation P
        LEFT JOIN Children C ON P.ChildId = C.Id
        LEFT JOIN Admins A ON P.CreatedBy = A.Id
        ORDER BY P.Date DESC
      `
      : `
        SELECT P.Id, P.ChildId, C.ChildName, P.ParticipationType, C.TeamNo,
               CONVERT(VARCHAR, P.Date, 23) AS Date, P.TimeStart, P.Duration, P.Location, A.Name AS Coach
        FROM Participation P
        INNER JOIN Children C ON P.ChildId = C.Id
        LEFT JOIN Admins A ON P.CreatedBy = A.Id
        WHERE C.UserId = @UserId
        ORDER BY P.Date DESC
      `;

    const pool = await sql.connect();
    const request = pool.request();
    if (!isAdmin) request.input('UserId', sql.Int, req.user.id);

    const result = await request.query(query);

    res.status(200).json({
      success: true,
      data: result.recordset.map((row) => ({
        id: row.Id,
        childId: row.ChildId,
        childName: row.ChildName,
        participationType: row.ParticipationType,
        teamNo: row.TeamNo,
        date: row.Date,
        timeStart: row.TimeStart,
        duration: row.Duration,
        location: row.Location,
        coach: row.Coach,
      })),
    });
  } catch (error) {
    console.error('Error fetching participations:', error.message);
    res.status(500).json({ success: false, message: 'Error fetching participations' });
  }
};

// Add participation
exports.addParticipation = async (req, res) => {
  try {
    const { ChildName, ParticipationType, Date, TimeStart, Duration, Location } = req.body;
    const adminId = req.user.id;

    const formattedDate = validateDate(Date);

    const pool = await sql.connect();

    // Check if the child exists and fetch required details
    const childQuery = `
      SELECT Id AS ChildId, TeamNo
      FROM Children
      WHERE ChildName = @ChildName
    `;
    const childResult = await pool.request()
      .input('ChildName', sql.VarChar, ChildName)
      .query(childQuery);

    if (!childResult.recordset.length) {
      return res.status(404).json({
        success: false,
        message: `Child '${ChildName}' not found in the database. Please ensure the child is registered before adding participation.`,
      });
    }

    const { ChildId, TeamNo } = childResult.recordset[0];

    // Insert participation using ChildId
    const query = `
      INSERT INTO Participation (ChildId, ParticipationType, TeamNo, Date, TimeStart, Duration, Location, CreatedBy, CreatedAt, UpdatedAt)
      VALUES (@ChildId, @ParticipationType, @TeamNo, @Date, @TimeStart, @Duration, @Location, @CreatedBy, GETDATE(), GETDATE())
    `;

    await pool.request()
      .input('ChildId', sql.Int, ChildId)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .input('TeamNo', sql.VarChar, TeamNo)
      .input('Date', sql.Date, formattedDate)
      .input('TimeStart', sql.NVarChar, TimeStart)
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .input('CreatedBy', sql.Int, adminId)
      .query(query);

    res.status(201).json({
      success: true,
      message: 'Participation added successfully',
    });
  } catch (error) {
    console.error('Error adding participation:', error.message);
    res.status(500).json({ success: false, message: 'Error adding participation' });
  }
};


// Update participation
exports.updateParticipation = async (req, res) => {
  try {
    const { id } = req.params;
    const { ChildName, ParticipationType, Date, TimeStart, Duration, Location } = req.body;

    const formattedDate = validateDate(Date); // Validate and format the date

    const query = `
      UPDATE Participation
      SET ParticipationType = @ParticipationType,
          Date = @Date,
          TimeStart = @TimeStart,
          Duration = @Duration,
          Location = @Location,
          UpdatedAt = GETDATE()
      WHERE Id = @Id
    `;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .input('ParticipationType', sql.VarChar, ParticipationType)
      .input('Date', sql.Date, formattedDate)
      .input('TimeStart', sql.NVarChar, TimeStart)
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ success: false, message: `Participation with ID ${id} not found.` });
    }

    res.status(200).json({ success: true, message: `Participation with ID ${id} updated successfully.` });
  } catch (error) {
    console.error('Error updating participation:', error.message);
    res.status(500).json({ success: false, message: 'Error updating participation' });
  }
};

// Delete participation
exports.deleteParticipation = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      DELETE FROM Participation
      WHERE Id = @Id
    `;

    const pool = await sql.connect();
    const result = await pool.request()
      .input('Id', sql.Int, id)
      .query(query);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ success: false, message: `Participation with ID ${id} not found.` });
    }

    res.status(200).json({ success: true, message: `Participation with ID ${id} deleted successfully.` });
  } catch (error) {
    console.error('Error deleting participation:', error.message);
    res.status(500).json({ success: false, message: 'Error deleting participation' });
  }
};
