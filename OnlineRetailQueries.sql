-- Create the Customers table
CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products table
CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories table
CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

-- Create the Orders table
CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

-- Insert sample data into Categories table
INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150),
('Keyboard', 1, 39.99, 0);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Geovani', 'D', 'geoD@example.com', '562-829-4628', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA');


-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);

SELECT * FROM Categories;
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

--Query 1: Retrieve all orders for a specific customer

SELECT o.OrderId, o.OrderDate, oi.ProductID, p.ProductName, oi.Quantity, oi.Price, o.TotalAmount 
FROM Orders o
JOIN OrderItems oi ON o.OrderId = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerId = 1;

--Query 2: Find the total sales for each product

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity * oi.Price) AS total_sales
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY total_sales DESC;

--Query 3: Calculate the average order value
SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders

--Query 4: List the top 5 customers by total spending

SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpending DESC;

--Query 5: Retrieve the most popular product category

SELECT CategoryName, TotalQuantitySold
FROM (
	SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity) AS TotalQuantitySold, RANK() OVER(ORDER BY SUM(oi.Quantity) DESC) AS rnk
	FROM OrderItems oi
	JOIN Products p ON oi.ProductID = p.ProductID
	JOIN Categories c ON p.CategoryID = c.CategoryID
	GROUP BY c.CategoryID, c.CategoryName
) A
WHERE rnk = 1;

--Query 6: List all products that are out of stock, i.e. stock = 0

SELECT * FROM Products WHERE Stock = 0

SELECT p.ProductID, p.ProductName, c.CategoryName, p.Stock   -- with category name
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.Stock = 0;

--Query 7: Find customers who placed orders in the last 30 days

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, o.OrderDate
FROM Orders o
JOIN Customers c ON o.CustomerId = c.CustomerID
WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE());

--Query 8: Calculate the total number of orders placed each month

SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, COUNT(OrderID) AS TotalOrders
FROM Orders 
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

--Query 9: Retrieve the details of the most recent order

SELECT TOP 1 o.OrderId, o.OrderDate, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerId = c.CustomerID
ORDER BY o.OrderDate DESC;

--Query 10: Find the average price of products in each category

SELECT c.CategoryID, c.CategoryName, AVG(p.Price) AS AveragePrice
FROM Products p
JOIN Categories c ON p.ProductID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName;

--Query 11: List customers who have never placed an order

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerId
WHERE o.OrderId IS NULL;

--Query 12: Retrieve the total quantity sold for each product

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalQuantitySold
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName;

--Query 13: Calculate the total revenue generated from each category

SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY 3 DESC;

--Query 14: Find the highest-priced product in each category

SELECT CategoryName, ProductName, Price
FROM (
SELECT c.CategoryID, c.CategoryName, p.ProductName, p.Price, ROW_NUMBER() OVER(PARTITION BY c.CategoryID ORDER BY p.Price DESC) AS rn
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
) l
WHERE rn = 1;

--Query 15: Retrieve orders with a total amount greater than a specific value (e.g., $500)

SELECT o.OrderId, c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerId = c.CustomerID
WHERE o.TotalAmount > 500
ORDER BY 5 DESC;

--Query 16: List products along with the number of orders they appear in

SELECT p.ProductID, p.ProductName, COUNT(oi.OrderID) AS OrderCount
FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName;

--Query 17: Find the top 3 most frequently ordered products

SELECT TOP 3 p.ProductID, p.ProductName, COUNT(oi.OrderID) AS OrderCount
FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY 3 DESC;

--Query 18: Calculate the total number of customers from each country

SELECT Country, COUNT(CustomerID) AS TotalCustomers
FROM Customers
GROUP BY Country;

--Query 19: Retrieve the list of customers along with their total spending

SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, c.FirstName, c.LastName;

--Query 20: List orders with less than a specified number of items (e.g., 5 items)

SELECT o.OrderId, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerId
JOIN OrderItems oi ON o.OrderId = oi.OrderID
GROUP BY o.OrderId, c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(oi.OrderItemID) < 5;


-- LOG MAINTENANCE

-- Create a Log Table
CREATE TABLE ChangeLog (
	LogID INT PRIMARY KEY IDENTITY(1,1),
	TableName NVARCHAR(50),
	Operation NVARCHAR(10),
	RecordID INT,
	ChangeDate DATETIME DEFAULT GETDATE(),
	ChangedBy NVARCHAR(100)
);
GO

