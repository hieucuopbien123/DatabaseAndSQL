-- Basic/Các câu lệnh cơ bản

SELECT ISNULL('freetuts.net', 'myfreetuts.net'); -- Nếu 1 là NULL trả ra 2, nếu 1 khác NULL sẽ trả ra 1

SELECT ISNUMERIC('1234'); -- Số k hợp lệ sẽ ra 0
SELECT ISNUMERIC(1234);
SELECT ISDATE('2019-04-06 10:03:32.001'); -- Ngày k hợp lệ sẽ ra 0

SELECT USER_NAME();
SELECT SYSTEM_USER; -- Tên đăng nhập người dùng hiện tại
SELECT SESSION_USER;
SELECT CURRENT_USER; -- Tên người dùng hiện tại

SELECT COALESCE(NULL, NULL, 'freetuts.net', NULL, 'Myfreetuts.net'); 
-- Ra biểu thức k NULL đầu tiên trong danh sách. Tất cả là NULL thì COALESCE sẽ trả NULL

SELECT
CASE -- Điều kiện được đánh giá theo thứ tự liệt kê. Nếu 1 cái when đúng sẽ k check tiếp điều kiện nx
  WHEN list_price < 1000 THEN 'duoi kha'
  WHEN list_price = 1000 THEN 'kha'
  WHEN list_price > 1000 THEN 'tren kha'
  ELSE 'error' -- Nếu tất cả bị bỏ qua và k chạy cả ELSE thì sẽ trả NULL. Có thể k khai báo ELSE
END
FROM production.products;

SELECT SQRT(9)

SELECT TRY_CONVERT(varchar, 15.6); -- Thất bại ra NULL
SELECT TRY_CAST('14 Main St.' AS float); -- Thất bại trả ra NULL
SELECT CONVERT(float, '15.6'); -- Thất bại trả ra error
SELECT CAST('2019-04-06' AS datetime); -- Cast dữ liệu trong SQL, thất bại sẽ trả ra error
--SELECT CAST(15.6 AS varchar(2));
SELECT CAST(15.6 AS varchar);

SELECT YEAR('2018/04/06 15:05'); -- Chỉ ra năm. thất bại sẽ trả lỗi
SELECT MONTH('2019/04/06'); -- Chỉ ra tháng
SELECT DAY('2019/04/15 15:45'); -- Chỉ ra ngày
SELECT DATEPART(year, '2019/04/06'); -- Trả về 1 phần của 1 ngày nhất định dạng nguyên
SELECT DATENAME(millisecond, '2019/04/06 08:45:12.726'); -- 1 phần của ngày dạng chuỗi

SELECT DATEDIFF(minute, '2019/04/06 05:00', '2019/01/25 15:45'); -- 2 ngày chênh nhau 1 khoảng -101595 phút

SELECT DATEADD(year, 3, '2019/04/06'); -- 1 là đơn vị, 2 là số lượng, 3 là thêm vào ngày nào. Có thể thêm khá tự do như
-- yy, yyyy, year đều được, quater/q/qq là thêm theo đơn vị quý
SELECT DATEADD(day, -5, '2019/04/06'); -- dy,y đều được

SELECT GETUTCDATE(); -- Như nhau
SELECT GETDATE();
SELECT CURRENT_TIMESTAMP; -- Ngày giờ hệ thống theo định dạng

SELECT SUM(list_price) AS "SUM"
FROM production.products

SELECT SIGN(-20);
SELECT SIGN(0);

SELECT RAND(); -- K có seed sẽ trả ra hoàn toàn random, có seed sẽ trả về 1 chuỗi các số ngẫu nhiên lặp lại với seed đó
SELECT RAND(6);

SELECT CEILING(32.65); -- FLOOR và ROUND nữa

SELECT MAX(list_price) AS "Gia Cao Nhat" -- MIN nx
FROM production.products;

SELECT COUNT(*) AS "So luong product 2018"
FROM production.products
WHERE upper(model_year) = upper('2018');

SELECT AVG(list_price) AS "Gia Trung Binh"
FROM production.products
WHERE upper(model_year) = upper('2018'); 
-- Upper nhận string nhưng model_year tư chuyển sang string. Với các kiểu basic nó sẽ tự động cast nọ kia

-- Các hàm này cũng phối hợp được với distinct như:
SELECT AVG(DISTINCT list_price) AS "Gia Trung Binh" FROM production.products

SELECT ABS(24.65 * -1);

SELECT STUFF('Freetuts.net', 5, 4, 'tutorial'); -- Hàm rất mạnh thao tác với chuỗi

SELECT SUBSTRING('Freetuts.net', 10, 3); -- Vị trí bắt đầu lấy và số lượng. Số âm sẽ lỗi

SELECT STR(-123.5, 5, 1); -- Chuyển số thành chuỗi, 2 là length k bắt buộc độ dài bao gồm cả dấu và chữ số thập phân, mặc định
-- là 10; 3 là số lượng vị trí thập phân hiển thị ở chuỗi kết quả, k đc quá 16, nếu k chỉ định sẽ là 0. VD ở đây ta có số dài
-- hơn 5 ký tự -12345.5 sẽ sai hay 5 ký tự -1234.5 sẽ tự làm tròn bỏ phần thập phân

SELECT SPACE(10);

SELECT REPLACE('Freet123ut123 s.net', 't123', 't'); -- Thế toàn bộ

SELECT PATINDEX('%e%net', 'Freetuts.net'); -- Ra 3 vì gặp chữ e đầu tiên, nó tính theo cái chữ e cơ trả vị trí mẫu trong chuỗi. 
-- % khớp chuỗi dài bất kỳ kể cả 0; _ là 1 ký tự; [abe] sẽ khớp a hoặc b hoặc e; [^abr] khớp mọi ký tự khác a,b,r

SELECT LTRIM('   Freetuts.net   '); -- bỏ khoảng trắng bên trái chuỗi. Ngược lại RTRIM

SELECT LOWER('FreeTuts.NET'); -- Ngược lại là UPPER

SELECT LEFT('Freetuts.net', 100); -- 100 ký tự từ 1, tràn tự động co đúng. Ngược lại là RIGHT
SELECT LEN(' ');
SELECT LEN(NULL);

SELECT DATALENGTH(NULL);
SELECT DATALENGTH(' H ');

SELECT LEN(' H '); -- k tính khoảng trắng ở cuối

SELECT 'Freetus' + '.net';

SELECT CONCAT('Hello ', 'World', '!!');

SELECT CHARINDEX('t', 'Fretust', 4); -- start position k bắt buộc mặc định là 1, bắt đầu từ 1, k có trả 0

SELECT CHAR(70);
SELECT NCHAR(70); -- hệt nhau

SELECT ASCII('A');
SELECT ASCII('ABC'); -- nó chỉ tính ký tự đầu


