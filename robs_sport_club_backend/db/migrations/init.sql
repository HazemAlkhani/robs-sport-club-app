-- Drop tables if they already exist to ensure clean initialization
DROP TABLE IF EXISTS Participation;
DROP TABLE IF EXISTS Children;
DROP TABLE IF EXISTS Users;

-- Create Users table
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ParentName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Mobile NVARCHAR(15),
    SportType NVARCHAR(50),
    Username NVARCHAR(50) UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) DEFAULT 'user', -- Role can be 'admin' or 'user'
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create Children table
CREATE TABLE Children (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChildName NVARCHAR(100) NOT NULL,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id) ON DELETE CASCADE,
    TeamNo NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create Participation table
CREATE TABLE Participation (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChildId INT NOT NULL FOREIGN KEY REFERENCES Children(Id) ON DELETE CASCADE,
    ParticipationType NVARCHAR(50) NOT NULL,
    TeamNo NVARCHAR(50),
    Date DATE NOT NULL,
    TimeStart NVARCHAR(10) NOT NULL,
    TimeEnd NVARCHAR(10) NOT NULL,
    Location NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Insert default admin user
INSERT INTO Users (ParentName, Email, Mobile, SportType, Username, Password, Role, CreatedAt, UpdatedAt)
VALUES
('Admin', 'admin@example.com', '1234567890', 'All Sports', 'admin', 'hashed_password_here', 'admin', GETDATE(), GETDATE());

-- End of file