-- A. Triggers for Products Table
-- Trigger for INSERT on Products table

CREATE OR ALTER TRIGGER trg_Insert_Product
ON Products
AFTER INSERT
AS
BEGIN
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	PRINT 'INSERT operation logged for Products table';
END;
GO

INSERT INTO Products (ProductName, CategoryID, Price, Stock)
VALUES
('Wireless Mouse', 1, 499, 20);

INSERT INTO Products (ProductName, CategoryID, Price, Stock)
VALUES
('Sweatshirt', 2, 899.99, 50);


SELECT * FROM Products;
SELECT * FROM ChangeLog;
GO
-- Trigger for UPDATE on Products table

CREATE OR ALTER TRIGGER trg_Update_Product
ON Products
AFTER UPDATE
AS
BEGIN
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	PRINT 'UPDATE operation logged for Products table';
END;
GO

UPDATE Products SET Price = Price - 300 
WHERE ProductID = 2;
GO

-- Trigger for DELETE on Products table

CREATE OR ALTER TRIGGER trg_DELETE_Product
ON Products
AFTER DELETE
AS
BEGIN
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER
	FROM deleted;

	PRINT 'DELETE operation logged for Products table';
END;
GO

SET NOCOUNT ON;

DELETE FROM Products WHERE ProductID = 9
GO

-- B. Triggers for Customers Table
-- Trigger for INSERT on Customers table

CREATE OR ALTER TRIGGER trg_Insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN
	--SET NOCOUNT ON;

	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	PRINT 'INSERT operation logged for Customers table.';
END;
GO

-- Trigger for UPDATE on Customers table

CREATE OR ALTER TRIGGER trg_Update_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
	--SET NOCOUNT ON;

	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	PRINT 'UPDATE operation logged for Customers table.';
END;
GO

-- Trigger for DELETE on Customers table

CREATE OR ALTER TRIGGER trg_Delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN
	--SET NOCOUNT ON;

	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER
	FROM deleted;

	PRINT 'DELETE operation logged for Customers table.';
END;
GO

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 
'Delhi', '5456665', 'INDIA');
GO
	

UPDATE Customers SET State = 'Florida' WHERE State = 'IL';
GO
	
DELETE FROM Customers WHERE CustomerID = 5;
GO

SELECT * FROM Customers;
SELECT * FROM ChangeLog;
GO

-- INDEXES

-- A. Indexes on Categories Table
--	  1. Clustered Index on CategoryID: Usually created with the primary key.
CREATE CLUSTERED INDEX IDX_Category_CategoryID
ON Categories(CategoryID);
GO

/*
B. Indexes on Products Table
	1. Clustered Index on ProductID: This is usually created automatically when 
	   the primary key is defined.
	2. Non-Clustered Index on CategoryID: To speed up queries filtering by CategoryID.
	3. Non-Clustered Index on Price: To speed up queries filtering or sorting by Price.
*/
-- Drop foreign key reference from OrderItems table	- ProductID
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Produ__4316F928;

CREATE CLUSTERED INDEX IDX_Products_ProductID
ON Products(ProductID);
GO

CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID);
GO

CREATE NONCLUSTERED INDEX IDX_Products_Price
ON Products(Price);
GO

-- Recreate foreign key reference from OrderItems table	
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
GO

/*
C. Indexes on Orders Table
	1. Clustered Index on OrderID: Usually created with the primary key.
	2. Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
	3. Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
*/
-- Drop foreign key reference from OrderItems table	- OrderID
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Order__440B1D61;

CREATE CLUSTERED INDEX IDX_Orders_OrderID
ON Orders(OrderID);
GO

CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
ON Orders(CustomerID);
GO

CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
ON Orders(OrderDate);
GO

-- Recreate foreign key reference from OrderItems table	
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);
GO

/*
D. Indexes on OrderItems Table
	1. Clustered Index on OrderItemID: Usually created with the primary key.
	2. Non-Clustered Index on OrderID: To speed up queries filtering by OrderID.
	3. Non-Clustered Index on ProductID: To speed up queries filtering by ProductID.
*/

CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO

CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO


