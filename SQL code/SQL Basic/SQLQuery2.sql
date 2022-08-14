-- Câu lệnh Schema
CREATE SCHEMA news;
go
CREATE SCHEMA syst;
go
DROP SCHEMA syst;
CREATE SCHEMA test;
go


-- Phân quyền
-- Cú pháp: GRANT <list các quyền bằng dấu phẩy> ON <thành phần của database> TO <user> [WITH GRANT OPTION]
-- Trao quyền trong toàn bộ schema(1 tập hơp table). Khi dùng schema thì phải có ::
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: news TO hieu
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: news TO hieu;
-- Có các quyền là SELECT,INSERT,DELETE,UPDATE,REFERENCES(quyền trong 1 relation),USAGE,TRIGGER,EXECUTE,UNDER(right to create subtype)

-- Trao quyền 1 bảng cụ thể
GRANT ALL ON sales.contacts TO hieu WITH GRANT OPTION;
-- ALL là tất cả quyền, WITH GRANT OPTION là quyền cho phép trao quyền cho người khác nx

-- Cú pháp thu quyền: REVOKE <privilege list> ON <database element> FROM <user list> [CASCADE| RESTRICT] ;
REVOKE ALL ON sales.contacts FROM hieu CASCADE;
-- Với CASCADE là xóa bỏ mọi quyền được granted chỉ vì revoked privileges. Còn RESTRICT là revoke sẽ k thực thiện nếu quyền
-- revoked được trao cho những người khác r, kiểu báo lỗi sai ấy

-- Để revoke grant option phải dùng riêng
REVOKE GRANT OPTION FOR SELECT ON sales.contacts FROM hieu CASCADE;

CREATE USER user_name FOR LOGIN hieu;
DROP USER IF EXISTS user_name  

--lệnh tạo login mới có password, chứ user làm gi có password nx. Xong từ đây bên dưới có thể tạo tiếp user từ login này
CREATE LOGIN NewAdminName WITH PASSWORD = 'ABCD'
GO
DROP LOGIN NewAdminName

-- Có thể gán nhiều user cho 1 role, chỉnh sửa quyền role đó là mọi user được chỉnh
CREATE ROLE testing AUTHORIZATION hieu;  
GO  
GRANT CREATE TABLE TO testing; -- Nhiều quyền lắm, tùy chỉnh quyền thực hiện lệnh nào
REVOKE CREATE TABLE FROM testing;
ALTER ROLE testing ADD MEMBER guest;  
GO  
ALTER ROLE testing DROP MEMBER guest; -- phải DROP User khỏi role (chỉ còn nhiều nhất 1 user) rồi mới xóa role đó được
GO
DROP ROLE testing 

DROP SCHEMA news;


-- Basic/Các câu lệnh cơ bản
-- Nếu k nói rõ database thì nó dùng database mặc định hiển thị ở góc trái trên của phần mềm. Có thể chỉnh ở đó or dùng use + go
use BikeStores;
go


-- Câu lệnh table
CREATE TABLE SINHVIEN(
    MASINHVIEN INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    TENSINHVIEN NVARCHAR(200) NOT NULL,
    MAKHOA INT NOT NULL FOREIGN KEY REFERENCES sales.stores(store_id),
    NAMSINH INT NULL DEFAULT 0, -- DEFAULT thường đi với NULL, DEFAULT k được đi với UNIQUE
    gender CHAR(1) NOT NULL
);

INSERT INTO SINHVIEN(TENSINHVIEN, MAKHOA, NAMSINH, gender)
OUTPUT inserted.MASINHVIEN
VALUES('John', 1, 2, 'M');

INSERT INTO SINHVIEN(TENSINHVIEN, MAKHOA, NAMSINH, gender)
OUTPUT inserted.MASINHVIEN
VALUES('Jane', 1, 2,'F');

CREATE TABLE sales.visits (
    visit_id INT PRIMARY KEY IDENTITY,
    visited_at DATETIME,
    phone VARCHAR(20),
    store_id INT NOT NULL,
    FOREIGN KEY(store_id) REFERENCES sales.stores(store_id) ON UPDATE CASCADE ON DELETE CASCADE
	-- constraints foreign key thì cú pháp thêm 1 cái ngoặc ở giữa thôi
);
DROP TABLE SINHVIEN, sales.visits

CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
	discounted_price DEC(10,2) CHECK(discounted_price > 0),

	-- Nên đặt tên cho CHECK để dễ quản lý như dưới. Chú ý vẫn chấp nhận giá trị NULL vì SQL coi NULL > 0 và 0 khác nhau
    unit_price DEC(10,2) CONSTRAINT positive_price CHECK(unit_price > 0),

	CHECK (discounted_price < 10000000 AND discounted_price > unit_price)
	-- Tạo CHECK ở cuối sẽ kết hợp check được nhiều trường, dùng được AND hoặc OR
);

-- Thêm 1 column mới và trong lúc đó ta thêm check vào luôn vì nó cx chỉ là 1 option của column, k đặt tên
ALTER TABLE test.products
ADD price1 DEC(10,2)
CHECK(price1 > 0)

-- Dùng ALTER TABLE ADD CONSTRAINT
ALTER TABLE test.products
ADD CONSTRAINT valid_price
CHECK(discounted_price > unit_price)

--Có thể xóa constraint bằng cách DROP CONSTRAINT như bth or tạm thời vô hiệu hóa mà k xóa nó với: 
ALTER TABLE test.products
NOCHECK CONSTRAINT valid_price

DROP TABLE test.products;
DROP SCHEMA test;