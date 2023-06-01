CREATE DATABASE GYM;
Use GYM;

--�������� ������
--����������
CREATE TABLE Subscriptions(
Subscription_code	Int PRIMARY KEY	IDENTITY Not null,
Training_type	Varchar(30) 	Not null,
Price	Int 	Not null,
Number_of_visits	Int 	Not null,
Number_of_months	Int 	Not null
);
--������ ��������
CREATE TABLE List_of_clients(
Client_code	Int PRIMARY KEY	IDENTITY Not null,
Surname	Varchar(30) 	Not null,
Name_clients	Varchar(30) 	Not null,
middle_name	Varchar(30) 	Not null,
Address_client	Int 	Not null,
Telephone	BIGINT 	Not null,
Date_of_Birth	DATE 	Not null
);
--������ �������
CREATE TABLE List_of_goods(
Product_code	Int PRIMARY KEY	IDENTITY Not null,
Name_of_good	Varchar(30) 	Not null,
Price	Int 	Not null
);
--������ ����������
CREATE TABLE Workout_List(
Training_code	Int PRIMARY KEY	IDENTITY Not null,
Training_type	Varchar(50) 	Not null
);
--������ �����
CREATE TABLE List_of_services(
Service_code	Int PRIMARY KEY	IDENTITY Not null,
Name_of_service	Varchar(50) 	Not null
);
--������ �����������
CREATE TABLE A_list_of_employees(
Employee_code	Int PRIMARY KEY	IDENTITY Not null,
Employee_surname	Varchar(30) 	Not null,
Employee_name	Varchar(30) 	Not null,
Employee_patronymic	Varchar(30) 	Not null,
Employee_date_of_birth	DATE 	Not null,
Salary	INT 	Not null
);
--������� ������
CREATE TABLE Sale_of_goods(
Sales_number Int PRIMARY KEY	IDENTITY Not null,
�umber	Int  	Not null,
Product_code int REFERENCES List_of_goods(Product_code),
Client_code int REFERENCES List_of_clients(Client_code)
);
--������� �����������
CREATE TABLE Sale_of_season_tickets(
Card_number Int PRIMARY KEY	IDENTITY Not null,
The_date_of_the_beginning	date  	Not null,
Expiration_date	date  	Not null,
Client_code int REFERENCES List_of_clients(Client_code),
Subscriber_code int REFERENCES Subscriptions(Subscription_code)
);
--����������
CREATE TABLE Schedule(
Record_number Int PRIMARY KEY	IDENTITY Not null,
Date_of_Schedule	date  	Not null,
Start_time	time  	Not null,
End_time	time  	Not null,
Employee_code int REFERENCES A_list_of_employees(Employee_code),
Service_code int REFERENCES List_of_services(Service_code),
Training_code int REFERENCES Workout_List(Training_code)
);
--���� ���������
CREATE TABLE Tracking_visits(
Visit_number Int PRIMARY KEY	IDENTITY Not null,
Card_number int REFERENCES Sale_of_season_tickets(Card_number),
Record_number int REFERENCES Schedule(Record_number)
);

--�������� ������ ��� ����� �� ������
CREATE LOGIN HeadDepartm WITH PASSWORD = '123456';

--�������� ������������ ��� ���������� ������
CREATE USER HeadDepartm FOR LOGIN HeadDepartm;
--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT,INSERT,UPDATE,DELETE ON GYM.dbo.A_list_of_employees TO HeadDepartm;
GRANT SELECT,INSERT,UPDATE,DELETE ON GYM.dbo.A_list_of_employees TO HeadDepartm;
GRANT SELECT,INSERT,UPDATE,DELETE ON GYM.dbo.A_list_of_employees TO HeadDepartm;
GRANT SELECT,INSERT,UPDATE,DELETE ON GYM.dbo.A_list_of_employees TO HeadDepartm;
GRANT SELECT,INSERT,UPDATE,DELETE ON GYM.dbo.A_list_of_employees TO HeadDepartm;

--�������� ������ ��� ����� �� ������
CREATE LOGIN StajerOFderpart WITH PASSWORD = '1234';

--�������� ������������ ��� ���������� ������
CREATE USER StajerOFderpart FOR LOGIN StajerOFderpart;

