﻿USE QLCH
GO

CREATE PROCEDURE GetCategories
AS
BEGIN
    SELECT id, catename FROM Category WHERE status = N'Using';
END
GO

CREATE PROCEDURE GetCategoryName
AS
BEGIN
    SELECT catename FROM Category WHERE status = N'Using';
END
GO

CREATE PROCEDURE DeleteCategory
    @CategoryID INT
AS
BEGIN
    UPDATE Category
    SET status = N'Unused'
    WHERE id = @CategoryID
    SELECT 1 AS Success
END
GO

CREATE PROCEDURE InsertCategory
    @CategoryId INT,
    @CategoryName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Category(id, catename, status)
        VALUES (@CategoryId, @CategoryName, N'Using')
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE UpdateCategory
    @CategoryId INT,
    @NewCategoryName NVARCHAR(100)
AS
BEGIN
    UPDATE Category
    SET catename = @NewCategoryName
    WHERE id = @CategoryId
END
GO

CREATE PROCEDURE GetClients
AS
BEGIN
    SELECT id, fullname, address, phonenumber FROM Customer WHERE status = N'Using';
END
GO

CREATE PROCEDURE DeleteClient
    @ClientID INT
AS
BEGIN
    UPDATE Customer
    SET status = N'Unused'
    WHERE id = @ClientID
    SELECT 1 AS Success
END
GO

CREATE PROCEDURE InsertClient
    @ClientId INT,
    @ClientName NVARCHAR(100),
	@ClientAddress NVARCHAR(255),
    @ClientPhone CHAR(10)
AS
BEGIN
	BEGIN TRY
        INSERT INTO Customer(id, fullname, address, phonenumber, status)
		VALUES (@ClientId, @ClientName, @ClientAddress, @ClientPhone, N'Using')
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE UpdateClient
    @ClientId INT,
    @NewClientName NVARCHAR(100),
	@NewClientAddress NVARCHAR(255),
    @NewClientPhone CHAR(10)
AS
BEGIN
    UPDATE Customer
    SET fullname = @NewClientName,
		address = @NewClientAddress,
		phonenumber = @NewClientPhone
    WHERE id = @ClientId
END
GO

CREATE PROCEDURE GetFoods
AS
BEGIN
    SELECT I.id, I.name, I.unit, I.price, C.catename
    FROM Item AS I
    INNER JOIN Category AS C ON I.cateid = C.id
	WHERE I.status = N'Using';
END
GO

CREATE PROCEDURE DeleteFood
    @FoodId INT
AS
BEGIN
	UPDATE Item
    SET status = N'Unused'
    WHERE id = @FoodID
    SELECT 1 AS Success
END
GO

CREATE PROCEDURE InsertFood
    @FoodId INT,
    @FoodName VARCHAR(255),
    @Unit VARCHAR(50),
    @Price DECIMAL(10, 2),
    @CategoryId INT
AS
BEGIN
BEGIN TRY
        INSERT INTO Item(id, name, unit, price, cateid, status)
		VALUES (@FoodId, @FoodName, @Unit, @Price, @CategoryId, N'Using')
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE UpdateFood
    @FoodId INT,
    @NewFoodName VARCHAR(255),
    @NewUnit VARCHAR(50),
    @NewPrice DECIMAL(10, 2),
    @NewCategoryId INT
AS
BEGIN
    UPDATE Item
    SET name = @NewFoodName,
		unit = @NewUnit,
		price = @NewPrice,
		cateid = @NewCategoryId
    WHERE id = @FoodId
END
GO

CREATE PROCEDURE GetAccounts
AS
BEGIN
    SELECT A.username, A.fullname, R.rolename, A.status
    FROM Account AS A
    INNER JOIN Role AS R ON A.roleid = R.id
END
GO

CREATE PROCEDURE InsertAccount
    @Username VARCHAR(255),
	@fullname VARCHAR(255),
    @pwd VARCHAR(255),
    @roleid INT
