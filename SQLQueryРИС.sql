CREATE DATABASE Book_library; 
USE Book_library;
GO

CREATE TABLE Book (
ID_book int PRIMARY KEY IDENTITY ,
Book_price int NULL,
Book_author varchar(50) NULL,
Book_publication_year datetime NOT NULL,
Numbers_of_book_on_hand int NULL,
Title_of_the_book varchar(50) NULL,
Quantity_of_the_book_in_the_libriary int NULL,
Quantity_day_of_delay int NULL,
Book_usage_period int NULL
); 

CREATE TABLE Ganry (
ID_genre int  PRIMARY KEY IDENTITY,
genre_naming Varchar(30) NOT NULL
); 

CREATE TABLE Connection(
ID_book int NOT NULL REFERENCES Ganry(ID_genre),
ID_genre int NOT NULL REFERENCES Book(ID_book)
);

CREATE TABLE Student(
ID_student Int PRIMARY KEY IDENTITY,
Name_of_student	Varchar(50)	Not null,
Number_of_phone_student	Int	Not null,
Number_of_student_book	Int	Not null,
Home_adress	Varchar(70)	Not null,
Date_of_birthday	Date	Not null
);

CREATE TABLE Employee(
ID_Employee	Int PRIMARY KEY IDENTITY	Not null,
Name_of_Employee	Varchar(50)	Not null,
Date_of_bd_Employee	Date	Not null,
Adress_of_Employee	Varchar(70)	Not null,
Number_phone_of_Employee	Int	Not null,
Password_of_user Varchar(8) UNIQUE CHECK(Password_of_user !='')
);

CREATE TABLE NumberBook(
ID_copy_book	Int PRIMARY KEY	IDENTITY Not null,
Issue_date_of_the_book	Date	Not null,
Book_return_date	Date	Not null,
The_shelf_where_the_book_is	Varchar(70)	Not null,
Book_write_off_date	Date	Not null,
ID_book int Not null REFERENCES Book(ID_book),
ID_student int Not null REFERENCES Student(ID_student),
ID_Employee int Not null REFERENCES Employee(ID_Employee)
);


--Создание логина для входа на сервер
CREATE LOGIN Boss WITH PASSWORD = '123';

--Создание пользователя для созданного логина
CREATE USER Boss FOR LOGIN Boss;

--Добавление привелегий пользователю выбирать все атрибуты отношения
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.Book TO Boss;
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.Connection TO Boss;
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.Employee TO Boss;
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.Student TO Boss;
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.Ganry TO Boss;
GRANT SELECT,INSERT,UPDATE,DELETE ON Book_library.dbo.NumberBook TO Boss;

--Создание логина для входа на сервер
CREATE LOGIN Stag WITH PASSWORD = '1234';

--Создание пользователя для созданного логина
CREATE USER Stag FOR LOGIN Stag;

--Добавление привелегий пользователю выбирать все атрибуты отношения
GRANT SELECT ON Book_library.dbo.Book TO Stag;
GRANT SELECT ON Book_library.dbo.Connection TO Stag;
GRANT SELECT ON Book_library.dbo.Employee TO Stag;
GRANT SELECT ON Book_library.dbo.Student TO Stag;
GRANT SELECT ON Book_library.dbo.Ganry TO Stag;
GRANT SELECT ON Book_library.dbo.NumberBook TO Stag;

--статистика для просмотра времени транзакции
set statistics io on
set statistics time on 

use Book_library;
GO

SELECT Student.Name_of_student
FROM Student join NumberBook ON Student.ID_student=NumberBook.ID_student 
join Book ON Book.ID_book = NumberBook.ID_book;

--Удаление индекса
DROP INDEX Student.IX_Name_of_student;
--Создание индекса
CREATE index IX_Name_of_student on Student (Name_of_student);


SELECT * FROM Student where Name_of_student = 'Булдаков Джамал Маликович';

EXEC sp_enum_oledb_providers;
--Запрос к удаленному пользователю
SELECT *
FROM OPENQUERY(POSTGRESQL, 'select * from ganry');

