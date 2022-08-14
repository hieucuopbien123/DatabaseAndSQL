CREATE DATABASE QLKH
GO
USE QLKH;

CREATE TABLE Lecturers(
  LID char(4) NOT NULL,
  FullName nchar(30) NOT NULL,
  Address nvarchar(50) NOT NULL,
  DOB date NOT NULL,
  CONSTRAINT pkLecturers PRIMARY KEY (LID)
)

CREATE TABLE Projects(
  PID char(4) NOT NULL,
  Title nvarchar(50) NOT NULL,
  Level nchar(12) NOT NULL,
  Cost integer,
  CONSTRAINT pkProjects PRIMARY KEY (PID	)
)

CREATE TABLE Participation(
  LID char(4) NOT NULL,
  PID char(4) NOT NULL,
  Duration smallint,
  CONSTRAINT pkParticipation PRIMARY KEY (LID, PID),
  CONSTRAINT fk1 FOREIGN KEY (LID) REFERENCES Lecturers (LID),
  CONSTRAINT fk2 FOREIGN KEY (PID) REFERENCES Projects (PID) 
)


INSERT INTO Lecturers VALUES
('GV01',N'Vũ Tuyết Trinh',N'Hoàng Mai, Hà Nội','1975/10/10'),
('GV02',N'Nguyễn Nhật Quang',N'Hai Bà Trưng, Hà Nội','1976/11/03'),
('GV03',N'Trần Đức Khánh',N'Đống Đa, Hà Nội','1977/06/04'),
('GV04',N'Nguyễn Hồng Phương',N'Tây Hồ, Hà Nội','1983/12/10'),
('GV05',N'Lê Thanh Hương',N'Hai Bà Trưng, Hà Nội','1976/10/10');


INSERT INTO Projects VALUES 
('DT01',N'Tính toán lưới',N'Nhà nước','700'),
('DT02',N'Phát hiện tri thức',N'Bộ','300'),
('DT03',N'Phân loại văn bản',N'Bộ','270'),
('DT04',N'Dịch tự động Anh Việt',N'Trường','30');


INSERT INTO Participation VALUES 
('GV01','DT01','100'),
('GV01','DT02','80'),
('GV01','DT03','80'),
('GV02','DT01','120'),
('GV02','DT03','140'),
('GV03','DT03','150'),
('GV04','DT04','180')

DROP DATABASE QLKH;

--C1:
SELECT * FROM Lecturers WHERE Address LIKE N'%Hai Bà Trưng%' ORDER BY FullName DESC;

--C2:
SELECT FullName, Address, DOB 
FROM Lecturers as L, Participation as Pa, Projects as Pr
WHERE L.LID = Pa.LID AND Pr.PID = Pa.PID AND Pr.Title = N'Tính toán lưới';

--C3:
--Câu này JOIN 2 lần ở FROM tốt hơn vì đỡ phải viết lại logic JOIN 2 lần ở WHERE
SELECT FullName, Address, DOB 
FROM Lecturers as L, Participation as Pa, Projects as Pr
WHERE (L.LID = Pa.LID AND Pr.PID = Pa.PID AND Pr.Title = N'Tính toán lưới')
OR (L.LID = Pa.LID AND Pr.PID = Pa.PID AND Pr.Title = N'Dịch tự động Anh Việt');

--C4:
--Cách 1:
SELECT * 
FROM Lecturers as L
WHERE ( SELECT COUNT(*) FROM Participation as P WHERE P.LID = L.LID ) >= 2;
--C2: Vc dùng WHERE 2 bảng bằng nhau 1 trương là cách ghép hợp 2 bảng vào với nhau rất hay dùng như dưới
SELECT L.LID, L.FullName, L.Address, L.DOB FROM Lecturers as L, Participation as Pa 
WHERE Pa.LID = L.LID
GROUP BY L.LID, L.FullName, L.Address, L.DOB
HAVING COUNT(*) >= 2;
--C3:
SELECT * FROM Lecturers 
WHERE LID IN(SELECT LID FROM Participation GROUP BY LID HAVING COUNT(LID) > 1);

--C5:
--Do query tìm max nó buộc phải duyệt qua hết 1 lần nên chỉ có thể query lồng
--Kết hợp GROUP BY với COUNT sẽ ra bảng các count
SELECT FullName 
FROM Lecturers as L, Participation as P
WHERE P.LID = L.LID
GROUP BY L.LID, FullName
HAVING COUNT(*) >= ALL(SELECT COUNT(*) FROM Participation as PA GROUP BY PA.LID);

--C6:
SELECT * 
FROM Projects
WHERE Cost = (SELECT MIN(Cost) FROM Projects);

--C7: 
SELECT L.FullName, L.DOB, Pr.Title
FROM Lecturers as L, Participation as Pa, Projects as Pr
WHERE L.LID = Pa.LID AND Pa.PID = Pr.PID AND L.Address LIKE N'%Tây Hồ%';

--C8:
--Nếu trước ngày bnh sẽ phải so sánh từng trường ngày tháng năm
SELECT FullName 
FROM Lecturers L JOIN Participation Pa ON L.LID = Pa.LID
JOIN Projects P ON Pa.PID = P.PID
WHERE YEAR(L.DOB) <= 1980 AND P.Title = N'Phân loại văn bản';

--Câu 9 sai vì giáo viên k participant vào cái nào cx phải có total_duration là 0. Làm như dưới nó mất luon
--C1 left join; C2: coalesce
SELECT L.LID, FullName, SUM(Duration) total_duration
FROM Lecturers L, Participation P
WHERE L.LID = P.LID
GROUP BY L.LID, FullName;
--Cách fix bằng leftjoin thì nó ra NULL thì thêm hàm ISNULL vào là được
SELECT L.LID, FullName, ISNULL(SUM(Duration), 0)
FROM Lecturers L LEFT JOIN Participation P  
ON L.LID = P.LID
GROUP BY L.LID, FullName;

INSERT INTO Lecturers VALUES ('GV06', N'Ngô Tuấn Phong', N'Đống Đa, Hà Nội', '1986/09/08');

UPDATE Lecturers
SET Address = N'Tây Hồ, Hà Nội'
WHERE
	FullName = N'Vũ Tuyết Trinh';

DELETE FROM Participation WHERE LID = 'GV02';
DELETE FROM Lecturers WHERE LID = 'GV02';

BACKUP DATABASE QLKH
TO DISK = 'C:\Users\hieuc\OneDrive\Máy tính\Class\DB Lab\Ex1\backup.bak';

RESTORE DATABASE QLKH FROM DISK = 'D:\SQL\SQL Other\Class\Thực hành Ex1\backup.bak';

--Tạo login, và grant quyền cho login, chứ kp lúc nào cx user
CREATE LOGIN phongnt WITH PASSWORD = 'phong123';
CREATE LOGIN phuongnh WITH PASSWORD = 'phuong123';
GO