AS
BEGIN
    INSERT INTO Account(username,fullname,pwd,roleid,status)
    VALUES (@Username, @fullname, @pwd, @roleid,N'Using')
END
GO

CREATE PROCEDURE DeleteAccount
    @Username VARCHAR(255)
AS
BEGIN
	Delete Account
    WHERE username = @Username
	SELECT 1 AS Success
END
GO

CREATE PROCEDURE UpdateAccount
    @Username VARCHAR(255),
	@fullname NVARCHAR(255),
    @roleid INT,
	@status nvarchar(255)
AS
BEGIN
    UPDATE Account
    SET fullname = @fullname,
		roleid = @roleid,
		status = @status
    WHERE username = @Username 
END
GO

CREATE PROCEDURE UpdateInfo
    @Username VARCHAR(255),
	@fullname NVARCHAR(255),
    @pwd VARCHAR(255)
AS
BEGIN
    UPDATE Account
    SET fullname = @fullname,
		pwd = @pwd
    WHERE username = @Username 
END
GO

CREATE PROC LoginAccount
@Username nvarchar(100),
@passWord nvarchar(100)
AS 
BEGIN
	SELECT * FROM dbo.Account WHERE  username = @userName AND pwd = @passWord AND status = N'Using'
END
GO

CREATE PROC checkAdmin
@Username nvarchar(100)
AS 
BEGIN
	SELECT * FROM dbo.Account WHERE  username = @userName AND roleid = 1
END
GO

CREATE PROC checkpwd
@Username nvarchar(100),
@pwd nvarchar(100)
AS 
BEGIN
	SELECT * FROM dbo.Account WHERE  username = @userName AND pwd = @pwd
END
GO

CREATE PROCEDURE CreateBill
    @customerid INT,
    @status VARCHAR(50),
    @time DATE,
    @id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Bill (customerid, status, time)
    VALUES (@customerid, @status, @time);

    SET @id = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE CreateBillDetail
    @billid INT,
    @itemid INT,
    @quantity INT,
    @total DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Bill WHERE id = @billid)
    BEGIN
        PRINT N'Mã hóa đơn không tồn tại';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Item WHERE id = @itemid)
    BEGIN
        PRINT N'Mã sản phẩm không tồn tại';
        RETURN;
    END;

    INSERT INTO BillDetail (billid, itemid, quantity, total)
    VALUES (@billid, @itemid, @quantity, @total);
END
GO

CREATE PROCEDURE GetProductId
	@productName nvarchar(50)
AS
BEGIN
	SELECT id FROM Item WHERE name = @productName
END
GO

CREATE PROCEDURE GetCustomerId
	@customerName nvarchar(50)
AS
BEGIN
	SELECT id FROM Customer WHERE fullname = @customerName
END
GO

CREATE PROCEDURE UpdateStatusBill
    @id INT,
    @status nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Bill WHERE id = @id)
    BEGIN
        PRINT N'Mã hóa đơn không tồn tại';
        RETURN;
    END;

    UPDATE Bill
    SET status = @status
    WHERE id = @id;
END
GO

CREATE PROCEDURE GetListBills
AS
BEGIN
	SET NOCOUNT ON;

    SELECT bi.id , cu.fullname, bi.status, bi.time
    FROM Bill bi
    INNER JOIN Customer cu ON bi.customerid = cu.id;
END
GO

CREATE PROCEDURE GetInfomation
	@id nvarchar(50)
AS
BEGIN
	SELECT cu.fullname, cu.address, bi.time FROM Bill bi INNER JOIN Customer cu ON cu.id = bi.customerid WHERE bi.id = @id
END
GO

CREATE PROCEDURE GetBillDetail
    @billid INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT bd.billid, it.name, it.price, bd.quantity, bd.total
	FROM BillDetail bd
	INNER JOIN Item it ON bd.itemid = it.id
	WHERE bd.billid = @billid;
END
GO