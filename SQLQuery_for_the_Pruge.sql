CREATE DATABASE University;
Use University;

CREATE TABLE Thing(
Unique_item_number	Int PRIMARY KEY	IDENTITY Not null,
Thing	Varchar(30) 	Not null
);

CREATE TABLE Student(
Gradebook_number	Int PRIMARY KEY	IDENTITY Not null,
Surname	Varchar(50) 	Not null,
Name_of_student	Varchar(50) 	Not null,
Patronymic	Varchar(50) 	Not null,
Locality	Varchar(50) 	Not null,
Postcode	Int 	Not null,
Street	Varchar(50) 	Not null,
House_number	Int 	Not null,
Apartment_number	Int 	Not null,
Phone_number	Int 	Not null
);

CREATE TABLE Teacher(
Personnel_Number	Int PRIMARY KEY	IDENTITY Not null,
Surname	Varchar(50) 	Not null,
Name_of_teacher	Varchar(50) 	Not null,
Patronymic	Varchar(50) 	Not null,
Position	Varchar(50) 	Not null,
Department	Varchar(50)  	Not null,
Phone	Int 	Not null,
);

CREATE TABLE Grouppa(
Group_code	Int PRIMARY KEY	IDENTITY Not null,
Course	Int 	Not null,
Name_of_group	Varchar(30) 	Not null,
Code_of_specialty	Int 	Not null,
Specialty	Varchar(30) 	Not null,
);

CREATE TABLE Session(
Session_code	Int PRIMARY KEY	IDENTITY Not null,
Subject	Varchar(50) 	Not null,
Teacher	Varchar(50) 	Not null,
Student	Varchar(50) 	Not null,
Exam	Varchar(50)  	Not null,
Date_of_Exam	Date 	Not null,
Evaluation Int 	Not null,
Unique_item_number int REFERENCES Thing(Unique_item_number),
Gradebook_number int REFERENCES Student(Gradebook_number),
Personnel_Number int REFERENCES Teacher(Personnel_Number),
Group_code int REFERENCES Grouppa(Group_code)
);

--Создание логина для входа на сервер
CREATE LOGIN Bosses WITH PASSWORD = '123456';

--Создание пользователя для созданного логина
CREATE USER Bosses FOR LOGIN Bosses;

--Создание логина для входа на сервер
CREATE LOGIN Stages WITH PASSWORD = '1234';

--Создание пользователя для созданного логина
CREATE USER Stages FOR LOGIN Stages;

--Добавление привелегий пользователю выбирать все атрибуты отношения
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Thing TO Bosses;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Student TO Bosses;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Teacher TO Bosses;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Grouppa TO Bosses;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Session TO Bosses;

--Добавление привелегий пользователю выбирать все атрибуты отношения
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Thing TO Stages;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Student TO Stages;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Teacher TO Stages;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Grouppa TO Stages;
GRANT SELECT,INSERT,UPDATE,DELETE ON University.dbo.Session TO Stages;

ALTER TABLE Session
DROP COLUMN Subject, Teacher, Student;

ALTER TABLE Session
DROP COLUMN Date_of_Exam;

ALTER TABLE Session
ADD Date_of_Exam DATE NOT NULL DEFAULT '01-01-2021';

SELECT Student.Surname, Student.Name_of_student FROM Student join Session 
ON Student.Gradebook_number = Session.Gradebook_number where Session.Evaluation = 5;

set statistics io on
set statistics time on

SELECT Student.Surname, Student.Name_of_student FROM Student join Session 
ON Student.Gradebook_number = Session.Gradebook_number where Session.Evaluation = 5;

CREATE index IX_Name_of_student on Student (Name_of_student) 

--Проверка на то как работают удаленные запросы.
SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from AdressOfTeacherPG, TeacherPG 
							where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;');

SELECT * FROM Teacher
WHERE Surname NOT IN (SELECT * FROM OPENQUERY(POSTGRESQL, 'select Surname from TeacherPG'));

