-- Câu lệnh SELECT
CREATE DATABASE TEST;

-- Test các loại JOIN
/*
DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
CREATE TABLE B(
    idB INT PRIMARY KEY,
);
CREATE TABLE A(
	idA INT,
	idB INT,
	FOREIGN KEY(idB) REFERENCES B(idB) ON UPDATE CASCADE ON DELETE CASCADE
)

INSERT INTO B (idB) VALUES (1),(2),(3),(4);

INSERT INTO A(idA, idB) VALUES(101, 2),(102, 2),(103, 3);

SELECT * 
FROM B b LEFT JOIN A a ON a.idB = b.idB

SELECT * 
FROM B b RIGHT JOIN A a ON a.idB = b.idB

SELECT * 
FROM B b JOIN A a ON a.idB = b.idB

SELECT * 
FROM B b FULL OUTER JOIN A a ON a.idB = b.idB

SELECT * 
FROM B b CROSS JOIN A a

SELECT * 
FROM B, A

SELECT * 
FROM B b, A a
WHERE b.idB = A.idB
*/

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;

CREATE TABLE B(
    idB INT PRIMARY KEY,
);
CREATE TABLE C(
    idC INT PRIMARY KEY,
);
CREATE TABLE A(
	idB INT,
	idC INT,
	FOREIGN KEY(idB) REFERENCES B(idB) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(idC) REFERENCES C(idC) ON UPDATE CASCADE ON DELETE CASCADE
)

INSERT INTO B (idB) VALUES (1),(2),(3);
INSERT INTO C (idC) VALUES (101),(102),(103);
INSERT INTO A (idB, idC) VALUES (1, 101),(1, 102),(1,103),(2,101),(2,103),(3,101);


-- Tìm mọi idB mà có tất cả idC: many - to - many
-- Hướng: nhóm từng nhóm trong A thành các nhóm có idB phân biệt với GROUP BY, trong từng nhóm ta check xem mọi idC 
-- thì đều có trong nhóm hay k. Nếu mọi idC đều có trong nhóm thì ta lấy cái giá trị idB đó
-- Nhưng khi chia thành từng nhóm với GROUP BY thì ta k thao tác được với các phần tử trong nhóm => bỏ

-- Dùng nested query, từ bảng A lấy ra các idB thỏa mãn điều kiện: từ bảng A lọc ra các idB trùng, left join nó với
-- bảng C. Khi này ta sẽ được 1 bảng có các giá trị idB trùng với idB cần check bên ngoài + các giá trị idB có thể 
-- NULL -> lấy ra các giá trị NULL, nếu tồn tại giá trị NULL thì k bao hết nên k lấy
SELECT DISTINCT idB 
FROM A as x
WHERE NOT EXISTS(
	SELECT idB
	FROM C c LEFT JOIN(
		SELECT *
		FROM A
		WHERE a.idB = x.idB
	) y ON c.idC = y.idC
	WHERE idB IS NULL
)

-- Dùng ANY
SELECT idC
FROM A
WHERE idB = ANY (SELECT idB FROM B)
-- Ở đây = ANY nó cũng như IN vậy, cách dùng ALL cũng giống ANY

DROP DATABASE IF EXISTS TEST;

DECLARE @d DATETIME = '12/01/2018';
SELECT FORMAT (@d, 'd', 'en-US') AS 'US English Result',
        FORMAT (@d, 'd', 'no') AS 'Norwegian Result',
       	FORMAT (@d, 'd', 'zu') AS 'Zulu Result';
-- 1 là in giá trị nào, 2 là format, 3 là vùng miền optional. Đối số 2 là cái mẹ gì format cứ học gì hiểu nấy là được
SELECT FORMAT(123456789, '##-##-#####');
