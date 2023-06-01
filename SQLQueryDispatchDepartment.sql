CREATE DATABASE DispatchDepartment;
Use DispatchDepartment;

--�������� ������

CREATE TABLE Car(
Vehicle_code	Int PRIMARY KEY	IDENTITY Not null,
Car_model	Varchar(30) 	Not null,
Government_number	Varchar(30) 	Not null,
Color	Varchar(30) 	Not null,
Year_of_release	Date 	Not null,
Technical_condition	Varchar(60) 	Not null
);

CREATE TABLE TypeOfWork(
Work_code	Int PRIMARY KEY	IDENTITY Not null,
Name_of_works	Varchar(120)  	Not null,
Price	Int	Not null
);

CREATE TABLE Adress(
Address_code	Int PRIMARY KEY	IDENTITY Not null,
City	Varchar(30) 	Not null,
Street	Varchar(30) 	Not null,
House	Int 	Not null,
Flat	Int 	Not null,
);

CREATE TABLE Employee(
Employee_code	Int PRIMARY KEY	IDENTITY Not null,
Employee_surname	Varchar(30)	Not null,
Employee_name	Varchar(30) 	Not null,
Employee_patronymic	Varchar(30) 	Not null,
Employee_date_of_birth	Date	Not null,
Category Int Not null,
Callsign Varchar(30) 	Not null,
Vehicle_code int REFERENCES Car(Vehicle_code),
Address_code int REFERENCES Adress(Address_code)
);

CREATE TABLE Client(
Client_code	Int PRIMARY KEY	IDENTITY Not null,
Client_surname	Varchar(30) 	Not null,
Client_name	Varchar(30) 	Not null,
Client_patronymic	Varchar(30) 	Not null,
Date_of_Birth	Date 	Not null,
Telephone Int 	Not null,
Address_code int REFERENCES Adress(Address_code)
);


CREATE TABLE Request(
Application_code Int PRIMARY KEY	IDENTITY Not null,
Initial_value	Varchar(30)  	Not null,
End_value	Varchar(30) 	Not null,
The_date_of_the_beginning	Date 	Not null,
Start_time	Time 	Not null,
Expiration_date Date Not null,
End_time Time Not null,
Application_status Varchar(30) Not null,
Work_code int REFERENCES TypeOfWork(Work_code),
Address_code int REFERENCES Adress(Address_code),
Employee_code int REFERENCES Employee(Employee_code),
Client_code int REFERENCES Client(Client_code)
);

--�������� ������ ��� ����� �� ������
CREATE LOGIN HeadDep WITH PASSWORD = '123456';

--�������� ������������ ��� ���������� ������
CREATE USER HeadDep FOR LOGIN HeadDep;
--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT,INSERT,UPDATE,DELETE ON DispatchDepartment.dbo.Adress TO HeadDep;
GRANT SELECT,INSERT,UPDATE,DELETE ON DispatchDepartment.dbo.Adress TO HeadDep;
GRANT SELECT,INSERT,UPDATE,DELETE ON DispatchDepartment.dbo.Adress TO HeadDep;
GRANT SELECT,INSERT,UPDATE,DELETE ON DispatchDepartment.dbo.Adress TO HeadDep;
GRANT SELECT,INSERT,UPDATE,DELETE ON DispatchDepartment.dbo.Adress TO HeadDep;

--�������� ������ ��� ����� �� ������
CREATE LOGIN Stajer WITH PASSWORD = '1234';

--�������� ������������ ��� ���������� ������
CREATE USER Stajer FOR LOGIN Stajer;

--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT ON DispatchDepartment.dbo.Adress TO Stajer;
GRANT SELECT ON DispatchDepartment.dbo.Adress TO Stajer;
GRANT SELECT ON DispatchDepartment.dbo.Adress TO Stajer;
GRANT SELECT ON DispatchDepartment.dbo.Adress TO Stajer;
GRANT SELECT ON DispatchDepartment.dbo.Adress TO Stajer;

--������
SELECT DISTINCT Client.Client_surname, Client.Client_name,Request.Initial_value,
Request.Application_status, TypeOfWork.Name_of_works, TypeOfWork.Price, Employee.Callsign, Car.Government_number 
FROM Client, TypeOfWork, Request, Employee,Car
where Client.Client_code = Request.Client_code and Request.Work_code = TypeOfWork.Work_code 
and Request.Employee_code = Employee.Employee_code and Employee.Vehicle_code = Car.Vehicle_code;

