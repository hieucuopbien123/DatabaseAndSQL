-- Câu lệnh Function và Biến table

-- Câu lệnh function
CREATE FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2),
    @discount DEC(4,2)
)
RETURNS DEC(10,2)
AS
BEGIN
    RETURN @quantity * @list_price * (1 - @discount);
END;
GO

SELECT sales.udfNetSale(10, 100, 0.1) net_sale -- gọi ez với tên và tham số, đổi tên hiển thị sang net_sale

-- Dùng lồng function trong 1 function khác
SELECT
    order_id, 
    SUM(sales.udfNetSale(quantity, list_price, discount)) net_amount
FROM
    sales.order_items
GROUP BY
    order_id
ORDER BY
    net_amount DESC;
GO

ALTER FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2)
)
RETURNS DEC(10,2)
AS
BEGIN
    RETURN @quantity * @list_price; -- SQL sẽ tự cast để cộng
END;
GO
DROP FUNCTION sales.udfNetSale;


-- Biến table
DECLARE @product_table TABLE (
    product_name VARCHAR(MAX) NOT NULL,
    brand_id INT NOT NULL,
    list_price DEC(11,2) NOT NULL
);

INSERT INTO @product_table
SELECT
    product_name,
    brand_id,
    list_price
FROM
    production.products
WHERE
    category_id = 1;

SELECT * FROM @product_table;


-- Khi dùng biến table JOIN với bảng tạm thì buộc phải đặt bí danh cho nó vì nó k có chấm <tên trường> như bth
-- VD ở dưới ta đặt là pt
SELECT
    brand_name,
    product_name,
    list_price
FROM
    production.brands b
INNER JOIN @product_table pt ON b.brand_id = pt.brand_id; -- Chỉ là 1 cách rút gọn của: @product_table AS pt

-- Sử dụng function return về 1 biến TABLE
GO
CREATE OR ALTER FUNCTION udfSplit(
    @string VARCHAR(MAX), 
    @delimiter VARCHAR(50) = ' '
)
RETURNS @parts TABLE ( -- Trả ra 1 biến kiểu table, ở đây ta đặt tên luôn để dùng @part trong hàm
	idx INT IDENTITY PRIMARY KEY,		
	val VARCHAR(MAX)   
)
AS
BEGIN
	DECLARE @index INT = -1;
	WHILE (LEN(@string) > 0) -- Lấy length của biến kiểu VARCHAR
	BEGIN
		SET @index = CHARINDEX(@delimiter , @string); -- Trả ra index của @delimiter trong @string 
        -- Bắt đầu từ vị trí 1 nếu như string k có ký tự @delimeter nào thì trả ra 0
    
		IF (@index = 0) AND (LEN(@string) > 0)  
		BEGIN 
			INSERT INTO @parts VALUES (@string);
			BREAK -- Dừng vòng loop ngoài
		END

		IF (@index > 1)  
		BEGIN 
			-- Lấy @string từ 0 đến vị trí @index - 1 và gán phần string còn lại sang mé bên phải
			INSERT INTO @parts VALUES (LEFT(@string, @index - 1));
			SET @string = RIGHT(@string, (LEN(@string) - @index)); -- Lấy từ vị trí nào đến hết cuối
		END
		ELSE
			SET @string = RIGHT(@string, (LEN(@string) - @index)); 
	END
	RETURN -- K cần viết return tên biến nx vì nó là @part được xử lý bên trên r
END
GO
SELECT * FROM udfSplit('foo,bar,baz,',',');