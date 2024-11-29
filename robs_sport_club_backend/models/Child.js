class Child {
  constructor(id, childName, userId, teamNo, createdAt, updatedAt) {
    this.id = id;
    this.childName = childName;
    this.userId = userId; // Parent's user ID
    this.teamNo = teamNo;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || new Date();
  }

  // Method to create a `Child` instance from JSON
  static fromJson(json) {
    return new Child(
      json.id,
      json.childName,
      json.userId,
      json.teamNo,
      new Date(json.createdAt),
      new Date(json.updatedAt)
    );
  }

  // Method to convert a `Child` instance to JSON
  toJson() {
    return {
      id: this.id,
      childName: this.childName,
      userId: this.userId,
      teamNo: this.teamNo,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}

module.exports = Child;
