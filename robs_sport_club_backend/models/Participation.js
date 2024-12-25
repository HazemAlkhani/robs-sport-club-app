const sql = require('../db');

class Participation {
  constructor(id, childId, participationType, teamNo, date, location, createdBy, createdAt, updatedAt, childName, duration, timeStart) {
    this.id = id;
    this.childId = childId;
    this.participationType = participationType;
    this.teamNo = teamNo;
    this.date = date;
    this.location = location;
    this.createdBy = createdBy;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
    this.childName = childName;
    this.duration = duration;
    this.timeStart = timeStart;
  }

  // Create a new participation record
  static async createParticipation(childId, participationType, teamNo, date, location, createdBy, childName, duration, timeStart) {
    try {
      const query = `
        INSERT INTO Participation (ChildId, ParticipationType, TeamNo, Date, Location, CreatedBy, CreatedAt, UpdatedAt, ChildName, Duration, TimeStart)
        OUTPUT INSERTED.*
        VALUES (@ChildId, @ParticipationType, @TeamNo, @Date, @Location, @CreatedBy, GETDATE(), GETDATE(), @ChildName, @Duration, @TimeStart)
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ChildId', sql.Int, childId)
        .input('ParticipationType', sql.NVarChar, participationType)
        .input('TeamNo', sql.NVarChar, teamNo)
        .input('Date', sql.Date, date)
        .input('Location', sql.NVarChar, location)
        .input('CreatedBy', sql.Int, createdBy)
        .input('ChildName', sql.NVarChar, childName)
        .input('Duration', sql.Int, duration)
        .input('TimeStart', sql.NVarChar, timeStart)
        .query(query);

      return result.recordset[0]; // Return the created participation record
    } catch (error) {
      console.error('Error creating participation:', error.message);
      throw new Error('Failed to create participation');
    }
  }

  // Get all participation records
  static async getAllParticipations() {
    try {
      const query = `SELECT * FROM Participation`;
      const pool = await sql.connect();
      const result = await pool.request().query(query);

      return result.recordset; // Return all participation records
    } catch (error) {
      console.error('Error fetching participations:', error.message);
      throw new Error('Failed to fetch participations');
    }
  }

  // Get participation by ID
  static async getParticipationById(id) {
    try {
      const query = `SELECT * FROM Participation WHERE Id = @Id`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the participation record or null if not found
    } catch (error) {
      console.error('Error fetching participation by ID:', error.message);
      throw new Error('Failed to fetch participation by ID');
    }
  }

  // Update a participation record
  static async updateParticipation(id, childId, participationType, teamNo, date, location, childName, duration, timeStart) {
    try {
      const query = `
        UPDATE Participation
        SET ChildId = @ChildId, ParticipationType = @ParticipationType, TeamNo = @TeamNo,
            Date = @Date, Location = @Location, ChildName = @ChildName, Duration = @Duration,
            TimeStart = @TimeStart, UpdatedAt = GETDATE()
        WHERE Id = @Id
        OUTPUT INSERTED.*
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('ChildId', sql.Int, childId)
        .input('ParticipationType', sql.NVarChar, participationType)
        .input('TeamNo', sql.NVarChar, teamNo)
        .input('Date', sql.Date, date)
        .input('Location', sql.NVarChar, location)
        .input('ChildName', sql.NVarChar, childName)
        .input('Duration', sql.Int, duration)
        .input('TimeStart', sql.Int, timeStart)
        .query(query);

      return result.recordset[0] || null; // Return the updated participation record or null if not found
    } catch (error) {
      console.error('Error updating participation:', error.message);
      throw new Error('Failed to update participation');
    }
  }

  // Delete a participation record
  static async deleteParticipation(id) {
    try {
      const query = `DELETE FROM Participation WHERE Id = @Id OUTPUT DELETED.*`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the deleted participation record or null if not found
    } catch (error) {
      console.error('Error deleting participation:', error.message);
      throw new Error('Failed to delete participation');
    }
  }
}

module.exports = Participation;
