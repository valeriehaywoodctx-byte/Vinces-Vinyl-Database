/* MSC 5304: Database Systems
   Vince's Vinyl Physical Implementation
   Developed by: Valerie Ann Haywood
*/

-- 1. Create Album Table (Catalog Data)
CREATE TABLE Album (
    AlbumID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Artist VARCHAR(255) NOT NULL,
    PressingRegion VARCHAR(50) NOT NULL,
    CONSTRAINT UC_Album UNIQUE (Title, Artist, PressingRegion)
);

-- 2. Create Staff Table
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL CHECK (Role IN ('Owner', 'Appraiser', 'Sales'))
);

-- 3. Create Customer Table
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(255) UNIQUE,
    StoreCreditBalance DECIMAL(10, 2) DEFAULT 0.00 CHECK (StoreCreditBalance >= 0)
);

-- 4. Create Inventory Item Table (Physical Copies)
CREATE TABLE InventoryItem (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    AlbumID INT NOT NULL,
    AcquisitionCost DECIMAL(10, 2) NOT NULL CHECK (AcquisitionCost >= 0),
    Status VARCHAR(50) DEFAULT 'Available' NOT NULL,
    CONSTRAINT FK_Inventory_Album FOREIGN KEY (AlbumID) REFERENCES Album(AlbumID)
);

-- 5. Create Appraisal Table (Valuation History)
CREATE TABLE Appraisal (
    AppraisalID INT IDENTITY(1,1) PRIMARY KEY,
    ItemID INT NOT NULL,
    StaffID INT NOT NULL,
    ConditionGrade VARCHAR(20) NOT NULL, -- e.g., Mint, Near Mint, Very Good
    AppraisedValue DECIMAL(10, 2) NOT NULL CHECK (AppraisedValue >= 0),
    AuditDate DATETIME DEFAULT GETDATE() NOT NULL,
    CONSTRAINT FK_Appraisal_Item FOREIGN KEY (ItemID) REFERENCES InventoryItem(ItemID),
    CONSTRAINT FK_Appraisal_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- 6. Create Sale Receipt Table (Transaction Headers)
CREATE TABLE SaleReceipt (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    StaffID INT NOT NULL,
    SaleDate DATETIME DEFAULT GETDATE() NOT NULL,
    Tax DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Sale_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Sale_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- 7. Create Line Item Table (The Bridge Entity)
CREATE TABLE LineItem (
    LineItemID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NOT NULL,
    ItemID INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    CONSTRAINT FK_Line_Sale FOREIGN KEY (SaleID) REFERENCES SaleReceipt(SaleID),
    CONSTRAINT FK_Line_Item FOREIGN KEY (ItemID) REFERENCES InventoryItem(ItemID),
    CONSTRAINT UC_LineItem_Unique_Unit UNIQUE (ItemID) -- Ensures a physical copy is only sold once
);