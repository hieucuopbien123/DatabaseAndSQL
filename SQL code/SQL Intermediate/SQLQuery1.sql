-- Temp Table
-- Cách 1 tạo Local Temp Table với SELECT INTO
SELECT
    product_name,
    list_price
INTO #trek_products 
FROM
    production.products
WHERE
    brand_id = 9;
go

DROP TABLE #trek_products; -- Đằng nào local temp table cx tự xóa khi kết thúc phiên 

--Cách 2: tạo bảng tạm bth r tự insert data vào. INSERT INTO có thể kết hợp câu lệnh SELECT
CREATE TABLE #haro_products (
    product_name VARCHAR(MAX),
    list_price DEC(10,2)
);
INSERT INTO #haro_products
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    brand_id = 2;
DROP TABLE #haro_products;
-- Ở đây có thể tạo Global Temporary Table bằng cách đặt tên trước nó 2 dấu thăng là được: ##
GO


-- Câu lệnh procedure
CREATE PROCEDURE uspProductList -- viết gọn lệnh là CREATE PROC <tên>
	AS BEGIN
		SELECT
			product_name,
            list_price
		FROM
			production.products
		ORDER BY
			product_name;
	END;
GO

-- Chạy proc
EXEC uspProductList; -- or EXECUTE uspProductList;
EXEC sp_helptext uspProductList;
-- Cái sp_helptext là thủ tục có sẵn của hệ thống cho phép xem content của 1 proc nào
DROP PROC uspProductList; -- or DROP PROCEDURE uspProductList;
GO

-- params của procedure trong (), type thông qua từ khóa AS, nên quy ước bắt đầu với @, mạnh hơn view
CREATE PROCEDURE uspFindProducts(@min_list_price AS DECIMAL)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price
    ORDER BY
        list_price;
END;
GO

-- Modify procedure
ALTER PROCEDURE uspFindProducts(
    @min_list_price AS DECIMAL = 0 -- Có thể làm nhiều tham số kèm giá trị mặc định
    ,@max_list_price AS DECIMAL = 999999
    ,@name AS VARCHAR(max) -- Max thì dùng max bộ nhớ có thể luôn
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price AND
        list_price <= @max_list_price AND
        product_name LIKE '%' + @name + '%' -- like có thể chơi kiểu cộng string như này
    ORDER BY
        list_price;
END;
GO
EXECUTE uspFindProducts 900, 1000, 'Hieu';
EXECUTE uspFindProducts @name = 'Trek', @max_list_price = 99999; -- tường minh
DROP PROC uspFindProducts;