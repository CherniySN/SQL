-- ������������� ������ ���������������������� ������� ��������� ���������

CREATE DATABASE Nalogovaya;
Use Nalogovaya;

CREATE TABLE Employee(
Idemp	Int PRIMARY KEY	IDENTITY Not null,
Surname	Varchar(50) 	Not null,
NameEmp	Varchar(50) 	Not null,
Patronymic	Varchar(50) 	Not null,
Salary Float Not null,
NDFL Float 
);

CREATE TABLE NDS(
IDnds	Int PRIMARY KEY	IDENTITY Not null,
STAVKA Int Not null
);

CREATE TABLE Inc(
INN	Int PRIMARY KEY	IDENTITY Not null,
KPP Int Not null,
StatusInc Varchar(50) Not null,
City	Varchar(50) 	Not null,
Street	Varchar(50) 	Not null,
House_number	Int 	Not null,
Apartment_number	Int 	Not null,
Idemp int REFERENCES Employee(Idemp),
IDnds int REFERENCES NDS(IDnds)
);

--�������� ������ ��� ����� �� ������
CREATE LOGIN BBK WITH PASSWORD = '12345678';

--�������� ������������ ��� ���������� ������
CREATE USER Bbk FOR LOGIN BBK;

--�������� ������ ��� ����� �� ������
CREATE LOGIN EMPL WITH PASSWORD = '12345678';

--�������� ������������ ��� ���������� ������
CREATE USER Empl FOR LOGIN EMPL;

--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT,INSERT,UPDATE,DELETE ON Nalogovaya.dbo.Employee TO BBK;
GRANT SELECT,INSERT,UPDATE,DELETE ON Nalogovaya.dbo.NDS TO BBK;
GRANT SELECT,INSERT,UPDATE,DELETE ON Nalogovaya.dbo.Inc TO BBK;

--���������� ���������� ������������ �������� ��� �������� ���������
GRANT SELECT ON Nalogovaya.dbo.Employee TO EMPL;
GRANT SELECT ON Nalogovaya.dbo.NDS TO EMPL;
GRANT SELECT ON Nalogovaya.dbo.Inc TO EMPL;

set statistics io on
set statistics time on

--�������� �������
CREATE index IX_INN_of_the_INC on Inc (KPP); 

select * from Inc;

--�������� �� �� ��� �������� ��������� �������.
SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from Emp, AdressOfEMPL where Emp.IDEmployee = AdressOfEMPL.IDEmpLL;');

--�������� ���������
CREATE SYNONYM synonymEMP FOR [POSTGRESQL].[DopBDforNalogovaya].[public].[emp];
CREATE SYNONYM synonymadofEMP FOR [POSTGRESQL].[DopBDforNalogovaya].[public].[adressofempl];


--�������� ���������
CREATE PROCEDURE ADRESSEMP AS 
BEGIN    
	SELECT * FROM OPENQUERY(POSTGRESQL, 'select * from Emp, AdressOfEMPL where Emp.IDEmployee = AdressOfEMPL.IDEmpLL;');
END;

--�������� ������ ���������
EXEC ADRESSEMP;


USE Nalogovaya;
GO

--������� �������
CREATE TRIGGER RashchetNDFL 
ON Employee
FOR INSERT,update 
AS 
UPDATE Employee 
SET NDFL = Salary * 0.18 where Idemp in (select Idemp from inserted);

select distinct * from Inc,Employee,NDS where NDS.STAVKA = 18 and Inc.INN = 1;