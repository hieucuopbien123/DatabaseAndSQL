-- Câu lệnh trigger

-- AFTER trigger
-- Tình huống giả sử ta muốn mỗi khi bảng production.products được insert or delete dữ liệu thì dữ liệu đó sẽ được 
-- lưu lại hết trong 1 bảng mới có tên là production.product_audits => cái này có vai trò như là ghi lại lịch sử vậy
-- bảng production.product_audits có mọi thứ của production.products nhưng thêm 3 trường thể hiện sự update là change_id 
-- là update id nào, updated_at ghi lại thời gian được update và operation là update như thế nào
CREATE TABLE production.product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL') -- INSERT hay DELETE
);
GO

CREATE TRIGGER production.trg_product_audit
ON production.products
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
	-- Khi chạy 1 trigger sẽ trả kết quả là số lượng row bị ảnh hưởng. Ta muốn tắt cái này để trả về 1 cái khác thì
	-- chạy SET NOCOUNT ON để tùy ý ta
    INSERT INTO production.product_audits(
        product_id, 
        product_name,
        brand_id,
        category_id,
        model_year,
        list_price, 
        updated_at, 
        operation
    ) -- Thêm vào bảng các thông tin này và các thông tin này lấy từ bảng inserted
    SELECT
        i.product_id,
        i.product_name,
        brand_id,
        category_id,
        model_year,
        i.list_price,
        GETDATE(), -- Trả ra thời gian gọi lệnh này
        'INS'
    FROM
        inserted i
    UNION ALL-- Vì ta muốn thực hiện gộp cả delete và insert nên làm như này. Khi ta insert thì bảng deleted sẽ là rỗng thì
	-- gọi union hiển nhiên lấy toàn giá trị của bảng inserted nên k sao, ngược lại khi delete
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        GETDATE(),
        'DEL'
    FROM
        deleted AS d;
END
GO

INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'Test product',
    1,
    1,
    2018,
    599
);

DELETE FROM
    production.products
WHERE
    product_id = 332;
GO

SELECT * FROM production.product_audits;
DROP TABLE production.product_audits;
DROP TRIGGER production.trg_product_audit;

-- INSTEAD OF trigger
-- Tình huống: ta muốn thêm 1 thương hiệu mới vào brands nhưng ta cho nó vào brand_approval để được phê duyệt. 
-- Sau khi phê duyệt xong thì sẽ thêm nó vào bảng brands. Quy trình: tạo 1 view mới và khi thêm data vào view sẽ
-- kích hoạt INSTEAD OF trigger chèn vào bảng brand_approval
CREATE TABLE production.brand_approvals(
    brand_id INT IDENTITY PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);
GO
CREATE VIEW production.vw_brands 
AS
SELECT
    brand_name,
    'Approved' approval_status -- mặc định giá trị là Approved cho trường approval_status
FROM
    production.brands
UNION --hợp 2 bảng lại
SELECT
    brand_name,
    'Pending Approval' approval_status
FROM
    production.brand_approvals;
GO
-- View này sẽ lấy data từ 2 bảng và set bảng brands là Approved còn brand_approvals là Pending Approval
-- Tạo trigger để insert vào view là insert vào brand_approvals
CREATE TRIGGER production.trg_vw_brands 
ON production.vw_brands
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO production.brand_approvals ( 
        brand_name
    )
    SELECT
        i.brand_name
    FROM
        inserted i
    WHERE
        i.brand_name NOT IN (
            SELECT
                brand_name
            FROM
                production.brands
        );
	-- Ta lọc 1 brand mới thêm mà k thuộc các brand đã có trong production.brands thì thêm vào brand_approvals
	-- nếu đã có trong brands thì đơn giản chả insert gì cả vì nó NULL
END
GO
--Thêm dữ liệu vào view
INSERT INTO production.vw_brands(brand_name)
VALUES('Eddy Merckx');

--xem các thứ trong view
SELECT brand_name, approval_status FROM production.vw_brands;
--xem các thứ đang pending
SELECT * FROM production.brand_approvals;

DROP TRIGGER production.trg_vw_brands 
DROP VIEW production.vw_brands
DROP TABLE production.brand_approvals
-- Ta có thể làm đơn giản hơn là tạo ra 1 trường mới trong table xác định approved hay chưa approved nhưng ở đây chia 2 bảng để
-- học thôi chứ chả ai làm v cả

-- TRIGGER có ROLLBACK
GO
CREATE TRIGGER TriggerData
ON production.products
AFTER INSERT
AS
BEGIN
    ROLLBACK TRAN -- check j k thỏa mãn thì hoàn tác
	PRINT 'Trigger run'
END
GO
SELECT * FROM production.products
INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'Test product',
    1,
    1,
    2018,
    599
);
DROP TRIGGER TriggerData


-- Câu lệnh transaction
BEGIN TRANSACTION
DELETE production.products WHERE list_price = 599
ROLLBACK -- or ROLLBACK TRAN đều được
-- COMMIT -- là lệnh ngược với ROLLBACK thì COMMIT chắc chắn được gửi đi

DECLARE @trans1 VARCHAR(10) = 'Trans1';
BEGIN TRANSACTION @trans1
DELETE production.products WHERE list_price = 599
COMMIT TRANSACTION @trans1 -- Đặt tên cho transaction để tùy biến COMMIT và ROLLBACK mọi lúc

-- Có thể tạo mốc transaction để quay lại
BEGIN TRANSACTION 

SAVE TRANSACTION Trans1
DELETE production.products WHERE list_price = 599

SAVE TRANSACTION Trans2
DELETE production.products WHERE list_price = 100

ROLLBACK TRANSACTION Trans2
-- Lưu 2 cái lệnh DELETE là 2 transaction Trans1 và Trans2
-- Khi chạy sẽ thực hiện từ trên xuống Trans1 delete 599 và Trans2 delete 100 
-- Sau đó ROLLBACK về Trans2 thì vc xóa 100 sẽ bị undo còn 599 vẫn bị xóa nhưng ROLLBACK Trans1 thì cả 2 cùng bị undo vì 
-- ROLLBACK về 1 trans trước đó sẽ rollback nó cùng với tất cả tran sau nó