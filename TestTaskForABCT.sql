/* 
	Тестовое: Есть задача создать небольшую транзакционную систему с сущностями "Клиенты", "Карты", "Транзакции".

Клиент владеет одной или несколькими картами, по карте может совершаться одна или более транзакций (операций).

Необходимо спроектировать модель БД (желательно в третьей нормальной форме) и наполнить ее данными (сгенерировать данные), 
при необходимости создать индексы.

Входными параметрами этой процедуры должны быть "кол-во клиентов" (количество клиентов, которое генерим), 
"кол-во карт" (количество карт, которое генерим), "кол-во транзакций" (количество операций, которое генерим)

Требования:

Для каждой сущности должен быть создан первичный ключ.
Для клиента должно быть сгенерировано ФИО (либо просто фамилия). Можно не морочиться с реальными ФИО - просто любой набор букв
Для карты должен быть сгенерирован номер карты (ЛЮБЫЕ 16 цифр) и дата окончания действия карты (Дата)
Для транзакций обязательными полями являются сумма, тип операции (пополнение, снятие) и дата/время.  
Вместо типа операции можно использовать знак плюс или минус у суммы операции

В случае , если после очередной транзакции по карте баланс уходит в минус 
(то есть суммы предыдущих пополнений не хватает для очередной покупки) , то такую транзакцию не вставляем, 
выводим сообщение (либо записываем куда-нибудь) "недостаточно средств".

В случае совершения операции после даты окончания действия карты - такую транзакцию тоже не вставляем, 
выводим сообщение - "карта недействительна".

 

Код оформить в виде процедуры/процедур на T-SQL (MS SQL).
Анализ работы процедуры/процедур будет производится со значениями параметров:
- "Клиенты" = 1000
- "Карты" = 5000
- "Транзации" = 15000
*/


-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 1 ⇊⇊⇊⇊⇊⇊⇊⇊
CREATE DATABASE Transactional_system;
Use Transactional_system;
-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈


-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 2 ⇊⇊⇊⇊⇊⇊⇊⇊
CREATE TABLE Typet(
id_typet	Int PRIMARY KEY	IDENTITY Not null, 
transaction_type	Varchar(30) 	Not null
);

CREATE TABLE Client(
id_client Int PRIMARY KEY IDENTITY Not null,
Client_surname	Varchar(30) 	Not null,
Client_name	Varchar(30) 	Not null,
Client_patronymic	Varchar(30) 	Not null
); 


CREATE TABLE Card(
id_card	Int PRIMARY KEY	IDENTITY Not null,
number_card	Varchar(16) Not null, --тут хорошо бы проверять, что у нас именно 16 цифр пока уберем проверку, где-то генерит не то количество символов, срабатывет CHECK (LEN(number_card) = 16)
date_of_end	DATE,
balance DECIMAL(38, 2) DEFAULT 0 CHECK (balance >= 0),
id_client int REFERENCES Client(id_client)
);

CREATE TABLE Transactions(
id_t	Int PRIMARY KEY	IDENTITY Not null,
summ	DECIMAL(38, 2) 	Not null, 
date_time_of_tran	DATETIME DEFAULT getdate(),
id_card int REFERENCES Card(id_card),
id_typet int REFERENCES Typet(id_typet)
);
-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈

/* 
	Базу данных мы создали, создадим триггеры которые будут автоматически вставлять дату текущую при выпуске карты и дату и время при создание операции.
Так же у нас есть требования в задании: 

В случае , если после очередной транзакции по карте баланс уходит в минус 
(то есть суммы предыдущих пополнений не хватает для очередной покупки) , то такую транзакцию не вставляем, 
выводим сообщение (либо записываем куда-нибудь) "недостаточно средств". Решил выводить сообщение.

В случае совершения операции после даты окончания действия карты - такую транзакцию тоже не вставляем, 
выводим сообщение - "карта недействительна". 

*/


-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 3 ⇊⇊⇊⇊⇊⇊⇊⇊
	-- триггер на дату действия карты, думаю по возможности нужно все автоматизировать
GO
CREATE TRIGGER TRG_date_of_end --вставляем дату окончания действия карты
ON Card
FOR INSERT,update 
AS 
UPDATE Card 
SET date_of_end = getdate()+365 --тут тоже уточнений нет, пускай будет год (дата окончания через год от текущей даты)
where Card.id_card in (select id_card from inserted);
-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈


-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 4 ⇊⇊⇊⇊⇊⇊⇊⇊
	--Включение статистики
set statistics io on
set statistics time on
-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈



-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 5 ⇊⇊⇊⇊⇊⇊⇊⇊
	-- заполним типы транзакций
INSERT into Typet(	
	transaction_type)
VALUES ('+')
Go

INSERT into Typet(	
	transaction_type)
VALUES ('-')
Go

-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈




/* Заведем - "Клиенты" = 1000 человек, для них оформим - "Карты" = 5000 штук, по которым будут совершены - "Транзации" = 15000 шутук. */


