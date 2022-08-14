CREATE TABLE Person(
	PersonID int,
	LastName varchar(255),
	FirstName varchar(255),
	Age int,
	Gender char(1),
	City varchar(255)
);
INSERT INTO Person 
VALUES(1,'Hiddleston','Tom',23,'F','Florida'),
(2,'Watson','Angela',18,'F','Texas'),
(3,'Clooney','Pandora',34,'U','Arizona'),
(4,'Crane','Amory',52,'M','California'),
(5,'Clooney','Bush',67,'M','Arizona'),
(6,'Schwimmer','Geoffrey',19,'U','Hawaii')
INSERT INTO Person 
VALUES(10,'Hiddles','To',3,'M','Florid')

ALTER TABLE Person DROP COLUMN Age
DROP TABLE Person;
SELECT * FROM Person;


-- Backup database
BACKUP DATABASE QLKH
TO DISK = 'C:\Test\test.bak';
-- Nếu lỗi -> search window -> service -> SQL Server -> double click -> Login -> Local System Account -> Apply -> OK. Tạo sẵn thư mục đích đi

BACKUP DATABASE QLKH
TO DISK = 'C:\Test\test1.bak'
WITH DIFFERENTIAL;


-- Câu lệnh table
-- UNIQUE dùng với nhiều trường
CREATE TABLE Test(
	userId int,
	age int,
	CONSTRAINT ttt UNIQUE(userId, age)
)


-- Câu lệnh view
-- View thg dùng để join nhiều bảng, như dưới là ta có thể lấy ra 3 trường với 3 cái tên như nào trong view
-- Nó sẽ lấy kiểu bảng có 3 cột 
CREATE VIEW vComSupPro1(ComName, ProdName, Qty)
AS
SELECT Company.Name, Product.Name, Quantity
FROM Company INNER JOIN Supply ON Company.CompanyID = Supply.CompanyID
INNER JOIN Product ON Supply.ProductID = Product.ProductID

SELECT * FROM vComSupPro1

-- Tạo view cho database BikeStores
CREATE VIEW product_master
WITH SCHEMABINDING
AS 
SELECT
product_id, product_name, model_year, list_price, 
brand_name, category_name
FROM production.products p INNER JOIN 
production.brands b 
ON b.brand_id = p.brand_id
INNER JOIN production.categories c ON c.category_id = 
p.category_id


-- Câu lệnh index
-- Xem tốc độ
SET STATISTICS IO ON
GO
SELECT * 
FROM dbo.product_master
ORDER BY product_name;
GO 

-- Nhờ có cái này là tăng tốc độ
CREATE UNIQUE CLUSTERED INDEX ucidx_product_id 
ON dbo.product_master(product_id);

-- Câu lệnh procedure
-- Proc nó k ảnh hưởng bởi chấm phẩy, họ thg dùng nó đặt tên kiểu thứ tự đánh số như dưới
CREATE PROC group_sp;1
AS SELECT * FROM Company
GO
CREATE PROC group_sp;2
AS SELECT Name FROM Company
GO
CREATE PROC group_sp;3
AS SELECT Name, Address FROM Company
GO
EXEC group_sp;3

-- Proc dùng biến lưu giá trị trả về 
CREATE PROCEDURE scores
@score1 smallint,
@score2 smallint,
@score3 smallint,
@score4 smallint,
@score5 smallint,
@myAvg smallint OUTPUT
AS SELECT @myAvg = (@score1 + @score2 + 
@score3 + @score4 + @score5) / 5

DECLARE @AvgScore smallint
EXEC scores 10, 9, 8, 8, 10, @AvgScore OUTPUT
SELECT 'The Average Score is: ',@AvgScore
Go

DECLARE @AvgScore smallint
EXEC scores
@score1=10, @score3=9, @score2=8, @score4=8,
@score5=10, @myAvg = @AvgScore OUTPUT
SELECT 'The Average Score is: ',@AvgScore
Go

-- Proc dùng return giá trị trả về
CREATE PROC MyReturn
@t1 smallint, @t2 smallint, @retval smallint
AS SELECT @retval = @t1 + @t2
RETURN @retval
GO
DECLARE @myReturnValue smallint
EXEC @myReturnValue = MyReturn 9, 9, 0
SELECT 'The return value is: ',@myReturnValue

