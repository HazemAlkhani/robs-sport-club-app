const { sql } = require('../db');

// Create a new participation record
exports.createParticipation = async (req, res) => {
  const { childId, participationType, teamNo, date, timeStart, timeEnd, location } = req.body;
  const createdBy = req.user.id; // Assuming the JWT payload includes the user ID

  try {
    const hours = (new Date(`1970-01-01T${timeEnd}`).getTime() - new Date(`1970-01-01T${timeStart}`).getTime()) / 3600000; // Convert time difference to hours

    // Insert into the database
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
      hours
    });

    res.status(201).json({ message: 'Participation created successfully' });
  } catch (error) {
    console.error('Error creating participation record:', error);
    res.status(500).json({ message: 'Error creating participation record', error: error.message });
  }
};

// Get all participation records
exports.getAllParticipations = async (req, res) => {
  try {
    const result = await sql.query('SELECT * FROM Participation');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error fetching participation records:', error);
    res.status(500).json({ message: 'Error fetching participation records', error: error.message });
  }
};

// Get participation by ID
exports.getParticipationById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await sql.query('SELECT * FROM Participation WHERE Id = @id', { id });
    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Participation not found' });
    }
    res.status(200).json(result.recordset[0]);
  } catch (error) {
    console.error('Error fetching participation by ID:', error);
    res.status(500).json({ message: 'Error fetching participation', error: error.message });
  }
};

// Update participation by ID
exports.updateParticipation = async (req, res) => {
  const { id } = req.params;
  const { childId, participationType, teamNo, date, timeStart, timeEnd, location } = req.body;

  try {
    const hours = (new Date(`1970-01-01T${timeEnd}`).getTime() - new Date(`1970-01-01T${timeStart}`).getTime()) / 3600000; // Convert time difference to hours

    const result = await sql.query(`
      UPDATE Participation
      SET ChildId = @childId, ParticipationType = @participationType, TeamNo = @teamNo, Date = @date, TimeStart = @timeStart,
          TimeEnd = @timeEnd, Location = @location, Hours = @hours
      WHERE Id = @id
    `, {
      id,
      childId,
      participationType,
      teamNo,
      date,
      timeStart,
      timeEnd,
      location,
      hours
    });

    if (result.rowsAffected === 0) {
      return res.status(404).json({ message: 'Participation not found' });
    }

    res.status(200).json({ message: 'Participation updated successfully' });
  } catch (error) {
    console.error('Error updating participation:', error);
    res.status(500).json({ message: 'Error updating participation', error: error.message });
  }
};

// Delete participation by ID
exports.deleteParticipation = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await sql.query('DELETE FROM Participation WHERE Id = @id', { id });
    if (result.rowsAffected === 0) {
      return res.status(404).json({ message: 'Participation not found' });
    }
    res.status(200).json({ message: 'Participation deleted successfully' });
  } catch (error) {
    console.error('Error deleting participation:', error);
    res.status(500).json({ message: 'Error deleting participation', error: error.message });
  }
};