--��������� ����������
set statistics io on
set statistics time on

--�������� �������
CREATE index IX_Name_of_clients on Client (Client_surname);

--�������� ������������� ���� �����������
EXEC sp_enum_oledb_providers;

--�������������� ������
SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from auto') WHERE model NOT IN (SELECT Car.Car_model FROM Car);

--�������� ���������
CREATE SYNONYM synonymautosalon FOR [POSTGRESQL].[DDdatabase].[public].[auto];

CREATE SYNONYM synonymadofteach FOR [POSTGRESQL].[DDdatabase].[public].[autosalon];

--�������� ������ ���������
SELECT * FROM synonymautosalon;
SELECT * FROM synonymadofteach;
SELECT * FROM OPENQUERY(POSTGRESQL, 'select model, yearofauto, price, valueofauto, namestore, telstore
 from Auto, Autosalon where Autosalon.IDStore = Auto.IDStor;')



--�������� �������������
CREATE VIEW modelprice AS
select model AS Model,
price AS Price
FROM synonymautosalon WHERE model IN (SELECT Car.Car_model FROM Car);

--������ � �������������
SELECT * FROM modelprice;

USE DispatchDepartment;
Go
--�������� �������������� ��� ������� ������ ����������� � ����.�������
CREATE VIEW modelpricestore AS
SELECT * FROM OPENQUERY(POSTGRESQL, 'select model, yearofauto, price, valueofauto, namestore, telstore
 from Auto, Autosalon where Autosalon.IDStore = Auto.IDStor;');

 --�������� �������������� ��� ������� ������ ����.�������
 CREATE VIEW modelpricestoremodel AS
 SELECT * FROM OPENQUERY(POSTGRESQL, ' select model, yearofauto, powerofauto, price, valueofauto from Auto;');

  --�������� �������������� ��� ����������� ������ ����.�������
 CREATE VIEW storeidauto AS
 SELECT * FROM OPENQUERY(POSTGRESQL, 'select idauto from Auto;');

  --������ � �������������
SELECT * FROM storeidauto;

 --������ � �������������
SELECT * FROM modelpricestoremodel;

 --������ � �������������
SELECT * FROM modelpricestore;

--�������� ���������
CREATE PROCEDURE ValueOfReqest AS
BEGIN    
	SELECT DISTINCT Client.Client_surname, Client.Client_name, Request.Initial_value, Adress.City, Adress.Street, Adress.House,
	Employee.Employee_surname, Employee.Employee_name, Car.Car_model, TypeOfWork.Name_of_works, TypeOfWork.Price
	FROM Client, Request, Adress, Employee, TypeOfWork, Car  where Request.Client_code = Client.Client_code and 
	Request.Work_code = TypeOfWork.Work_code and Request.Employee_code = Employee.Employee_code and Employee.Vehicle_code = Car.Vehicle_code
	and Adress.Address_code = Request.Address_code and Request.The_date_of_the_beginning = '2021-07-05';
	SELECT SUM(TypeOfWork.Price) AS Obshi_price FROM TypeOfWork;
END;	

--�������� ������ ���������
GO
USE DispatchDepartment;
GO 
EXEC ValueOfReqest;

--�������� �������� 
USE DispatchDepartment;
GO

CREATE TRIGGER TRGDateOfReqest 
ON Request
FOR INSERT,update 
AS 
UPDATE Request 
SET The_date_of_the_beginning = getdate(),Start_time = getdate(),Expiration_date=getdate()+5,End_time = getdate()
where Request.Application_code in (select Application_code from inserted);

--������� ������ � ������������ �����
INSERT into Request(	
	Initial_value,
	End_value,
	The_date_of_the_beginning,
	Start_time,
	Expiration_date,
	End_time,
	Application_status,
	Work_code,
	Address_code,
	Employee_code,
	Client_code)
VALUES ('����� � ������ ����', '���������', '2051-07-10', '11:00:00', '2021-07-12','11:00:00','���������', 11,15,6,15)
Go

--�������� �������� ��� ����
CREATE TRIGGER TRGDateOfcar 
ON Car
FOR INSERT,update 
AS 
UPDATE Car 
SET Year_of_release = getdate()
where Car.Vehicle_code in (select Vehicle_code from inserted);