/*
E. Indexes on Customers Table
	1. Clustered Index on CustomerID: Usually created with the primary key.
	2. Non-Clustered Index on Email: To speed up queries filtering by Email.
	3. Non-Clustered Index on Country: To speed up queries filtering by Country.
*/

-- Drop foreign key reference from Orders table	- CustomerID
ALTER TABLE Orders DROP CONSTRAINT FK__Orders__Customer__403A8C7D;

CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

CREATE NONCLUSTERED INDEX IDX_Customers_Email
ON Customers(Email);
GO

CREATE NONCLUSTERED INDEX IDX_Customers_Country
ON Customers(Country);
GO

-- Recreate foreign key reference from Orders table	
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO


-- VIEWS

-- View for Product Details: A view combining product details with category names.

CREATE VIEW vw_ProductDetails AS
SELECT p.ProductID, p.ProductName, p.Price, p.Stock, c.CategoryName
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
GO

-- Display product details with category names using view
SELECT * FROM vw_ProductDetails;
GO

-- View for Customer Orders : A view to get a summary of orders placed by each customer.

CREATE VIEW vw_CustomerOrders AS 
SELECT c.CustomerID,c.FirstName, c.LastName, COUNT(o.OrderId) AS TotalOrders, SUM(oi.Quantity * p.Price) AS TotalAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerId = c.CustomerID
INNER JOIN OrderItems oi ON o.OrderId = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY c.CustomerID,c.FirstName, c.LastName;
GO

-- View for Recent Orders: A view to display orders placed in the last 30 days.

CREATE VIEW vw_RecentOrders AS 
SELECT o.OrderId, o.OrderDate, c.CustomerID, c.FirstName, c.LastName, SUM(oi.Quantity * oi.Price) AS OrderAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerId = c.CustomerID
INNER JOIN OrderItems oi ON o.OrderId = oi.OrderID
GROUP BY o.OrderId, o.OrderDate, c.CustomerID, c.FirstName, c.LastName;
GO


--Query 31: Retrieve All Products with Category Names
--Using the vw_ProductDetails view to get a list of all products along with their category names.

SELECT ProductName, CategoryName
FROM vw_ProductDetails;
GO

--Query 32: Retrieve Products within a Specific Price Range
--Using the vw_ProductDetails view to find products priced between $10 and $500.

SELECT ProductName,Price
FROM vw_ProductDetails
WHERE Price BETWEEN 10 AND 500;
GO

--Query 33: Count the Number of Products in Each Category
--Using the vw_ProductDetails view to count the number of products in each category.

SELECT CategoryName, COUNT(ProductID) AS NumberOfProducts
FROM vw_ProductDetails
GROUP BY CategoryName;
GO

--Query 34: Retrieve Customers with More Than 1 Orders
--Using the vw_CustomerOrders view to find customers who have placed more than 1 orders.

SELECT *
FROM vw_CustomerOrders
WHERE TotalOrders > 1;
GO

--Query 35: Retrieve the Total Amount Spent by Each Customer
--Using the vw_CustomerOrders view to get the total amount spent by each customer.

SELECT CustomerID, FirstName, LastName, TotalAmount
FROM vw_CustomerOrders;
GO

--Query 36: Retrieve Recent Orders Above a Certain Amount
--Using the vw_RecentOrders view to find recent orders where the total amount is greater than $500.

SELECT *
FROM vw_RecentOrders
WHERE OrderAmount > 500;
GO

--Query 37: Retrieve the Latest Order for Each Customer
--Using the vw_RecentOrders view to find the latest order placed by each customer.

SELECT ro.OrderID, ro.OrderDate, ro.CustomerID, ro.FirstName, ro.LastName, ro.OrderAmount
FROM vw_RecentOrders ro
INNER JOIN (SELECT CustomerID, MAX(OrderDate) AS LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID) a 
ON ro.CustomerID = a.CustomerID AND ro.OrderDate = a.LatestOrderDate;
GO

--Query 38: Retrieve Products in a Specific Category
--Using the vw_ProductDetails view to get all products in a specific category, such as 'Electronics'.

SELECT ProductID, ProductName, CategoryName
FROM vw_ProductDetails
WHERE CategoryName = 'Electronics';
GO

--Query 39: Retrieve Total Sales for Each Category
--Using the vw_ProductDetails and vw_CustomerOrders views to calculate the total sales for each category.

