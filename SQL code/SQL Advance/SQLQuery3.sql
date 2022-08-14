-- Biến type loop condition rule

DECLARE @bigIntVar BIGINT = 10;
DECLARE @doublePrecisionVar DOUBLE PRECISION = 10.9;
DECLARE @bitVar Bit = 0;
DECLARE @money Money = $1;
SET @money += 1;
DECLARE @smallMoneyVar smallMoney = $1;
DECLARE @timeVar Time = '11:20:10.100'; -- Chỉ giờ phút giây mili
DECLARE @realVar real = 1.2;
DECLARE @charVar CHARACTER = 'H';

SELECT @bitVar;
SELECT @money;
SELECT @smallMoneyVar;
SELECT @timeVar;

-- Type chuỗi
DECLARE @v1 Char(10) = 'Hello1'; -- K chứa Unicode, cấp phát tĩnh
DECLARE @v2 Nchar(10) = 'Hello2'; -- Chứa Unicode, cấp phát tĩnh
DECLARE @v3 Varchar(10) = 'Hello3'; -- K chứa Unicode, cấp phát động max đến n ô nhớ
DECLARE @v4 Nvarchar(20) = N'Nguyễn Thụ Hiếu'; -- Chứa Unicode, cấp phát động max n ô nhớ

SELECT @v1;
SELECT @v2;
SELECT @v3;
SELECT @v4;

DECLARE @datetimeVar DATETIME = '19950419'; -- Có thể yyyymmdd như này
DECLARE @datetimeVar2 DATETIME = '1995-04-19 01:00:00.000';
SELECT @datetimeVar;
SELECT @datetimeVar2;


-- Câu lệnh SELECT

SELECT COUNT(DISTINCT model_year) FROM production.products
-- K có DISTINCT -> số phần tử có cột model_year thì chính là số phần tử
-- Có DISTINCT -> số lượng model_year khác nhau của bảng

SELECT TOP 5 * FROM production.products

SELECT YEAR(GETDATE()) - YEAR('20010118')

SELECT ALL
FROM sales.orders
FULL OUTER JOIN sales.staffs ON sales.orders.staff_id = sales.staffs.staff_id

SELECT * 
FROM sales.orders
CROSS JOIN sales.staffs 
-- tương đương với
SELECT * 
FROM sales.orders, sales.staffs


SELECT first_name FROM sales.contacts
UNION ALL
SELECT last_name FROM sales.staffs

-- Phân biệt cái dưới rất xàm lol, khi 2 bảng cùng có first_name thì phải select first_name bảng nào phải nói rõ ra
SELECT sales.contacts.first_name FROM sales.contacts,sales.staffs
-- Vc viết 2 bảng liên tiếp nhau FROM table1,table2 tức là tích đề các của 2 table.

-- Cách tạo 1 bảng copyTable y hệt sales.staffs nhưng bên trong k có dữ liệu gì
SELECT * INTO CloneTable
FROM sales.staffs
WHERE 6 > 9

-- Sau đó có thể thêm data vào 1 bảng từ 1 lệnh select cơ. Thế thì phải bật mode IDENTITY_INSERT cho nó
SET IDENTITY_INSERT CloneTable ON
GO
insert into CloneTable(staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
SELECT staff_id, first_name, last_name, email, phone, active, store_id, manager_id FROM sales.staffs
SET IDENTITY_INSERT CloneTable OFF

SELECT * FROM CloneTable

DROP TABLE CloneTable;

DECLARE @testVar TIMESTAMP = 10;
SELECT @testVar;
DECLARE @testVarChar CHARACTER = '1';
