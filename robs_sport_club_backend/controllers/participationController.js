const { sql } = require('../db');

// Create a new participation record
exports.createParticipation = async (req, res) => {
  const { childId, participationType, teamNo, date, timeStart, timeEnd, location } = req.body;
  const createdBy = req.user.id; // Assuming the JWT payload includes the user ID

  try {
    // Calculate hours based on the provided time values
    const hours = (new Date(`1970-01-01T${timeEnd}`) - new Date(`1970-01-01T${timeStart}`)) / 3600000;

    // Parameterized query to prevent SQL injection
    await sql.query(`
      INSERT INTO Participation (ChildId, ParticipationType, TeamNo, Date, TimeStart, TimeEnd, Location, CreatedBy, Hours)
      VALUES (@childId, @participationType, @teamNo, @date, @timeStart, @timeEnd, @location, @createdBy, @hours)
    `, {
      childId,
      participationType,
      teamNo,
      date,
      timeStart,
      timeEnd,
      location,
      createdBy,
      hours,
    });

    res.status(201).json({ message: 'Participation record created successfully' });
  } catch (error) {
    console.error('Error creating participation record:', error);
    res.status(500).json({ message: 'Error creating participation record', error: error.message });
  }
};

// Get participation records by child
exports.getParticipationByChild = async (req, res) => {
  const childId = req.params.childId;

  try {
    // Parameterized query for security
    const result = await sql.query(`
      SELECT * FROM Participation WHERE ChildId = @childId
    `, {
      childId,
    });

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching participation records:', error);
    res.status(500).json({ message: 'Error fetching participation records', error: error.message });
  }
};
