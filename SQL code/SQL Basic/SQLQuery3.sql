-- Câu lệnh table/contraints thường dùng

-- Tạo foreign key bằng constraint.
-- Cách 1 bình thường
CREATE SCHEMA procurement;
go
CREATE TABLE procurement.vendor_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (100) NOT NULL
);
CREATE TABLE procurement.vendors (
    vendor_id INT IDENTITY PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    group_id INT NOT NULL,
    CONSTRAINT fk_group FOREIGN KEY (group_id) -- Tên foreign key là fk_group. 
    REFERENCES procurement.vendor_groups(group_id)
);
-- Có thể có nhiều trường gom lại thành 1 foreign key như sau:
-- CONSTRAINT fk_constraint_name FOREIGN KEY (column_1, column2,...) REFERENCES parent_table_name(column1,column2,..)

-- Cách 2 tạo foreign key bằng constraint là dùng ALTER TABLE. Mỗi lần chỉnh sửa phải gọi lại ALTER TABLE
ALTER TABLE procurement.vendors 
DROP CONSTRAINT fk_group;

ALTER TABLE procurement.vendors 
ADD CONSTRAINT fk_group
FOREIGN KEY (group_id) REFERENCES procurement.vendor_groups(group_id)

ALTER TABLE procurement.vendors
ADD 
	description VARCHAR(255),
	summary VARCHAR (50) NULL

-- Để xóa table cha có con chứa FOREIGN KEY trỏ tới:
-- C1 là xóa table con trước r xóa cha bằng cách đặt con trước cha.
-- C2 là xóa foreign key của con r xóa được cha(tức k cần xóa hẳn table con). VD:
-- ALTER TABLE procurement.vendors 
-- DROP CONSTRAINT fk_group;
-- DROP TABLE procurement.vendor_groups;
-- C3: dùng ON DELETE CASCADE or thêm nó ở con

-- Có option IF EXISTS để tránh báo lỗi và [database_name.][schema_name.]table_name; tức 2 cái kia nếu k truyền sẽ dùng mặc định
DROP TABLE IF EXISTS BikeStores.procurement.vendors, procurement.vendor_groups;


-- Câu lệnh table
-- Khi chuyển đổi kiểu dữ liệu với ALTER COLUMN thì các giá trị bên trong phải tương thích mới được
DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (c INT NULL, d INT NULL DEFAULT 0);
INSERT INTO t1 
	VALUES (1, 0),(2, 0),(3, 0); -- éo hiểu sao default vẫn phải truyền, nếu k sẽ báo lỗi. Chắc vì đây là insert nhiều giá trị
ALTER TABLE t1 ALTER COLUMN c VARCHAR(2); -- ok
INSERT INTO t1 VALUES ('@', 0);
-- ALTER TABLE t1 ALTER COLUMN c INT; -- lỗi vì k cast @ về int được nhưng cast string '1' '2' '3' về varchar(2) được

-- TH đổi từ NULL sang NOT NULL thì phải cập nhập tất cả các dòng sao cho nó từ NULL thành rỗng trước khi thay đổi
UPDATE t1 SET c = '' WHERE c IS NULL;
ALTER TABLE t1 ALTER COLUMN c VARCHAR (20) NOT NULL;
ALTER TABLE t1 DROP COLUMN c;
DROP TABLE t1;

--khi xóa 1 column có constraint thì phải DROP CONSTRAINT trước r mới DROP COLUMN
CREATE TABLE sales.price_lists(
    valid_from DATE,
    price DEC(10,2) NOT NULL CONSTRAINT ck_positive_price CHECK(price >= 0),
    note VARCHAR(255),
);
ALTER TABLE sales.price_lists
DROP CONSTRAINT ck_positive_price;
ALTER TABLE sales.price_lists
DROP COLUMN price, valid_from;
-- Xóa column mà là primary key or foreign key thì báo lỗi ngay nên foreign key phải rời sang trường khác trc r ms xóa(ràng buộc toàn vẹn)


-- Basic/Câu lệnh hệ thống
/* SQL Server k cung cấp câu lệnh đổi tên table nhưng có 1 thủ tục lưu trữ global là sp_rename có thể dùng để đổi tên bảng
bằng cách exec thủ tục đó. Tên cũ và mới đều phải đặt trong dấu nháy đơn */
EXEC sp_rename 'sales.price_lists', 'price_groups'
-- Chú ý old_name có schema, còn new_name k có schema vì mặc định chơi trong schema kia
-- Vc đổi tên sẽ ảnh hưởng đến khóa ngoại của các table khác trỏ đến table này nhưng SQL Server tự động cập nhập nên kp lo
-- Ta cx có thể đổi tên bằng giao diện righclick table được 


-- Câu lệnh table
TRUNCATE TABLE sales.price_groups;
DROP TABLE sales.price_groups;

-- Câu lệnh table/constraints thường dùng
-- dùng constraint UNIQUE
CREATE TABLE persons(
    person_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
	birth DATE,
    -- email VARCHAR(255) UNIQUE,//dùng TT
    -- UNIQUE(email)//dùng ở cuối, thêm phẩy nếu có nhiều trường
	-- Có thể dùng column có UNIQUE như primary key nhưng k hay nên họ chỉ đặt là UNIQUE
	-- Tạo như trên thì SQL tự đặt tên cho UNIQUE 1 cái tên rất dài. Ta dùng constraint có thể tự đặt tên
	email VARCHAR(255),
	CONSTRAINT unique_email UNIQUE(email)
);
INSERT INTO persons(first_name, last_name)
VALUES('John', 'Handsome');
INSERT INTO persons(first_name, email)
VALUES('Jane','j.doe@bike.stores');

-- Có thể thêm unique bằng constraint or thêm tt
ALTER TABLE persons
ADD CONSTRAINT add_unique UNIQUE(first_name, birth)
ALTER TABLE persons
ADD CONSTRAINT lastname_unique UNIQUE(last_name)

-- Do UNIQUE cũng chỉ là 1 CONSTRAINT nên có thể xóa được bằng cách xóa constraint
ALTER TABLE persons
DROP CONSTRAINT add_unique;
DROP TABLE persons;
