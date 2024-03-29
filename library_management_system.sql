-- Create Tables
CREATE TABLE IF NOT EXISTS Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255),
    Author VARCHAR(255),
    Genre VARCHAR(100),
    PublicationYear INT,
    Language VARCHAR(50),
    IsCheckedOut BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS Borrowers (
    BorrowerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    ContactInfo VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    BorrowerID INT,
    CheckoutDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (BorrowerID) REFERENCES Borrowers(BorrowerID)
);

-- Populate Books Table
INSERT INTO Books (Title, Author, Genre, PublicationYear, Language) VALUES 
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 'English'),
('1984', 'George Orwell', 'Dystopian', 1949, 'English'),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 'English'),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 'English'),
('Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 'English'),
('El amor en los tiempos del cólera', 'Gabriel García Márquez', 'Romance', 1985, 'Spanish'),
('Le Petit Prince', 'Antoine de Saint-Exupéry', 'Fairy tale', 1943, 'French'),
('Die Verwandlung', 'Franz Kafka', 'Novella', 1915, 'German'),
('Norwegian Wood', 'Haruki Murakami', 'Novel', 1987, 'Japanese');

-- Populate Borrowers Table
INSERT INTO Borrowers (Name, ContactInfo) VALUES 
('John Doe', 'john.doe@example.com'),
('Jane Doe', 'jane.doe@example.com'),
('Bob Smith', 'bob.smith@example.com'),
('Alice Johnson', 'alice.johnson@example.com'),
('Charlie Brown', 'charlie.brown@example.com');

-- Searching for Books by Title, Author, or Genre
SELECT * FROM Books WHERE Title LIKE '%Pride%';
SELECT * FROM Books WHERE Author LIKE '%Harper Lee%';
SELECT * FROM Books WHERE Genre LIKE '%Fiction%';

-- Listing All Books That Are Currently Checked Out
SELECT * FROM Books WHERE IsCheckedOut = TRUE;

-- Finding Overdue Books Based on the Current Date and DueDate
SELECT L.LoanID, L.BookID, B.Title, B.Author, L.DueDate 
FROM Loans L
JOIN Books B ON L.BookID = B.BookID 
WHERE L.ReturnDate IS NULL AND L.DueDate < CURDATE();

-- Check-Out Process (Note: Ensure book is not already checked out before running this)
INSERT INTO Loans (BookID, BorrowerID, CheckoutDate, DueDate) 
VALUES (3, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
UPDATE Books SET IsCheckedOut = TRUE WHERE BookID = 3;

-- Return Process
UPDATE Loans SET ReturnDate = CURDATE() WHERE BookID = 3 AND ReturnDate IS NULL;
UPDATE Books SET IsCheckedOut = FALSE WHERE BookID = 3;
-- Create Fines Table
CREATE TABLE IF NOT EXISTS Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT,
    Amount DECIMAL(5, 2),
    Paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);
--Fine calculations
INSERT INTO Fines (LoanID, Amount, Paid)
SELECT LoanID, DATEDIFF(CURDATE(), DueDate) * 0.50, FALSE
FROM Loans
WHERE BookID = ? AND ReturnDate IS NULL AND CURDATE() > DueDate;