SELECT * FROM Teacher
WHERE Surname IN (SELECT * FROM OPENQUERY(POSTGRESQL, 'select Surname from TeacherPG'));

SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from teachersaddress;');

CREATE SYNONYM synonymteacher FOR [POSTGRESQL].[CityOfTheacher].[public].[teacherpg];
CREATE SYNONYM synonymadofteach FOR [POSTGRESQL].[CityOfTheacher].[public].[adressofteacherpg];

use University;

select * from synonymadofteach;

CREATE PROCEDURE OtlichnikiANDobsjiball AS
BEGIN    
	SELECT Student.Surname AS Familiya, Student.Name_of_student AS Imya, Student.Patronymic AS Otchestvo,Session.Evaluation, Thing.Thing
		FROM Student,Thing , Session where Student.Gradebook_number = Session.Gradebook_number 
		and Thing.Unique_item_number = Session.Unique_item_number and Session.Evaluation = 5;
		SELECT SUM(Session.Evaluation) AS Obshi_ball FROM Session;
END;

GO
USE University;
GO 
EXEC OtlichnikiANDobsjiball;

CREATE PROCEDURE AdressOfTeacher AS
BEGIN    
	SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from teachersaddress;');
END;

GO
USE University;
GO 
EXEC AdressOfTeacher;

USE University;
GO

CREATE TRIGGER Session_INSERT_date_Exam2 
ON Session
FOR INSERT,update 
AS 
UPDATE Session 
SET Date_of_Exam=getdate() where Session.Session_code in (select Session_code from inserted);


Insert INTO Session (
		[Exam],
		[Evaluation],
		[Unique_item_number],
		[Gradebook_number],
		[Personnel_Number],
		[Group_code],
		[Date_of_Exam])
	VALUES ('Zachet',5,9,4,1,1,'2035-01-01')
GO

select * from Session;

USE University;
GO

Insert INTO Session (
		[Exam],
		[Evaluation],
		[Unique_item_number],
		[Gradebook_number],
		[Personnel_Number],
		[Group_code],
		[Date_of_Exam])
	VALUES ('Exam',0,8,3,1,1,'2035-01-01')
GO

SELECT COUNT(Session.Gradebook_number) from Session,Grouppa where Session.Group_code=Grouppa.Group_code and Grouppa.Name_of_group = 4181;

SELECT * FROM Student WHERE Surname = 'Иванова';

SELECT Student.Surname, Student.Name_of_student, Student.Patronymic, Session.Exam,Thing.Thing,Session.Evaluation,Session.Date_of_Exam,Teacher.Surname
FROM Student,Session,Thing,Teacher WHERE Student.Gradebook_number = Session.Gradebook_number 
AND Thing.Unique_item_number = Session.Unique_item_number AND Teacher.Personnel_Number = Session.Personnel_Number
AND Student.Surname = 'Иванова';

--Распределенный запрос для Гьюшки

USE University;
GO 

CREATE PROCEDURE ForRaspeZapros AS
BEGIN    
	SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from AdressOfTeacherPG, TeacherPG 
							where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;');
END;

ForRaspeZapros

USE University;
Insert INTO Student(
		[Surname],
		[Name_of_student],
		[Patronymic],
		[Locality],
		[Postcode],
		[Street],
		[House_number],
		[Apartment_number],
		[Phone_number])
	VALUES ('Смородина','Дарья','Петровна','Тольятти',045442,'Луначарского',1,42,531651)
GO

USE University;
Insert INTO Grouppa(
		[Course],
		[Name_of_group],
		[Code_of_specialty],
		[Specialty])
	VALUES (1,'4283',1,'Поалеоботаника')
GO

--Создадим процедуру, которая будет выдавать нам запрос из всех таблиц БД MS SQL Server и PQ

