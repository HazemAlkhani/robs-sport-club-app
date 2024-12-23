const sql = require('../db');

class Child {
  constructor(id, childName, userId, teamNo, createdAt, updatedAt) {
    this.id = id;
    this.childName = childName;
    this.userId = userId; // Parent's user ID
    this.teamNo = teamNo;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
  }

  // Create a new child record
  static async createChild(childName, userId, teamNo) {
    try {
      const query = `
        INSERT INTO Children (ChildName, UserId, TeamNo, CreatedAt, UpdatedAt)
        OUTPUT INSERTED.*
        VALUES (@ChildName, @UserId, @TeamNo, GETDATE(), GETDATE())
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ChildName', sql.VarChar, childName)
        .input('UserId', sql.Int, userId)
        .input('TeamNo', sql.VarChar, teamNo)
        .query(query);

      return result.recordset[0]; // Return the created child
    } catch (error) {
      throw new Error(`Error creating child: ${error.message}`);
    }
  }

  // Get all children
  static async getAllChildren() {
    try {
      const query = `SELECT * FROM Children`;
      const pool = await sql.connect();
      const result = await pool.request().query(query);

      return result.recordset; // Return all children
    } catch (error) {
      throw new Error(`Error fetching children: ${error.message}`);
    }
  }

  // Get child by ID
  static async getChildById(id) {
    try {
      const query = `SELECT * FROM Children WHERE Id = @Id`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the child or null if not found
    } catch (error) {
      throw new Error(`Error fetching child by ID: ${error.message}`);
    }
  }

  // Update a child
  static async updateChild(id, childName, userId, teamNo) {
    try {
      const query = `
        UPDATE Children
        SET ChildName = @ChildName, UserId = @UserId, TeamNo = @TeamNo, UpdatedAt = GETDATE()
        WHERE Id = @Id
        OUTPUT INSERTED.*
      `;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('ChildName', sql.VarChar, childName)
        .input('UserId', sql.Int, userId)
        .input('TeamNo', sql.VarChar, teamNo)
        .query(query);

      return result.recordset[0] || null; // Return the updated child or null if not found
    } catch (error) {
      throw new Error(`Error updating child: ${error.message}`);
    }
  }

  // Delete a child
  static async deleteChild(id) {
    try {
      const query = `DELETE FROM Children WHERE Id = @Id OUTPUT DELETED.*`;
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);

      return result.recordset[0] || null; // Return the deleted child or null if not found
    } catch (error) {
      throw new Error(`Error deleting child: ${error.message}`);
    }
  }
}

module.exports = Child;
