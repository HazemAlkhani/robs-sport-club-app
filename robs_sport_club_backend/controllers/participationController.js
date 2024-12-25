const { sql } = require('../db');

// Helper to parse time from HH:MM to INT
const parseTimeToInt = (time) => {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 100 + minutes;
};


// Fetch all participations (Admin only)
exports.getAllParticipations = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    console.log('Fetching all participations...');
    const query = 'SELECT * FROM Participation';
    const pool = await sql.connect();
    const result = await pool.request().query(query);

    // Format TimeStart in the response
    const formattedResult = result.recordset.map((row) => ({
      ...row,
      TimeStart: parseTimeToHHMM(row.TimeStart), // Convert INT to HH:MM
    }));

    res.status(200).json({ success: true, data: formattedResult });
  } catch (error) {
    console.error('Error fetching participations:', error.message, error.stack);
    res.status(500).json({ success: false, message: 'Error fetching participations', error: error.message });
  }
};

// Fetch participation for children of a parent (Parent only)
exports.getParticipationByUser = async (req, res) => {
  try {
    const userId = req.user.id;

    console.log(`Fetching participation for User ID: ${userId}`);
    const query = `
      SELECT P.*
      FROM Participation P
      INNER JOIN Children C ON P.ChildId = C.Id
      WHERE C.UserId = @UserId
    `;
    const pool = await sql.connect();
    const result = await pool.request().input('UserId', sql.Int, userId).query(query);

    // Format TimeStart
    const formattedResult = result.recordset.map((row) => ({
      ...row,
      TimeStart: parseTimeToHHMM(row.TimeStart), // Convert INT to HH:MM
    }));

    res.status(200).json({ success: true, data: formattedResult });
  } catch (error) {
    console.error('Error fetching participation:', error.message, error.stack);
    res.status(500).json({ success: false, message: 'Error fetching participation', error: error.message });
  }
};

// Add participation (Admin only)
exports.addParticipation = async (req, res) => {
  try {
    console.log('Incoming Request:', req.body);

    const { ChildName, ParticipationType, Date, TimeStart, Duration, Location } = req.body;
    const adminId = req.user.id;

    console.log('Step 1: Validating Input...');
    if (!ChildName || !ParticipationType || !Date || !TimeStart || !Duration || !Location) {
      console.error('Missing required fields.');
      return res.status(400).json({ message: 'All fields are required.' });
    }

    // Convert TimeStart from HH:MM to INT
    console.log('Step 2: Parsing TimeStart...');
    const timeStartInt = parseTimeToInt(TimeStart);
    console.log('Parsed TimeStart (to INT):', timeStartInt);

    console.log('Step 3: Connecting to database...');
    const pool = await sql.connect();

    console.log('Step 4: Fetching Child Info...');
    const childQuery = `
      SELECT Id AS ChildId, TeamNo
      FROM Children
      WHERE ChildName = @ChildName
    `;
    const childResult = await pool.request()
      .input('ChildName', sql.VarChar, ChildName)
      .query(childQuery);

    console.log('Child Query Result:', childResult.recordset);

    if (childResult.recordset.length === 0) {
      console.error(`Child not found: ${ChildName}`);
      return res.status(404).json({ message: `Child '${ChildName}' not found.` });
    }

    const { ChildId, TeamNo } = childResult.recordset[0];
    console.log('Step 5: Child Info:', { ChildId, TeamNo });

    console.log('Step 6: Inserting Participation...');
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
      .input('TimeStart', sql.Int, timeStartInt)
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .input('CreatedBy', sql.Int, adminId)
      .query(participationQuery);

    console.log('Step 7: Participation added successfully!');
    res.status(201).json({ message: 'Participation added successfully.' });
  } catch (error) {
    console.error('Error adding participation:', error.message, error.stack);
    res.status(500).json({ message: 'Error adding participation', error: error.message });
  }
};


exports.updateParticipation = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const { id } = req.params;
    const { ChildId, ParticipationType, TeamNo, Date, TimeStart, Duration, Location } = req.body;

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
      .input('TimeStart', sql.Int, TimeStart)
      .input('Duration', sql.Int, Duration)
      .input('Location', sql.VarChar, Location)
      .query(query);

    res.status(200).json({ message: 'Participation updated successfully.' });
  } catch (error) {
    console.error('Error updating participation:', error.message, error.stack);
    res.status(500).json({ message: 'Error updating participation', error: error.message });
  }
};

exports.deleteParticipation = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const { id } = req.params;

    console.log(`Deleting Participation ID: ${id}`);
    const query = 'DELETE FROM Participation WHERE Id = @Id';
    const pool = await sql.connect();
    await pool.request().input('Id', sql.Int, id).query(query);

    console.log('Participation deleted successfully!');
    res.status(200).json({ message: 'Participation deleted successfully.' });
  } catch (error) {
    console.error('Error deleting participation:', error.message, error.stack);
    res.status(500).json({ message: 'Error deleting participation', error: error.message });
  }
};
