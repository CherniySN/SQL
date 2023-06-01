CREATE DATABASE AkBarsOutlookPars;
USE AkBarsOutlookPars

--��������� �������
CREATE TABLE List_of_department(
DP_code Int PRIMARY KEY	IDENTITY Not null, --ID ������
Name_of_department VARCHAR(100) Not null, -- �������� �����
);

--������ ����������� �������
CREATE TABLE List_of_boss(
Boss_code	Int PRIMARY KEY	IDENTITY Not null, --ID ����������
Boss_Surname	Varchar(30) 	Not null, --������� ����������
Boss_Name	Varchar(30) 	Not null, --��� ����������
Boss_otchestvo	Varchar(30) 	Not null, --�������� ����������
DP_code int REFERENCES List_of_department(DP_code) --� ����� ������ ����� ���� ��������� � ��� ��� � ���� ������������ ������� ���������� ��
);

--����� ������
CREATE TABLE List_of_Work(
W_code Int PRIMARY KEY	IDENTITY Not null, --ID ����� ������
Number_of_W Int Not null, -- ����� ����� ������
Name_of_W VARCHAR(100) Not null, --�������� ����� ������
DP_code int REFERENCES List_of_department(DP_code) --� ����� ������ ����� ���� ����� ������ ������
);

--��������� �������
CREATE TABLE List_of_SZ(
SZ_code Int PRIMARY KEY	IDENTITY Not null, --ID ��������� �������
Number_of_SZ VARCHAR(100) Not null, -- ����� ��������� �������
Date_of_SZ DATE Not null, --���� ��������� �������
Body_of_SZ	VARCHAR(MAX)  	Not null, --�������� ����� 8000 ��������, ������ �� 2��.
W_code int REFERENCES List_of_Work(W_code) --� ����� ����� ������ ����� ���� ����� ��������
);

--�������� ������� ��� ������ ��������� �������
CREATE index IX_Number_of_SZ on List_of_SZ(Number_of_SZ);

--�������� ������� ��� ������ ��������� ������� � �����
CREATE VIEW szforNDFL AS
SELECT List_of_SZ.Number_of_SZ, List_of_SZ.Date_of_SZ, List_of_SZ.Body_of_SZ FROM List_of_SZ, List_of_boss, List_of_department,List_of_Work 
WHERE List_of_boss.DP_code = List_of_department.DP_code and List_of_boss.Boss_Surname = '������' and List_of_boss.Boss_Name = '������' and List_of_boss.Boss_otchestvo = '����������' 
and List_of_department.DP_code = List_of_Work.DP_code and List_of_SZ.W_code = List_of_Work.W_code;

--������ � �������������
SELECT * FROM szforNDFL;

--������� ������ �� ��
INSERT into List_of_SZ(	
	[Number_of_SZ],
	[Date_of_SZ],
	[Body_of_SZ],
	[W_code])
VALUES ('��� ����� �� 1234', '10.08.2021','� ��� ����� ������� ���������� ��',1)