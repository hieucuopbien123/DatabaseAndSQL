-- Câu lệnh SELECT
SELECT
    customer_id,
    YEAR (order_date) order_year, -- Hiển thị YEAR(order_date) dưới dạng 1 column tên là order_year
    COUNT (order_id) order_placed
FROM
    sales.orders
WHERE
    customer_id IN (1, 2) -- Cách dùng: A IN (<list ngăn cách dấu chấm>), BETWEEN AND cũng có
GROUP BY
    customer_id,
    YEAR (order_date)
ORDER BY
    customer_id;
-- VD ở đây ta k thể lấy thêm order_id ra được vì nó gom thành 1 nhóm 2 trường kia thì k biết order_id sẽ lấy giá trị nào
-- Hàm COUNT ở đây khi có GROUP BY sẽ đếm xem 1 group có số lượng bao nhiêu order_id, aggregation function có tác dụng làm gì trong 1 group
-- Cái hiển thị ra là 1 GROUP

--Vấn đề này giống DISTINCT
/*SELECT DISTINCT
    customer_id,
    YEAR (order_date) order_year
FROM
    sales.orders
WHERE
    customer_id IN (1, 2)
ORDER BY
    customer_id;
*/

-- Lệnh GROUP BY này dùng nhiều trong thống kê. VD: có bao nhiêu người sống ở 1 thành phố chẳng hạn
SELECT
    city,
    state,
    COUNT (customer_id) customer_count
FROM
    sales.customers
GROUP BY
    state,
    city
ORDER BY
    city,
    state;

-- Bên dưới sẽ: tạo ra 1 bảng tạm là điểm chung của 2 bảng products và brands. Từ bảng tạm đó nó lọc ra những năm model_year = 2018
-- rồi tiến hành gom những dòng mà có brand_name trùng nhau vào 1 group. Từng group đó sẽ được in ra trong 1 dòng chứa các thông tin
-- nhãn chung của group, min price và max price của từng group, sắp xếp các dòng group theo thứ tự tăng dần brand_name và hiển thị ra 
-- Lưu ý: ta chỉ in được các trường chung cả group chứ k được in ra 1 phần tử trong group mà giá trị khác nhau
SELECT
    brand_name,
    MIN (list_price) min_price,
    MAX (list_price) max_price
FROM
    production.products p
INNER JOIN production.brands b ON b.brand_id = p.brand_id
WHERE
    model_year = 2018
GROUP BY
    brand_name
ORDER BY
    brand_name;

-- dùng HAVING
SELECT
    customer_id,
    YEAR (order_date),
    COUNT (order_id) order_count
FROM
    sales.orders
GROUP BY
    customer_id,
    YEAR (order_date)
HAVING
    COUNT (order_id) >= 2
ORDER BY
    customer_id;
-- Ở đây order là đơn hàng, products là sản phẩm còn order_item là từng sản phẩm trong đơn hàng. Thì ta lấy thông tin các nhóm đơn hàng
-- về chung customer và year, sau đó lấy ra những nhóm có số lượng đơn hàng đặt >= 2

--Có nhiều sản phẩm gom thành từng nhóm mà chung category_id. Ta in ra nhóm sản phẩm có max list_price > 4000 OR min list_price < 500
SELECT
    category_id,
    MAX (list_price) max_list_price,
    MIN (list_price) min_list_price
FROM
    production.products
GROUP BY
    category_id
HAVING
    MAX (list_price) > 4000 OR MIN (list_price) < 500;

--VD: lệnh AVG lấy trung bình => in các thông tin về nhóm sản phẩm có chung category_id mà trong nhóm đó ta lấy trung bình price các
--từng sp của nhóm sẽ cho giá trị trong khoảng 500-1000
SELECT
    category_id,
    AVG (list_price) avg_list_price
FROM
    production.products
GROUP BY
    category_id
HAVING
    AVG (list_price) BETWEEN 500 AND 1000;

--toán tử LIKE tìm chuỗi con có trong chuỗi cha không
Select * From production.products 
WHERE product_name LIKE '%Trek%' -- chứa Trek

Select * From production.products 
WHERE product_name NOT LIKE 'Trek%' -- không bắt đầu bằng Trek

Select * From production.products 
WHERE product_name LIKE '_[A,B]C' -- bắt đầu là 1 ký tư bất kỳ + 1 ký tự A hoặc B + 1 ký tự C