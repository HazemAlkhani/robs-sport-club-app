const sql = require('../db');

class Participation {
  constructor(id, childId, participationType, teamNo, date, timeStart, timeEnd, location, createdAt, updatedAt) {
    this.id = id;
    this.childId = childId;
    this.participationType = participationType;
    this.teamNo = teamNo;
    this.date = date;
    this.timeStart = timeStart;
    this.timeEnd = timeEnd;
    this.location = location;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
  }

  // Create a new participation record
  static async createParticipation(childId, participationType, teamNo, date, timeStart, timeEnd, location) {
    try {
      const query = `
        INSERT INTO Participation (ChildId, ParticipationType, TeamNo, Date, TimeStart, TimeEnd, Location, CreatedAt, UpdatedAt)
        OUTPUT INSERTED.*
        VALUES (@ChildId, @ParticipationType, @TeamNo, @Date, @TimeStart, @TimeEnd, @Location, GETDATE(), GETDATE())
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ChildId', sql.Int, childId)
        .input('ParticipationType', sql.VarChar, participationType)
        .input('TeamNo', sql.VarChar, teamNo)
        .input('Date', sql.Date, date)
        .input('TimeStart', sql.VarChar, timeStart)
        .input('TimeEnd', sql.VarChar, timeEnd)
        .input('Location', sql.VarChar, location)
        .query(query);

      return result.recordset[0]; // Return the created participation record
    } catch (error) {
      throw new Error(`Error creating participation: ${error.message}`);
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
      throw new Error(`Error fetching participations: ${error.message}`);
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
      throw new Error(`Error fetching participation by ID: ${error.message}`);
    }
  }

  // Update a participation record
  static async updateParticipation(id, childId, participationType, teamNo, date, timeStart, timeEnd, location) {
    try {
      const query = `
        UPDATE Participation
        SET ChildId = @ChildId, ParticipationType = @ParticipationType, TeamNo = @TeamNo,
            Date = @Date, TimeStart = @TimeStart, TimeEnd = @TimeEnd, Location = @Location, UpdatedAt = GETDATE()
        WHERE Id = @Id
        OUTPUT INSERTED.*
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('ChildId', sql.Int, childId)
        .input('ParticipationType', sql.VarChar, participationType)
        .input('TeamNo', sql.VarChar, teamNo)
        .input('Date', sql.Date, date)
        .input('TimeStart', sql.VarChar, timeStart)
        .input('TimeEnd', sql.VarChar, timeEnd)
        .input('Location', sql.VarChar, location)
        .query(query);

      return result.recordset[0] || null; // Return the updated participation record or null if not found
    } catch (error) {
      throw new Error(`Error updating participation: ${error.message}`);
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
      throw new Error(`Error deleting participation: ${error.message}`);
    }
  }
}

module.exports = Participation;