USE Book_library;
--Распределенный запрос
SELECT Book.Book_author FROM Book
WHERE Book_author NOT IN (SELECT * FROM OPENQUERY(POSTGRESQL, 'select Book_author from book'));
--Распределенный вопрос
SELECT * FROM Book
WHERE Book_author IN (SELECT * FROM OPENQUERY(POSTGRESQL, 'select Book_author from book'));
--Рапределенный вопрос который обьединяет таблицы
SELECT * FROM Book UNION SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from book');
--Создание синонимов
CREATE SYNONYM synonymbook FOR [POSTGRESQL].[usersdb].[public].[book];
CREATE SYNONYM synonymconnection FOR [POSTGRESQL].[usersdb].[public].[connection];
CREATE SYNONYM synonymganry FOR [POSTGRESQL].[usersdb].[public].[ganry];
CREATE SYNONYM synonymnumberbook FOR [POSTGRESQL].[usersdb].[public].[numberbook];
--Используем синоним
SELECT * FROM Book
SELECT * FROM synonymbook;
SELECT * FROM synonymbook WHERE title_of_the_book = 'Капитанская дочка';


USE Book_library;
Go
SELECT * FROM Book UNION SELECT * FROM synonymbook;

SELECT * FROM synonymbook WHERE Title_of_the_book = 'Капитанская дочка';

INSERT INTO Book (Book_price ,Book_author ,Book_publication_year ,Numbers_of_book_on_hand ,Title_of_the_book,Quantity_of_the_book_in_the_libriary,Quantity_day_of_delay,Book_usage_period) VALUES (1896,'Грегори Дэвид Робертс',12-10-1999,0,'Шантарам',12,0,3);

USE Book_library;
Go
--Создаем представление
CREATE VIEW NumberStudentBook AS
SELECT NumberBook.Book_return_date AS ReturnDate,
		NumberBook.Issue_date_of_the_book AS Vidana,
        Student.Name_of_student AS NameStudent,
        Book.Title_of_the_book As NameBook,  
		Book.Book_author As Autor,
		Book.Quantity_day_of_delay AS Prosrochka
FROM NumberBook INNER JOIN Book ON NumberBook.ID_book = Book.ID_book
INNER JOIN Student ON NumberBook.ID_student = Student.ID_student;

GO
DROP VIEW NumberStudentBook
--Используем представление
SELECT * FROM NumberStudentBook;


USE Book_library;
GO
--Создание хранимых процедур
CREATE PROCEDURE ProductSummary AS
BEGIN
    SELECT Student.Name_of_student AS NameOfDoljnik, Book.Quantity_day_of_delay, Book.Title_of_the_book, NumberBook.Book_return_date
    FROM Student , Book, NumberBook where Book.ID_book = NumberBook.ID_book and NumberBook.ID_student = Student.ID_student;
	SELECT SUM(Book.Quantity_day_of_delay) AS SumProsrochka FROM Book;
END;
--Использование хранимых процедур
GO
USE Book_library;
GO 
EXEC ProductSummary;

	
USE Book_library;
GO

CREATE TRIGGER NumberBook_INSERT_date_Issue 
ON NumberBook
FOR INSERT,update 
AS 
UPDATE NumberBook 
SET Issue_date_of_the_book=getdate() ,
Book_return_date=DATEADD(day, 50, GETDATE()) 
where NumberBook.ID_copy_book in (select ID_copy_book from inserted);

GO
USE Book_library;
GO

DROP TRIGGER NumberBook_INSERT_date_Issue;

SELECT DATEADD(day, 7, GETDATE());

GO
USE [Book_library]
GO

INSERT INTO NumberBook (Issue_date_of_the_book,Book_return_date,The_shelf_where_the_book_is,Book_write_off_date,ID_book,ID_student,ID_Employee)
     VALUES
           ('2023-01-01','2023-01-01','5 полка','2023-01-01',1,3,1);
GO

SELECT ID_student FROM Student WHERE Name_of_student = 'Иванова Анна Сергеевна';
SELECT ID_book FROM Book WHERE Title_of_the_book = 'Иванова Анна Сергеевна';