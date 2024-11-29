class UserStatistics {
  constructor(id, childId, monthYear, totalTrainingHours = 0, totalMatchHours = 0) {
    this.id = id;
    this.childId = childId;
    this.monthYear = monthYear;
    this.totalTrainingHours = totalTrainingHours;
    this.totalMatchHours = totalMatchHours;
  }

  // Method to create a `UserStatistics` instance from JSON
  static fromJson(json) {
    return new UserStatistics(
      json.id,
      json.childId,
      new Date(json.monthYear),
      json.totalTrainingHours || 0,
      json.totalMatchHours || 0
    );
  }

  // Method to convert a `UserStatistics` instance to JSON
  toJson() {
    return {
      id: this.id,
      childId: this.childId,
      monthYear: this.monthYear.toISOString(),
      totalTrainingHours: this.totalTrainingHours,
      totalMatchHours: this.totalMatchHours,
    };
  }
}

module.exports = UserStatistics;