--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT ON GYM.dbo.A_list_of_employees TO StajerOFderpart;
GRANT SELECT ON GYM.dbo.A_list_of_employees TO StajerOFderpart;
GRANT SELECT ON GYM.dbo.A_list_of_employees TO StajerOFderpart;
GRANT SELECT ON GYM.dbo.A_list_of_employees TO StajerOFderpart;
GRANT SELECT ON GYM.dbo.A_list_of_employees TO StajerOFderpart;

--������ ��� �������� �������
SELECT DISTINCT List_of_clients.Surname, List_of_clients.middle_name, List_of_clients.Surname, locality, street, housenumber, apartmentnumber
FROM List_of_clients, OPENQUERY(POSTGRESQL, 'select * from AdressOfClientPG;') WHERE IDadress = List_of_clients.Address_client;

--��������� ����������
set statistics io on
set statistics time on

--�������� �������
CREATE index IX_Surname_of_clients on List_of_clients (Surname);

--�������� ������������� ���� �����������
EXEC sp_enum_oledb_providers;

--�������������� ������
SELECT DISTINCT List_of_clients.Surname, List_of_clients.middle_name, List_of_clients.Surname, locality, street, housenumber, apartmentnumber
FROM List_of_clients, OPENQUERY(POSTGRESQL, 'select * from AdressOfClientPG;') WHERE IDadress = List_of_clients.Address_client;

--�������� ���������
CREATE SYNONYM synonymclien FOR [POSTGRESQL].[ClientAdress].[public].[clientpg];

CREATE SYNONYM synonymadressofclien FOR [POSTGRESQL].[ClientAdress]. [public].[adressofclientpg];

--�������� ������ ���������
SELECT * FROM synonymclien;
SELECT * FROM synonymadressofclien;

--�������� �������������
CREATE VIEW clientadress AS
SELECT DISTINCT List_of_clients.Surname AS surname, List_of_clients.middle_name AS otchestvo, List_of_clients.Name_clients AS name, locality AS gorod,
street AS ylica, housenumber AS dom, apartmentnumber AS kv
FROM List_of_clients, synonymadressofclien WHERE IDadress = List_of_clients.Address_client;

--������ � �������������
SELECT * FROM clientadress;

USE GYM;
Go

--�������� ���������
CREATE PROCEDURE ValueOfEntersAndPrice AS
BEGIN    
	SELECT List_of_clients.Surname, List_of_clients.middle_name, List_of_clients.middle_name,Sale_of_season_tickets.Card_number, Schedule.Date_of_Schedule,
	Schedule.Start_time, Schedule.End_time,A_list_of_employees.Employee_surname, A_list_of_employees.Employee_name,A_list_of_employees.Employee_surname,
	Workout_List.Training_type FROM List_of_clients, Sale_of_season_tickets, Schedule,A_list_of_employees,Workout_List, Tracking_visits, List_of_services, Subscriptions  
	where Tracking_visits.Card_number = Sale_of_season_tickets.Card_number and List_of_clients.Client_code = Sale_of_season_tickets.Client_code 
	and A_list_of_employees.Employee_code = Schedule.Employee_code and Schedule.Training_code = Workout_List.Training_code and Schedule.Service_code = List_of_services.Service_code
	and Sale_of_season_tickets.Card_number = Subscriptions.Subscription_code and Tracking_visits.Record_number = Schedule.Record_number and
	Schedule.Date_of_Schedule = '2020-01-03';
END;	

--�������� ������ ���������
GO
USE GYM;
GO 
EXEC ValueOfEntersAndPrice;

--�������� �������� 
CREATE TRIGGER TRGDateOfSales 
ON Sale_of_season_tickets
FOR INSERT,update 
AS 
UPDATE Sale_of_season_tickets 
SET The_date_of_the_beginning = getdate(),Expiration_date=getdate()+91
where Sale_of_season_tickets.Card_number in (select Card_number from inserted);

--������� ������ � ������������ �����
INSERT into Sale_of_season_tickets(	
	[The_date_of_the_beginning],
	[Expiration_date],
	[Client_code],
	[Subscriber_code])
VALUES ('2051-07-10', '2051-07-10',3,6)
Go
