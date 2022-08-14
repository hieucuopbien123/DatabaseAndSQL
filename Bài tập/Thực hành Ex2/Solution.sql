SELECT * 
FROM Company
WHERE Address LIKE '%London%'

SELECT name, color, price
FROM Product 
WHERE color = 'black' AND price > 5000

SELECT C.name, C.telephone
FROM Company as C, Product as P, Supply as S
WHERE C.CompanyID = S.CompanyID AND S.ProductID = P.ProductID AND P.color = 'red'

--C4 sai
SELECT C.name, C.telephone
FROM Company as C, Product as P, Supply as S
WHERE C.CompanyID = S.CompanyID AND S.ProductID = P.ProductID AND ( P.color = 'blue' OR P.color= 'black')
--C4 chữa
SELECT X.name, X.telephone
FROM Company as X
WHERE EXISTS(
	SELECT *
	FROM Company as C, Product as P, Supply as S
	WHERE C.CompanyID = S.CompanyID AND S.ProductID = P.ProductID
	AND C.CompanyID = X.CompanyID AND P.color = 'red'
) AND EXISTS(
	SELECT *
	FROM Company as C, Product as P, Supply as S
	WHERE C.CompanyID = S.CompanyID AND S.ProductID = P.ProductID
	AND C.CompanyID = X.CompanyID AND P.color='yellow'
)

--C5:
SELECT name
FROM Product
WHERE Price = (SELECT MAX(Price) FROM Product)

SELECT C.CompanyID
FROM Company as C, Supply as S
WHERE C.CompanyID = S.CompanyID
GROUP BY C.CompanyID
HAVING COUNT(*) >= 2

--C7 làm cả 2 TH công ty toàn sản phẩm brown và product có 3 sp brown thì công ty đó phải có cả 3. TH2 thì dùng count tất cả số lượng sp màu
--vàng của công ty 1 = số lượng sp màu vàng của bảng product. Luôn có 2 cách so sánh COUNT(khi bảng data info có mọi phần tử) và nested query
--Sửa đề: câu 7 thành kiểu công ty có toàn sản phẩm màu vàng
SELECT C.name
FROM Company as C
WHERE NOT EXISTS(
	SELECT *
	FROM Company as X, Supply as Y, Product as Z
	WHERE X.CompanyID = Y.CompanyID AND Y.ProductID = Z.ProductID
	AND X.CompanyID = C.CompanyID AND Z.color != 'yellow'
) AND (
	SELECT COUNT(*)
	FROM Company as X, Supply as Y, Product as Z
	WHERE X.CompanyID = Y.CompanyID AND Y.ProductID = Z.ProductID AND X.CompanyID = C.CompanyID
) > 0
--Cách Tuấn:
SELECT Name FROM Company
WHERE CompanyID IN(
	SELECT CompanyID FROM Supply JOIN Product
	ON Supply.ProductID = Product.ProductID
	WHERE Color = 'brown'
	EXCEPT
	SELECT CompanyID FROM Supply JOIN Product
	ON Supply.ProductID = Product.ProductID
	WHERE Color != 'brown'
)
--Cách Tuấn thầy
SELECT Name FROM Company
WHERE CompanyID IN(
	SELECT CompanyID FROM Supply JOIN Product
	ON Supply.ProductID = Product.ProductID
	WHERE Color = 'brown')
	AND CompanyID NOT IN(
	SELECT CompanyID FROM Supply JOIN Product
	ON Supply.ProductID = Product.ProductID
	WHERE Color != 'brown')
--TH2:
SELECT Name FROM Company
WHERE CompanyID IN(
	SELECT CompanyID FROM Supply JOIN Product
	ON Supply.ProductID = Product.ProductID
	WHERE Color = 'yellow'
	GROUP BY CompanyID
	HAVING COUNT(*) = (SELECT COUNT(*) FROM Product WHERE Color = 'yellow')
)


--chia ra ta lấy từng cái 1. Vc lấy cả tất cả thông tin từ cả 3 bảng là k tốt mà nên giảm trừ đi các data lấy được như bài trên
--C8 sai
SELECT C.name
FROM Company as C
WHERE (
	SELECT COUNT(*)
	FROM Company as X, Supply as Y
	WHERE X.CompanyID = Y.CompanyID AND X.CompanyID = C.CompanyID
) >= ALL(
	SELECT COUNT(*)
	FROM Company as X, Supply as Y
	WHERE X.CompanyID = Y.CompanyID
	GROUP BY X.CompanyID
)

--Câu 8: làm cả delivery nhiều loại product or nhiều số lượng product thì phải cộng cả quantity
SELECT C.name
FROM Company as C
WHERE (
	SELECT SUM(Y.Quantity)
	FROM Company as X, Supply as Y
	WHERE X.CompanyID = Y.CompanyID AND C.CompanyID = X.CompanyID
) >= ALL(
	SELECT SUM(Y.Quantity) --Ta có thể thao tác với cả cụm với các hàm của SQL ở SELECT chứ k chỉ là lấy ra các thứ chung trong GROUP BY
	FROM Company as X, Supply as Y
	WHERE X.CompanyID = Y.CompanyID
	GROUP BY X.CompanyID
)

--Cách 2 cho Th1 của bài 8:
--SELECT FROM WHERE IN dùng hay
SELECT Name FROM Company
WHERE CompanyID IN (SELECT CompanyID FROM Supply 
					GROUP BY CompanyID
					HAVING COUNT(ProductID)>= ALL (SELECT COUNT(ProductID)
													FROM Supply GROUP BY CompanyID
													)
					)

--Câu 9:
SELECT C.Name, AVG(Quantity)
FROM Company C, Supply S
WHERE C.CompanyID = S.CompanyID
GROUP BY C.Name
ORDER BY AVG(Quantity) DESC

--Câu 10:
SELECT * INTO Product2 FROM Product

--Câu 11:
UPDATE Company SET Address = 'Hanoi, Vietnam'
WHERE CompanyID = 1

--Câu 12:
DELETE FROM Supply WHERE CompanyID = 14
DELETE FROM Company WHERE CompanyID = 14

--Câu 13:
BACKUP DATABASE QLKH
TO DISK = 'C:\Test.bak';

