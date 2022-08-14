-- Basic/Câu lệnh hệ thống
SELECT * FROM sys.databases; -- Table lưu các database hiện tại 
SELECT * FROM INFORMATION_SCHEMA.TABLES -- Lưu các SCHEMA và table 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS -- Lưu tổ hợp SCHEMA TABLE và COLUMN
SELECT * FROM sys.all_columns -- Lưu tất cả các cột
SELECT * FROM sys.columns -- Lưu các cột
EXEC sp_help 'production.products' -- Ra nhiều bảng chứa thông tin của bảng nào


-- Câu lệnh index
CREATE INDEX index_name ON production.products(list_price) -- Dấu phẩy ngăn cách đánh nếu index nhiều trường
SELECT * FROM production.products
WHERE list_price >= 100 -- Maybe nhanh hơn

CREATE UNIQUE INDEX IndexNameUnique ON production.categories(category_id)
-- UNIQUE INDEX để đánh cho các trường của table mà unique ở mỗi record, nó cũng ngăn cản dữ liệu mới thêm vào mà bị trùng với
-- dữ liệu đã có trong SQL. 2 loại INDEX dùng nào cũng được. UNIQUE có thể có nhiều còn PRIMARY KEY chỉ có 1

DROP INDEX index_name ON production.products
DROP INDEX IndexNameUnique ON production.categories


-- Biến type loop condition rule
EXEC sp_addtype 'TNAME', 'nvarchar(100)', 'NOT NULL'
GO
CREATE TABLE TEST(
	name TNAME
)
GO
-- Phải tắt tab này đi thì khi mở UI của table mới thấy type của ta sau khi tạo
DROP TABLE TEST
EXEC sp_droptype 'TNAME'

-- Tạo type mới bằng lệnh CREATE TYPE
CREATE TYPE dbo.ADDRESS FROM nvarchar(2) NOT NULL
GO
CREATE TABLE TEST(
	name dbo.ADDRESS
)
GO
DROP TABLE TEST
DROP TYPE dbo.ADDRESS; -- xóa cũng khác
GO

-- Tạo rule
GO
CREATE RULE list_rule  
AS   
@list IN ('1389', '0736', '0877');
GO
CREATE TABLE TEST(
	name nvarchar(50)
)
GO
EXEC sp_bindrule list_rule, 'TEST.name'
INSERT INTO TEST(name) VALUES ('1389');
-- Bh thêm vào cột name chỉ được 3 giá trị xđ trong rule
DROP TABLE TEST
DROP RULE list_rule;


-- Câu lệnh cursor: thao tác từng dòng của record thì làm gì
DECLARE productsCursor CURSOR FOR SELECT product_id, product_name, list_price FROM production.products
OPEN productsCursor

DECLARE @product_id int
DECLARE @product_name varchar(225)
DECLARE @list_price DEC(10,2)

FETCH NEXT FROM productsCursor INTO @product_id, @product_name, @list_price -- pointer chưa tới cuối thì fetch tiếp được
WHILE @@FETCH_STATUS = 0
BEGIN
	IF(@list_price > 200)
	BEGIN
		PRINT @product_name + ' >200'
	END
	ELSE
	IF @list_price > 100
	BEGIN
		PRINT @product_name + ' >100'
	END
	FETCH NEXT FROM productsCursor INTO @product_id, @product_name, @list_price
END

CLOSE productsCursor
DEALLOCATE productsCursor


-- Câu lệnh database
-- Custom tạo file mdf, ldf
DROP DATABASE IF EXISTS QLKH
CREATE DATABASE QLKH 
ON 
	( NAME = QLKH_dat, -- Tên của cục này 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\QLKHdat.mdf', 
	SIZE = 10, -- Kích thước ban đầu của file
	MAXSIZE = 50, -- Kích thước lớn nhất của file
	FILEGROWTH = 5 ) -- mdf lưu dữ liệu chính, sau này database mở rộng ra thì kích thước file tăng lên dần dần
	-- Ở đây nó sẽ tăng lên cứ mỗi 5MB 1 cục nếu file size bị vượt quá
LOG ON -- LOG ON sẽ viết log cho các thao tác trong database vào file nào
	( NAME = QLKH_log, 
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\QLKHlog.ldf', 
	SIZE = 5MB, -- Có thể rõ đuôi MB or để bth cx mặc định là MB
	MAXSIZE = 25MB, 
	FILEGROWTH = 5MB ); 
GO
-- Bên trên là custom như mặc định vì nếu ta k specific như v thì khi database tạo ra nó cũng tự tạo 2 file ở thư mục đó


-- Câu lệnh SELECT
SELECT * FROM Lecturers WHERE FullName LIKE 'x%%' ESCAPE 'x';
-- Các ký tự đại diện như %, [], _ mà lại muốn tìm trong data thực tế thì ta chỉ cần thêm vào trước nó 1 loại ký tự k dùng
-- như x ở đây và ta dùng ESCAPE '<ký tự đó>' thì nó hiểu là 1 ký tự sau x sẽ coi như ký tự bth. VD ở trên ta đang tìm 
-- chuỗi bắt đầu bằng %. VD: a LIKE ‘H%!_’ ESCAPE ‘!’; tức là tìm chuỗi bắt đầu bằng H và kết thúc bằng _
