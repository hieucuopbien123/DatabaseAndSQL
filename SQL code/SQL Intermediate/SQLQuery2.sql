-- Biến type loop condition rule
DECLARE @model_year SMALLINT, 
        @product_name AS VARCHAR(MAX);
SET @model_year = 2018 + 3;

DECLARE @product_count INT;
SET @product_count = ( -- lệnh này trả ra số nguyên đúng kiểu mà biến lưu
    SELECT
        COUNT(*) 
    FROM
        production.products 
);
SELECT @product_count;

-- Gán giá trị của biến bên trong Select
DECLARE @list_price DECIMAL(10,2);
SELECT
    @product_name = product_name,
    @list_price = list_price
FROM
    production.products
WHERE
    product_id = 100;
-- Xem giá trị 2 biến đó
SELECT
    @product_name AS product_name, 
    @list_price AS list_price;
GO

-- Dùng biến và PROC
CREATE  PROC uspGetProductList(
    @model_year SMALLINT
) AS
BEGIN
    DECLARE @product_list VARCHAR(MAX);
    SET @product_list = '';

    SELECT
        @product_list = @product_list + product_name 
                        + CHAR(10) -- CHAR(10) là line feed, char(9) là tab
    FROM
        production.products
    WHERE
        model_year = @model_year
    ORDER BY
        product_name;

    PRINT @product_list; 
END;
GO
EXEC uspGetProductList 2018;
DROP PROC uspGetProductList;
GO

-- OUTPUT ở tham số ý chỉ biến này sẽ lấy được ở bên ngoài sau khi kết thúc procedure
CREATE PROCEDURE uspFindProductByModel (
    @model_year SMALLINT,
    @product_count INT OUTPUT
) AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

    SELECT @product_count = @@ROWCOUNT;
	IF @product_count <> 0 -- có thể lồng nhiều thoải mái
		PRINT @product_count
	ELSE 
		PRINT 'No record found'
END;
GO

DECLARE @count INT = 0;
EXEC uspFindProductByModel 
	@model_year = 2018, 
	@product_count = @count OUTPUT; -- Nhớ có từ khóa OUTPUT ở sau cả khi truyền vào và dùng tiếp được ở ngoài
SELECT @count AS 'Number of products found'; 
DROP PROC uspFindProductByModel;

DECLARE @counter INT = 1;
WHILE @counter <= 5
BEGIN
    PRINT @counter; 
    SET @counter = @counter + 1;
END