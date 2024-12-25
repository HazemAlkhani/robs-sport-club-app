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
    const query = `
      INSERT INTO Children (ChildName, UserId, TeamNo, CreatedAt, UpdatedAt)
      OUTPUT INSERTED.*
      VALUES (@ChildName, @UserId, @TeamNo, GETDATE(), GETDATE())
    `;
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('ChildName', sql.VarChar, childName)
        .input('UserId', sql.Int, userId)
        .input('TeamNo', sql.VarChar, teamNo)
        .query(query);
      return result.recordset[0]; // Return the created child
    } catch (error) {
      console.error('Error creating child:', error.message);
      throw new Error('Failed to create child');
    }
  }

  // Get all children
  static async getAllChildren() {
    const query = `SELECT * FROM Children`;
    try {
      const pool = await sql.connect();
      const result = await pool.request().query(query);
      return result.recordset; // Return all children
    } catch (error) {
      console.error('Error fetching children:', error.message);
      throw new Error('Failed to fetch children');
    }
  }

  // Get child by ID
  static async getChildById(id) {
    const query = `SELECT * FROM Children WHERE Id = @Id`;
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);
      return result.recordset[0] || null; // Return the child or null if not found
    } catch (error) {
      console.error('Error fetching child by ID:', error.message);
      throw new Error('Failed to fetch child by ID');
    }
  }

  // Update a child
  static async updateChild(id, childName, userId, teamNo) {
    const query = `
      UPDATE Children
      SET ChildName = @ChildName, UserId = @UserId, TeamNo = @TeamNo, UpdatedAt = GETDATE()
      WHERE Id = @Id
      OUTPUT INSERTED.*
    `;
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .input('ChildName', sql.VarChar, childName)
        .input('UserId', sql.Int, userId)
        .input('TeamNo', sql.VarChar, teamNo)
        .query(query);
      return result.recordset[0] || null; // Return the updated child or null if not found
    } catch (error) {
      console.error('Error updating child:', error.message);
      throw new Error('Failed to update child');
    }
  }

  // Delete a child
  static async deleteChild(id) {
    const query = `DELETE FROM Children WHERE Id = @Id OUTPUT DELETED.*`;
    try {
      const pool = await sql.connect();
      const result = await pool.request()
        .input('Id', sql.Int, id)
        .query(query);
      return result.recordset[0] || null; // Return the deleted child or null if not found
    } catch (error) {
      console.error('Error deleting child:', error.message);
      throw new Error('Failed to delete child');
    }
  }
}

module.exports = Child;