SELECT pd.CategoryName, SUM(oi.Quantity * p.Price) AS TotalSales 
FROM OrderItems oi
INNER JOIN Products p ON oi.ProductID = p.ProductID
INNER JOIN vw_ProductDetails pd ON p.ProductID = pd.ProductID
GROUP BY pd.CategoryName
ORDER BY TotalSales DESC;
GO

--Query 40: Retrieve Customer Orders with Product Details
--Using the vw_CustomerOrders and vw_ProductDetails views to get customer orders along with the details of the products ordered.

SELECT co.CustomerID, co.FirstName, co.LastName, o.OrderId, o.OrderDate, pd.ProductName, oi.Quantity, pd.Price
FROM Orders o
INNER JOIN OrderItems oi ON o.OrderId = oi.OrderID
INNER JOIN vw_ProductDetails pd ON oi.ProductID = pd.ProductID
INNER JOIN vw_CustomerOrders co ON o.CustomerId = co.CustomerID
ORDER BY o.OrderDate DESC;
GO

--Query 41: Retrieve Top 5 Customers by Total Spending
--Using the vw_CustomerOrders view to find the top 5 customers based on their total spending.

SELECT TOP 5 CustomerID, FirstName, LastName, TotalAmount
FROM vw_CustomerOrders
ORDER BY TotalAmount DESC;
GO

--Query 42: Retrieve Products with Low Stock
--Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 10 units.

SELECT *
FROM vw_ProductDetails
WHERE Stock < 10
GO

--Query 43: Retrieve Orders Placed in the Last 7 Days
--Using the vw_RecentOrders view to find orders placed in the last 7 days.

SELECT *
FROM vw_RecentOrders
WHERE OrderDate >= DATEADD(DAY, -7, GETDATE());
GO

--Query 44: Retrieve Products Sold in the Last Month
--Using the vw_RecentOrders view to find products sold in the last month.

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalSold
FROM vw_RecentOrders ro
INNER JOIN OrderItems oi ON ro.OrderId = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
WHERE ro.OrderDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSold DESC;
GO


-- IMPLEMENTING SECURITY / ROLE-BASED ACCESS CONTROL (RBAC)

-- Step 1: Create Logins
--			First, create logins at the SQL Server level. 
--			Logins are used to authenticate users to the SQL Server instance.

CREATE LOGIN SalesUser WITH PASSWORD = 'strongpassword';

/*
### Step 2: Create Users
----------------------------------
			Next, create users in the `OnlineRetailDB` database for each login. 
			Users are associated with logins and are used to grant access to the database.
*/

CREATE USER SalesUser FOR LOGIN SalesUser;

/*
### Step 3: Create Roles
----------------------------------
			Define roles in the database that will be used to group users with similar permissions. 
			This helps simplify permission management.
*/

CREATE ROLE SalesRole;
CREATE ROLE MarketingRole;

/*
### Step 4: Assign Users to Roles
----------------------------------
			Add the users to the appropriate roles.
*/

EXEC sp_addrolemember 'SalesRole', 'SalesUser';
EXEC sp_addrolemember 'MarketingRole', 'SalesUser';

/*
### Step 5: Grant Permissions
----------------------------------
			Grant the necessary permissions to the roles based on the access requirements
*/
-- GRANT SELECT permission on the Customers Table to the SalesRole
GRANT SELECT ON Customers TO SalesRole;

-- GRANT INSERT permission on the Orders Table to the SalesRole
GRANT INSERT ON Orders TO SalesRole;

-- GRANT UPDATE permission on the Orders Table to the SalesRole
GRANT UPDATE ON Orders TO SalesRole;

-- GRANT SELECT permission on the Products Table to the SalesRole
GRANT SELECT ON Products TO SalesRole;


SELECT * FROM Customers;
DELETE FROM Customers;

SELECT * FROM Orders;
DELETE FROM Orders;

INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES (1, GETDATE(), 600);

SELECT * FROM Products;
DELETE FROM Products;

/*
### Step 6: Revoke Permissions (if needed)
----------------------------------
			If you need to revoke permissions, you can use the `REVOKE` statement.
*/
-- REVOKE INSERT permission on the Orders to the SalesRole
REVOKE INSERT ON Orders FROM SalesRole;

