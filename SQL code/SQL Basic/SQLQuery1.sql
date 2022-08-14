-- Basic/Các câu lệnh về hệ thống
select @@version;


-- Câu lệnh Database
CREATE DATABASE Testdb;
DROP DATABASE Testdb;


-- Câu lệnh Table
CREATE TABLE sales.participants(
    activity_id int NOT NULL,
    customer_id int,
    birth DATE NOT NULL,
    duration DEC(5,2)
    -- PRIMARY KEY(activity_id, customer_id)
);

-- Thêm primary key sau khi đã khai báo table thì phải chưa define PRIMARY_KEY mới dùng được
-- Trường mà ta thêm PRIMARY KEY bằng ALTER TABLE phải là NOT NULL nếu k sẽ lỗi. Mặc định của nó là NULL nên phải chủ động khai báo 
ALTER TABLE sales.participants
ADD PRIMARY KEY(activity_id, customer_id);
DROP TABLE sales.participants

CREATE TABLE sales.promotions (
    promotion_id INT PRIMARY KEY IDENTITY (1, 1),
    promotion_name VARCHAR (255) NOT NULL,
    discount NUMERIC (3, 2) DEFAULT 0,
    start_date DATE NOT NULL,
);

INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date
) 
OUTPUT inserted.promotion_id,
    inserted.promotion_name,
    inserted.discount--có thể lấy thông tin trả về như này, lấy dữ liệu của inserted
VALUES(
    '2018 Summer Promotio',
    0.15,
    '20180601'
);

--khóa chính tăng tự động thì ta k thể insert thêm mà phải để SQL tự động gán. Ta có thể ép điều này bằng cách tắt->insert->bật
SET IDENTITY_INSERT sales.promotions ON;
INSERT INTO sales.promotions (
    promotion_id,
    promotion_name,
    discount,
    start_date
)
OUTPUT inserted.promotion_id,
    inserted.promotion_name,
    inserted.discount
VALUES( 
	4,
    '2019 Spring Promotion',
    0.25,
    '20190201'
);
SET IDENTITY_INSERT sales.promotions OFF;
DROP TABLE sales.promotions;


-- Câu lệnh SELECT
USE BikeStores;
GO

SELECT
    first_name,
    last_name
FROM
    sales.customers;

SELECT
    *
FROM
    sales.customers
WHERE
    state = 'CA'
    AND
    CITY = 'Encino'
ORDER BY
    first_name ASC;

-- dùng BETWEEN AND
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 1899.00 AND 1999.99
ORDER BY
    list_price DESC;