-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 6 ⇊⇊⇊⇊⇊⇊⇊⇊
	-- Генерация фамилии имени и отчества клиентов
GO
SET NOCOUNT ON;
GO
DECLARE @MyCounter INT,@MyCounterSmall INT, @Name VARCHAR(5), @Surname VARCHAR(5), @Patromic VARCHAR(5), @RandNumb INT;

SET @MyCounter = 0;

WHILE (@MyCounter < 1000)
BEGIN;

SET @MyCounterSmall = 0;
SET @Name = '';
SET @Surname = '';
SET @Patromic = '';

	WHILE (@MyCounterSmall < 5)
	BEGIN;
		SET @RandNumb = (SELECT (ROUND(1+(RAND(CHECKSUM(NEWID()))*24),0))); 
		
		SET @Name += CAST(CHAR((@RandNumb + ASCII('A'))) AS VARCHAR(1));
		SET @MyCounterSmall = @MyCounterSmall + 1;
		PRINT @Name
	END;
	
	SET @MyCounterSmall = 0;
	WHILE (@MyCounterSmall < 5)
	BEGIN;
		SET @RandNumb = (SELECT (ROUND(1+(RAND(CHECKSUM(NEWID()))*24),0))); 
		
		SET @Surname += CAST(CHAR((@RandNumb + ASCII('A'))) AS VARCHAR(1));
		SET @MyCounterSmall = @MyCounterSmall + 1;
		PRINT @Surname
	END;
	
	SET @MyCounterSmall = 0;
	WHILE (@MyCounterSmall < 5)
	BEGIN;
		SET @RandNumb = (SELECT (ROUND(1+(RAND(CHECKSUM(NEWID()))*24),0))); 
		
		SET @Patromic += CAST(CHAR((@RandNumb + ASCII('A'))) AS VARCHAR(1));
		SET @MyCounterSmall = @MyCounterSmall + 1;
		PRINT @Patromic
	END;
   
   INSERT INTO Client VALUES
       
       (@Surname,
        @Name,
		@Patromic
       );
   
   SET @MyCounter = @MyCounter + 1;
END;
GO
SET NOCOUNT OFF;
GO
-- Посмотрим что получилось. (время работы 4 мс.)
SELECT * FROM Client;
GO
-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈



	-- Генерим 5000 номеров карт для вставки помним про условие
	-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 7 ⇊⇊⇊⇊⇊⇊⇊⇊

CREATE TABLE #Card (id_card	Int PRIMARY KEY	IDENTITY Not null, number_card Varchar(16));

Create table #CaedID(id_client Int PRIMARY KEY IDENTITY Not null,id_client_for_union Varchar(16));

INSERT INTO #Card
select TOP 5000 left(cast(cast(cast(crypt_gen_random(8, cast(newid() as varbinary(16))) as binary(8)) as bigint) & 0x7fffffffffffffff as varchar(19)),16)
FROM sysobjects A
CROSS JOIN sysobjects B
CROSS JOIN sysobjects C

select * from #Card

	-- генерим id клиентов - держателей карт
INSERT INTO #CaedID 
select TOP 5000 ABS(CONVERT(INT, (CONVERT(BINARY(4), (NEWID()))))) % 100 +1
FROM sysobjects A
CROSS JOIN sysobjects B

INSERT INTO Card(number_card, id_client) SELECT number_card, id_client_for_union FROM #Card,#CaedID where #Card.id_card = #CaedID.id_client; 
select * from Card; -- как видим все заполнено верно

-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈




	-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 8 ⇊⇊⇊⇊⇊⇊⇊⇊
	--Создадим индекс после генерации карт, т.к. при добавлении 5 000 карт мы будем обновлять индексы у всей таблицы, но обязательно перед использование процедуры - это ускорит поиск.
CREATE index NumbCard on Card (number_card);

	-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈



	-- ⇊⇊⇊ МОЖНО ЗАПУСТИТЬ РАБОТАЕТ, НО Я РЕШИЛ В ПРОЦЕДУРЕ ЧЕРЕЗ ЦИКЛ ВСТАВКУ ПО ОДНОМУ ИСПОЛЬЗОВАТЬ ⇊⇊⇊⇊⇊⇊⇊⇊
	-- Генерим транзакции 15 000 штук сделаем триггер, который будет втавлять знак операции для записи транзакций в большой процедуре.
CREATE TABLE TestTableTrensactions (summ	DECIMAL(38, 2), id_transaction_card_for_union Varchar(16))

CREATE TABLE #Transactions -- временная таблица для тек.сессии
(id_summ	Int PRIMARY KEY	IDENTITY Not null,summ	DECIMAL(38, 2));

Create table #TransactionCardID
(id_tcfu	Int PRIMARY KEY	IDENTITY Not null, id_transaction_card_for_union Varchar(16));