/* 
### Step 7: View Effective Permissions
----------------------------------
			You can view the effective permissions for a user using the query
*/
SELECT * FROM fn_my_permissions(NULL,'DATABASE');


/*
	Here are 20 different scenarios for access control in SQL Server. 
	These scenarios cover various roles and permissions that can be assigned to users 
	in the `OnlineRetailDB` database.
*/

--- Scenario 1: Read-Only Access to All Tables
CREATE ROLE ReadOnlyRole;
GRANT SELECT ON SCHEMA::dbo TO ReadOnlyRole;

--- Scenario 2: Data Entry Clerk (Insert Only on Orders and OrderItems)
CREATE ROLE DataEntryClerk;
GRANT INSERT ON Orders TO DataEntryClerk;
GRANT INSERT ON OrderItems TO DataEntryClerk;

--- Scenario 3: Product Manager (Full Access to Products and Categories)
CREATE ROLE ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductManagerRole;

--- Scenario 4: Order Processor (Read and Update Orders)
CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

--- Scenario 5: Customer Support (Read Access to Customers and Orders)
CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;

--- Scenario 6: Marketing Analyst (Read Access to All Tables, No DML)
CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;

--- Scenario 7: Sales Analyst (Read Access to Orders and OrderItems)
CREATE ROLE SalesAnalystRole;
GRANT SELECT ON Orders TO SalesAnalystRole;
GRANT SELECT ON OrderItems TO SalesAnalystRole;

--- Scenario 8: Inventory Manager (Full Access to Products)
CREATE ROLE InventoryManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO InventoryManagerRole;

--- Scenario 9: Finance Manager (Read and Update Orders)
CREATE ROLE FinanceManagerRole;
GRANT SELECT, UPDATE ON Orders TO FinanceManagerRole;

--- Scenario 10: Database Backup Operator (Backup Database)
CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;

--- Scenario 11: Database Developer (Full Access to Schema Objects)
CREATE ROLE DatabaseDeveloperRole;
GRANT CREATE TABLE, ALTER, DROP ON SCHEMA::dbo TO DatabaseDeveloperRole;

--- Scenario 12: Restricted Read Access (Read Only Specific Columns)
CREATE ROLE RestrictedReadRole;
GRANT SELECT (FirstName, LastName, Email) ON Customers TO RestrictedReadRole;

--- Scenario 13: Reporting User (Read Access to Views Only)
CREATE ROLE ReportingRole;
GRANT SELECT ON SalesReportView TO ReportingRole;
GRANT SELECT ON InventoryReportView TO ReportingRole;

--- Scenario 14: Temporary Access (Time-Bound Access)
-- Grant access
CREATE ROLE TempAccessRole;
GRANT SELECT ON SCHEMA::dbo TO TempAccessRole;

-- Revoke access after the specified period
REVOKE SELECT ON SCHEMA::dbo FROM TempAccessRole;

--- Scenario 15: External Auditor (Read Access with No Data Changes)
CREATE ROLE AuditorRole;
GRANT SELECT ON SCHEMA::dbo TO AuditorRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AuditorRole;

--- Scenario 16: Application Role (Access Based on Application)
CREATE APPLICATION ROLE AppRole WITH PASSWORD = 'StrongPassword1';
GRANT SELECT, INSERT, UPDATE ON Orders TO AppRole;

--- Scenario 17: Role-Based Access Control (RBAC) for Multiple Roles 
-- Combine roles
CREATE ROLE CombinedRole;
EXEC sp_addrolemember 'SalesRole', 'CombinedRole';
EXEC sp_addrolemember 'MarketingRole', 'CombinedRole';

--- Scenario 18: Sensitive Data Access (Column-Level Permissions)
CREATE ROLE SensitiveDataRole;
GRANT SELECT (Email, Phone) ON Customers TO SensitiveDataRole;

--- Scenario 19: Developer Role (Full Access to Development Database)
CREATE ROLE DevRole;
GRANT CONTROL ON DATABASE::OnlineRetailDB TO DevRole;

--- Scenario 20: Security Administrator (Manage Security Privileges)
CREATE ROLE SecurityAdminRole;
GRANT ALTER ANY LOGIN TO SecurityAdminRole;
GRANT ALTER ANY USER TO SecurityAdminRole;
GRANT ALTER ANY ROLE TO SecurityAdminRole;
