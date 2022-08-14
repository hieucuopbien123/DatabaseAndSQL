-- Câu lệnh SELECT
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price > ( -- truy vấn con luôn nằm trong (), truy vấn cha chứa truy vấn con
        SELECT
            AVG (list_price) -- dùng thoải mái các hàm. Cái này không trả ra 1 table mà ra đúng 1 số là tb list_price mọi
			-- sản phẩm trong data trả ra và so sánh với list_price
        FROM
            production.products
        WHERE
            brand_id IN (
                SELECT
                    brand_id
                FROM
                    production.brands
                WHERE
                    brand_name = 'Strider' OR brand_name = 'Trek'
            )
    )
	AND
	list_price >= ALL (
        SELECT
            AVG (list_price)
        FROM
            production.products
        GROUP BY
            brand_id
    )
ORDER BY
    list_price
-- query con thứ 2 trả ra 1 table các trung bình cộng từng nhóm

SELECT
    customer_id,
    first_name,
    last_name,
    city
FROM
    sales.customers c --đặt tên ở ngoài dùng được ở trong
WHERE
    EXISTS (
    -- VD dùng not exist tức là lấy các thông số trên nếu bản ghi bên dưới k có giá trị nào. Điều này tương đương với 
    -- NOT IN ở 1 số TH. Ở TH này buộc phải đặt tên variable c nếu k sẽ chả có ý nghĩa. Hiểu bản chất
        SELECT
            customer_id
        FROM
            sales.orders o
        WHERE
            o.customer_id = c.customer_id AND YEAR (order_date) = 2017
    )
ORDER BY
    first_name,
    last_name;

-- Dùng subquery với FROM, nếu ta cần lấy gì trong query đó ở ngoài thì phải đặt cho nó 1 cái tên như ở dưới là t. 
-- Khi đó SQL tự hiểu dùng tên đó là t.order_count, ta có thể viết rõ như v or như dưới là cách viết gọn 
SELECT
    AVG(order_count) average_order_count_by_staff
FROM
(
    SELECT
		staff_id, 
        COUNT(order_id) order_count
    FROM sales.orders
    GROUP BY staff_id
) t
go


-- Câu lệnh view
-- Tạo 1 view, dùng GO để dùng được view ở dưới luôn
CREATE VIEW sales.product_info -- product_info là tên view
AS
SELECT
    product_name, 
    brand_name
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;
go

-- Update view
ALTER VIEW sales.product_info 
AS
SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;
go

-- Dùng view
SELECT * FROM sales.product_info;
DROP VIEW sales.product_info;

-- Vc dùng view nó như thao tác trên 1 bảng mới nhưng lại ảnh hưởng đến bảng gốc mà VIEW lấy
CREATE TABLE test1(
	name varchar(10), 
	age int
)
GO
CREATE VIEW test AS SELECT * FROM test1
GO
INSERT INTO test1 VALUES('HH',1)
SELECT * FROM test1
SELECT * FROM test
INSERT INTO test VALUES('TT', 2) -- view gắn với chỉ 1 table thì có thể thêm data vào table bằng cách thêm vào view 
DROP TABLE test1
DROP VIEW test

-- Câu lệnh trigger
CREATE TRIGGER delete_viewtrigger
INSTEAD OF DELETE ON monitor
FOR EACH ROW
BEGIN
    UPDATE clazz SET monitor_id = NULL
    WHERE clazz_id = OLD.clazz_id;
END;
