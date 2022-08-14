-- Basic/Các lệnh cơ bản

-- Trả ra các tính năng có được bật k. 
SELECT SESSIONPROPERTY('ANSI_NULLS'); -- Tuân thủ SQL-92 của các giá trị NULL
SELECT SESSIONPROPERTY('ANSI_PADDING'); -- Phần đệm và khoảng trống trong việc lưu trữ các cột ký tự và cột nhị phân
SELECT SESSIONPROPERTY('ANSI_WARNINGS'); -- Các cảnh báo và thông báo lỗi
SELECT SESSIONPROPERTY('ARITHABORT'); -- Hủy truy vấn khi có lỗi tràn và chia
SELECT SESSIONPROPERTY('CONCAT_NULL_YIELDS_NULL'); -- Các kết quả nối là NUL được coi là NULL thay vì các empty string
SELECT SESSIONPROPERTY('NUMERIC_ROUNDABORT'); -- Cảnh báo và lỗi khi làm tròn gây mất độ chính xác
SELECT SESSIONPROPERTY('QUOTED_IDENTIFIER'); -- Dấu ngoặc kép phân định chuỗi ký tự và mã định danh

SELECT NULLIF('freetuts.net', 'freetuts.net'); -- Trả về NULL if 1 = 2, nếu k sẽ trả về expression1

-- Lệnh LAG và LEAD
SELECT product_id, product_name, list_price,
LAG (list_price, 1) OVER (ORDER BY list_price) AS lower_1_level_price
FROM production.products;
-- Trong bảng production.products sẽ lấy ra 3 thuộc tính product_id, product_name, list_price còn thuộc tính thứ 4 là 
-- lower_1_level_price sẽ lấy bằng cách sắp xếp tập dữ liệu theo list_price tăng dần và lấy cột list_price lag ngược về 1 giá
-- trị. VD: list price tăng dần chỉ là 3,4,6 thì lower_1_level_price sẽ là NULL,3,4. VD row 3 mang giá trị row 2 ở trường đó

-- LAG ( expression [, offset [, default] ] ) OVER ( [ query_partition_clause ] order_by_clause ) sửa đổi 1 trường định lấy
-- thành cái gì -> lấy trường expression lag về 1 lượng offset(default là 1), nếu ngoài phạm vi sẽ lấy giá trị default(mặc định
-- là NULL), sẽ PARTITION BY nếu có và ORDER BY cái gì bên ngoài

SELECT product_id, product_name, list_price, model_year,
LAG (list_price, 2, NULL) OVER (PARTITION BY model_year ORDER BY list_price DESC) AS lower_2_level_price
FROM production.products;
-- Lấy 4 trường ban đầu từ production.products, sau đó lấy trường cuối lower_2_level_price bằng cách chia nó thành các nhóm
-- theo model_year, trong mỗi nhóm sắp xếp theo list_price giảm dần(nó cũng khiến data trên bảng hiển thị ra sẽ tự chia nhóm
-- theo model_year và hiển thị list_price giảm dần) và lấy lag lại 2 đơn vị trong từng nhóm tức đang sắp xếp giảm dần thì tại
-- 1 vị trí nào đó sẽ lấy lùi lại 2 item là lớn hơn giá trị 2 hiện tại. VD: 5,4,3,2 sẽ lấy NULL,NULL,5,4 

-- Ngược lại với LEAD là lấy tiến lên bao nhiêu giá trị
SELECT product_id, product_name, list_price, model_year,
LEAD (list_price,2,NULL) OVER (PARTITION BY model_year ORDER BY list_price DESC) AS lower_2_level_price
FROM production.products;
-- Xếp list_price giảm dần xong lấy tiến 2 giá trị bên trên. Tức 5,4,3,2 sẽ lấy 3,2,NULL,NULL