CREATE PROCEDURE VivodSessia AS
BEGIN    
	SELECT Student.Surname AS Familiya, Student.Name_of_student AS Imya, Student.Patronymic AS Otchestvo,Grouppa.Name_of_group,Session.Evaluation, Thing.Thing,
		Teacher.Name_of_teacher, Teacher.Surname, Teacher.Patronymic 
		FROM Student,Thing , Session, Teacher, Grouppa where Student.Gradebook_number = Session.Gradebook_number 
		and Thing.Unique_item_number = Session.Unique_item_number and Session.Personnel_Number = Teacher.Personnel_Number
		and Session.Group_code = Grouppa.Group_code;
		SELECT Teacher.Surname,Teacher.Name_of_teacher,Teacher.Patronymic, locality, street, housenumber,apartmentnumber FROM Teacher, OPENQUERY(POSTGRESQL,
		'select * from AdressOfTeacherPG, TeacherPG where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;')
		WHERE Teacher.Personnel_Number = personnelnumber;
END;

--Это распред запрос он берет ФИО из одной базы, сравнимает ID и берет адреса из другой базы данных мы его засунем в процедуру, что бы не писать кучу кода в питоне
SELECT Teacher.Surname,Teacher.Name_of_teacher,Teacher.Patronymic, locality, street, housenumber,apartmentnumber FROM Teacher, OPENQUERY(POSTGRESQL,
'select * from AdressOfTeacherPG, TeacherPG where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;')
WHERE Teacher.Personnel_Number = personnelnumber;

-- процедура работает не так как нам нужно, послкольку содержит два запроса. Что бы было проще работать с данными в Питоне сделаем один запрос
EXEC VivodSessia;

--Этот запрос дает нам нужный результат, используем его. Но сначала сделаем из него процедуру.
SELECT DISTINCT Session.Session_code,Student.Surname AS Familiya, Student.Name_of_student AS Imya, Student.Patronymic AS Otchestvo,Grouppa.Name_of_group,Session.Evaluation, Thing.Thing,
		Session.Date_of_Exam, Teacher.Name_of_teacher, Teacher.Surname, Teacher.Patronymic,locality,street, housenumber, apartmentnumber, phonenumber 
		FROM Student,Thing , Session, Teacher, Grouppa, OPENQUERY(POSTGRESQL,'select * from AdressOfTeacherPG, TeacherPG where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;')
		WHERE Student.Gradebook_number = Session.Gradebook_number 
		and Thing.Unique_item_number = Session.Unique_item_number and Session.Personnel_Number = Teacher.Personnel_Number
		and Session.Group_code = Grouppa.Group_code AND Teacher.Personnel_Number = personnelnumber;


CREATE PROCEDURE VivodimSessiu AS
BEGIN    
	SELECT DISTINCT Session.Session_code,Student.Surname AS Familiya, Student.Name_of_student AS Imya, Student.Patronymic AS Otchestvo,Grouppa.Name_of_group,Session.Evaluation, Thing.Thing,
		Session.Date_of_Exam, Teacher.Name_of_teacher, Teacher.Surname, Teacher.Patronymic,locality,street, housenumber, apartmentnumber, phonenumber 
		FROM Student,Thing , Session, Teacher, Grouppa, OPENQUERY(POSTGRESQL,'select * from AdressOfTeacherPG, TeacherPG where AdressOfTeacherPG.PersonnelNum = TeacherPG.PersonnelNumber;')
		WHERE Student.Gradebook_number = Session.Gradebook_number 
		and Thing.Unique_item_number = Session.Unique_item_number and Session.Personnel_Number = Teacher.Personnel_Number
		and Session.Group_code = Grouppa.Group_code AND Teacher.Personnel_Number = personnelnumber;

END;

VivodimSessiu;
GO

Insert INTO Session (
		[Exam],
		[Evaluation],
		[Unique_item_number],
		[Gradebook_number],
		[Personnel_Number],
		[Group_code],
		[Date_of_Exam])
	VALUES ('Exam',0,8,3,1,1,'2035-01-01')