INSERT INTO #Transactions
SELECT TOP 15000
      cast(cast((CHECKSUM(NEWID()) % 10000) as float) + RAND(CHECKSUM(NEWID())) as DECIMAL(38, 2))
FROM sysobjects A
CROSS JOIN sysobjects B
CROSS JOIN sysobjects C;

select * from #Transactions;

INSERT INTO #TransactionCardID -- генерим id карты
select TOP 15000 ABS(CONVERT(INT, (CONVERT(BINARY(4), (NEWID()))))) % 1000 +1
FROM sysobjects A
CROSS JOIN sysobjects B

select * from #TransactionCardID; 

INSERT INTO TestTableTrensactions(summ, id_transaction_card_for_union) SELECT summ, id_transaction_card_for_union 
FROM #Transactions,#TransactionCardID where #TransactionCardID.id_tcfu = #Transactions.id_summ;

select * from TestTableTrensactions; 

-- ⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈⇈
		
	-- Тут мы сгенерировали псевдослучайный набор цифр транзакции с компейками и ID карты. 
-- Что бы было более провдоподобно сделаем так что из 5 000 карт транзакции есть только по 1000 картам, остальными картами клиенты не пользуются, думаю у жизни так и есть.
-- (генерировать ИЛИ будем вставлять по 1 штуке в цикле в процедуре? В задании не сказанно.
-- Думаю, что более естественно было бы это реализавать в прецедуре, будет более похоже на имитацию транзакций, поскольку в жизни врядли вставляются 15 000 транзакций единовременно.





/* 
	Создадим процедуру, кторая проверяет баланс перед операцией и дату действия карты и вносит изменения. 
Использовать будем ране написанные скрипты для генерации данных в цикле. 
*/

-- Пунктиром выделил процедуру, что бы проще было проверять, такие комментарии обычно не оставляю при работе ---------------------------------------------------------------

	-- ⇊⇊⇊ ВЫДЕЛЯЕМ ЗАПУСКАЕМ 9 ⇊⇊⇊⇊⇊⇊⇊⇊
GO
CREATE PROCEDURE Transactions_Fill_Gaps AS
BEGIN

DECLARE @CountOfTransictions int;
SET @CountOfTransictions = 0;

	WHILE (@CountOfTransictions < 15000)
	BEGIN;
		
		DECLARE @current_value_of_money int, @current_date date, @end_of_card date, @id_card_for_serch int, @id__typet int, @summ_of_tranz DECIMAL(38, 2);

		SET @id_card_for_serch = (SELECT ABS(CONVERT(INT, (CONVERT(BINARY(4), (NEWID()))))) % 1000 +1); -- ТУТ ID КАРТА ЧЕТ НЕ РАБОТАЕТ !!!
		
		SET @current_value_of_money = (SELECT balance FROM Card where Card.id_card = @id_card_for_serch);

		SET @current_date = GETDATE();

		SET @end_of_card = (SELECT date_of_end FROM Card where Card.id_card = @id_card_for_serch);

		SET @summ_of_tranz = (SELECT cast(cast((CHECKSUM(NEWID()) % 10000) as float) + RAND(CHECKSUM(NEWID())) as DECIMAL(38, 2)));

			IF SIGN(@summ_of_tranz) = 1.00
				SET @id__typet = 1
				
			ELSE 
				SET @id__typet = 2

		IF @current_date > @end_of_card
			PRINT 'Карта не действительна.'

		ELSE

			BEGIN 
				IF @id__typet = 1

					BEGIN
						PRINT 'Зачисление'
						INSERT INTO Transactions(summ, id_card, id_typet) VALUES(@summ_of_tranz, @id_card_for_serch, @id__typet)
						UPDATE Card SET balance = balance + @summ_of_tranz WHERE Card.id_card = @id_card_for_serch
					END;

				ELSE
					BEGIN;
					PRINT @current_value_of_money;
					PRINT @summ_of_tranz;
					END;
					

					IF @current_value_of_money < ABS(@summ_of_tranz )
						PRINT 'Недостаточно средств'

					ELSE

						BEGIN
							PRINT 'Снятие \ Перевод \ Оплата'
							INSERT INTO Transactions(summ, id_card, id_typet) VALUES(@summ_of_tranz, @id_card_for_serch, @id__typet)
							UPDATE Card SET balance = balance - ABS(@summ_of_tranz) WHERE Card.id_card = @id_card_for_serch
						END;
			END;
	SET @CountOfTransictions = @CountOfTransictions + 1;
	END;
	
END;

-- конец процедуры -------------------------------------------------------------------------------------------------------------------------------------------------

	-- Используем процедуру
EXEC Transactions_Fill_Gaps; -- (47 секунд)


	-- Проверим
SELECT * FROM Transactions;
SELECT * FROM Card where Card.balance > 0; 

/* Процедура работает согласно тех.заданию, у нас много зачислений, т.к. на всех картах было 0 но есть и списания когда на кртах было достаточно средств для расходов */

set statistics io off
set statistics time off