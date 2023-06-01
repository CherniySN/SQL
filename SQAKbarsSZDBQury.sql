CREATE DATABASE AkBarsOutlookPars;
USE AkBarsOutlookPars

--Служебные записки
CREATE TABLE List_of_department(
DP_code Int PRIMARY KEY	IDENTITY Not null, --ID отдела
Name_of_department VARCHAR(100) Not null, -- Название отдел
);

--Список начальников отделов
CREATE TABLE List_of_boss(
Boss_code	Int PRIMARY KEY	IDENTITY Not null, --ID начальника
Boss_Surname	Varchar(30) 	Not null, --Фамилия начальника
Boss_Name	Varchar(30) 	Not null, --Имя начальника
Boss_otchestvo	Varchar(30) 	Not null, --Отчество начальника
DP_code int REFERENCES List_of_department(DP_code) --В одном отделе может быть начальник и его зам и иные руководители которые пересылают СЗ
);

--Этапы работы
CREATE TABLE List_of_Work(
W_code Int PRIMARY KEY	IDENTITY Not null, --ID этапа работы
Number_of_W Int Not null, -- Номер этапа работы
Name_of_W VARCHAR(100) Not null, --Название этапа работы
DP_code int REFERENCES List_of_department(DP_code) --В одном отделе может быть много этапов работы
);

--Служебные записки
CREATE TABLE List_of_SZ(
SZ_code Int PRIMARY KEY	IDENTITY Not null, --ID служебной записки
Number_of_SZ VARCHAR(100) Not null, -- Номер служебной записки
Date_of_SZ DATE Not null, --Дата служебной записки
Body_of_SZ	VARCHAR(MAX)  	Not null, --содержит более 8000 символов, размер до 2Гб.
W_code int REFERENCES List_of_Work(W_code) --В одном этапе работы может быть много служебок
);

--Создание индекса для номера служебной записки
CREATE index IX_Number_of_SZ on List_of_SZ(Number_of_SZ);

--Создание запроса для вывода служебной записки в форму
CREATE VIEW szforNDFL AS
SELECT List_of_SZ.Number_of_SZ, List_of_SZ.Date_of_SZ, List_of_SZ.Body_of_SZ FROM List_of_SZ, List_of_boss, List_of_department,List_of_Work 
WHERE List_of_boss.DP_code = List_of_department.DP_code and List_of_boss.Boss_Surname = 'Черный' and List_of_boss.Boss_Name = 'Сергей' and List_of_boss.Boss_otchestvo = 'Николаевич' 
and List_of_department.DP_code = List_of_Work.DP_code and List_of_SZ.W_code = List_of_Work.W_code;

--Запрос к представлению
SELECT * FROM szforNDFL;

--Вставка данных по СЗ
INSERT into List_of_SZ(	
	[Number_of_SZ],
	[Date_of_SZ],
	[Body_of_SZ],
	[W_code])
VALUES ('Тут номер сз 1234', '10.08.2021','А тут очень длинное содержание СЗ',1)