-- Trong system có 1 loại sysobjects lưu proc và trigger của database, ở đây ta check database có proc này r thì xóa nó đi và tạo lại
USE CompanySupplyProduct
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='pCompany' AND type='P') -- type P là type procedure
DROP PROCEDURE pCompany
GO

CREATE PROCEDURE pCompany WITH ENCRYPTION
AS SELECT Name, NumberofEmployee
FROM Company
ORDER BY Name DESC
GO
EXEC sp_helptext pCompany; -- K xem được nội dung câu lệnh

-- Câu lệnh trigger
USE CompanySupplyProduct
GO
IF EXISTS(SELECT name FROM sysobjects
WHERE name='AddCompany' AND Type='TR') -- TR là type trigger, check đã từng có trigger tên là AddCompany chưa
DROP TRIGGER AddCompany
GO

CREATE TRIGGER AddCompany
ON Company
FOR INSERT 
AS
PRINT 'The Company table has just been inserted data'
GO
--Kiểu FOR INSERT chưa dùng bh. Cái này nó insert vào rồi thực hiện tiếp gì bên dưới như AFTER

--Sinh 1 bảng mới lưu các company từng bị xóa
CREATE TABLE [DeletedCompany] (
	[CompanyID] int,
	[Name] varchar(40),
	[NumberofEmployee] int,
	[Address] varchar(50),
	[Telephone] char(15),
	[EstablishmentDay] date,
	PRIMARY KEY ([CompanyID])
);

CREATE TRIGGER tg_DeleteCompany
ON Company
FOR DELETE
AS
INSERT INTO DeletedCompany SELECT * FROM deleted

DELETE FROM Company WHERE CompanyID = 17

IF EXISTS(SELECT name FROM sysobjects
WHERE name='tg_CheckPrice' AND Type='TR')
DROP TRIGGER tg_CheckPrice
GO

-- K cho update nếu new price quá 10%. Vừa TRIGGER UPDATE vừa INSERT
CREATE TRIGGER tg_CheckPrice
ON Product
FOR INSERT, UPDATE
AS
	DECLARE @oldprice decimal(10,2), @newprice decimal(10,2)
	SELECT @oldprice = Price FROM deleted
	PRINT 'Old price ='
	PRINT CONVERT(varchar(6), @oldprice)
	PRINT(@oldprice)
	SELECT @newprice = Price FROM inserted
	PRINT 'New price ='
	PRINT CONVERT(varchar(6), @newprice)
	IF(@newprice > (@oldprice*1.10) OR ISNULL(@oldprice, 0) = 0) -- Cấm insert luôn
	BEGIN
		PRINT 'New price increased over 10%, not update'
		ROLLBACK
	END
	ELSE
	PRINT 'New price is accepted'
UPDATE Product
SET Price = Price * 2  -- Dùng TT Price ở vế phải để biến nào thay đổi như nào so với trước được

INSERT INTO [Product]([Name],[Color],[Price]) -- Nhờ trigger bên trên mà khỏi add vào nhé
VALUES('Standard MT 2022', 'brown', '299')

-- Biến type loop condition rule
-- Khai báo biến dùng DECLARE, set giá trị dùng SET, SELECT biến là chọn biến. V cái dưới là gì
DECLARE @var INT;
SELECT @var = ProductID FROM product
-- Câu lệnh SELECT biến nhưng lại = kiểu này tức là gán giá trị cho biến, nếu bảng trả ra nhiều giá trị thì nó sẽ lấy giá trị cuối cùng mà thôi
-- Chính vì v ta thg expect bảng chỉ có 1 record và gán giá trị cần lấy vào biến. Cái này khác với SET biến = SELECT thì biến là 1 bảng
SELECT @var

-- Nếu ta muốn lấy giá trị tổng tất cả data 1 row xong nhân 10 và lấy giá trị đó
SELECT (SELECT SUM(ProductID) FROM product)*10

-- Khi 1 câu query chỉ lấy 1 trường và chỉ có đúng 1 record thì sẽ dùng được như 1 giá trị.
SELECT * FROM product WHERE ProductID = (SELECT ProductID FROM product WHERE ProductID = 1000)*10
