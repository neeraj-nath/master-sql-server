select 1+1 as Result
go

select 1+2 as Sum
go
select 1/0 As DivideResult
select 1/1 As DivideResult
go

----------------------------
--Entering Data:

CREATE TABLE Students(
	Id UNIQUEIDENTIFIER,
	StdName NVARCHAR(100),
	StdClass INT)
GO

SELECT * FROM Students;
GO

INSERT INTO Students(Id, StdName, StdClass) VALUES(
NEWID(),
'Neeraj',10
);


INSERT INTO Students
VALUES(NEWID(), 'Dikhyita', 9),
(NEWID(),'Amy',8);

---------------------------
--Selecting Data/Retrieving Data:

SELECT * FROM Students;
GO

--------------------------
--Deleting Data:

DELETE FROM Students; 

TRUNCATE TABLE Students;

-----------------------------------------------
--Deleting a Table:

DROP TABLE Students;

-----------------------------------------------
-- Renaming a Database:

USE master;
GO

ALTER DATABASE learn_sql_server
SET SINGLE_USER -- forces all active users out of database so that no one is active in the DB while making the update
WITH ROLLBACK IMMEDIATE; -- cancels any active transaction
GO

--ALTER DATABASE learn_sql_server
--MODIFY NAME = '70-461-LearnSqlServer'; -- this will not work because it starts with a number; Need to have square brackets
--GO

ALTER DATABASE learn_sql_server
MODIFY NAME = [70-461-LearnSqlServer];
GO

ALTER DATABASE [70-461-LearnSqlServer]
SET MULTI_USER;
GO
-----------------------------------
--Create a New Database Table:

USE [70-461-LearnSqlServer]
GO

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'HR')
BEGIN
	EXEC('CREATE SCHEMA HR');
END
GO

IF OBJECT_ID('HR.Employees','U') IS NULL
BEGIN
	CREATE TABLE HR.Employees
	(
		Id INT IDENTITY(1,1),
		EmployeeNumber INT NOT NULL,
		EmployeeName NVARCHAR(100) NOT NULL
	)
END
GO

-- Adding an Employee:
--insert into HR.Employees values (
--	'Neeraj Nath',
--	12313); -- this will throw an error

insert into HR.Employees 
(EmployeeName, EmployeeNumber) 
values 
(
	'Neeraj Nath',
	12313
);

select * from hr.employees; -- case insensitive so works

-- helper queries:
SELECT * FROM sys.schemas
select * from sys.tables

----------------------------------------
-- # Declaring a variable in Sql Server:

----***---- Integers

declare @myVar as int = 2
set @myVar += 1

declare @myVar2 as int
set @myVar2 = 5
select @myVar as Result1,@myVar2 as Result2
GO

---

declare @smallIntValue smallint = -12

print @smallIntValue
go

--- 
declare @tinyIntValue tinyint = -1 -- error: Arithmetic overflow error for data type tinyint, value = -1. -- tinyint is unsigned
print @tinyIntValue
go

---
declare @tinyIntValue tinyint = 2
set @tinyIntValue -= 0.5
select @tinyIntValue as TinyValue --- round off to lowest integer value

set @tinyIntValue = 3.8
select @tinyIntValue as UpdatedTinyValue
go

-----
declare @value smallint
set @value = 20000
print @value
print '---------------------'
set @value = 200000
print @value
print '---------------------'
go

declare @value int
set @value = 200000
print @value
print '---------------------'
go

declare @value tinyint
set @value = 20000
print @value
print '---------------------'

----***---- Decimal/Numeric
-- Note: Decimal and Numeric are synonyms in sql server.

declare @numeric numeric(5,2) = 1123.2 -- error : Arithmetic overflow error converting numeric to data type numeric.
print @numeric
go

declare @numeric numeric(3,2) = 1.22
print @numeric
go

---
declare @numeric numeric(3,2) = 1.22
declare @decValue decimal(3,2)
set @decValue = @numeric
print @decValue							-- this would work fine, since both are the same
go

---
declare @num decimal(3) = 112.2
print @num -- this will omit the decimal part, but would not throw any error.
go

declare @num decimal(3) = 112.8
print @num -- this will omit the decimal part and round it off to the nearest number, but would not throw any error.
go

----***---- smallmoney and money
declare @moneyValue smallmoney = 113144124212412.14144144 -- will fail. Range of smallmoney: -214,748.3648 to 214,748.3647 
print @moneyValue
go

declare @moneyValue smallmoney = 212412.14144144 -- will fail. Range of smallmoney: -214,748.3648 to 214,748.3647 
print @moneyValue
go

declare @moneyValue smallmoney = 212412.1414 -- will fail. Range of smallmoney: -214,748.3648 to 214,748.3647 
print @moneyValue -- prints upto two decimal places.
select @moneyValue as MoneyVal -- prints fully upto 4 decimal places.
go

--Data type 					Range 																Storage
--money 		-922,337,203,685,477.5808 to 922,337,203,685,477.5807 (-922,337,203,685,477.58
--				to 922,337,203,685,477.58 for Informatica.
--				Informatica only supports two decimals, not four.) 									8 bytes
--
--smallmoney 	-214,748.3648 to 214,748.3647 														4 bytes


----***---- Float and Real
-- Note: Float(24) is basically Real

declare @var real = 1234.1244 --float(24)
select @var as realVal
go

declare @var real = 0.3 --float(24)
select @var as realVal
go

declare @var1 float = 0.1
declare @var2 float = 0.2
select @var1 + @var2 as total
go

declare @var1 float = 0.112
declare @var2 float = 0.224
select @var1 + @var2 as total
go


---------------------------------------------

-- Mathematical Functions:

declare @myVar as int = 2

select power(@myVar,3) as powerValue

select square(@myVar) as squareValue

select sqrt(@myVar) as sqrtRootValue

go

declare @decVar as decimal(5,2) = -123.12
select floor(@decVar) as floorValue
select ceiling(@decVar) as ceilingValue
select round(@decVar,0) as roundValue

set @decVar = -127.8
select round(@decVar,0) as roundValueCehck -- 0 refers to the first place after the decimal point
select round(@decVar,1) as roundValueCehck -- 1 refers to the second place after the decimal point

set @decVar = 127.8
select round(@decVar,0) as roundValue -- 0 refers to the first place after the decimal point
select round(@decVar,1) as roundValue -- 1 refers to the second place after the decimal point

set @decVar = 127.89
select round(@decVar,1) as roundValue -- always tries to get to the nearest value of the precision point used.
select round(@decVar,-1) as roundValue -- when (-ve) it refers to precision to the left of the decimal point
select round(@decVar,-2) as roundValue -- when (-ve) it refers to precision to the left of the decimal point
select round(@decVar,-3) as roundValue -- when (-ve) it refers to precision to the left of the decimal point
select round(@decVar,-4) as roundValue -- when (-ve) it refers to precision to the left of the decimal point
go

select pi() as piValue;
select exp(10) as expValue;

----
declare @signVar as decimal(5,3) = -1.898
select abs(@signVar) as absValue;
select sign(@signVar) as signValue;
go


--- 
select rand(2) as randomValue;
go

---- Converting between Data Types:

select 3/2 as value;

select 3.0/2 as value;

select 3/2.0 as value;

go

-- Implicit Conversion:
declare @myVar as decimal(5,2) = 3

select @myVar as intDecValue;
go

-- Explicit Conversion:

select convert(decimal(5,3),9) as convertedValue;

select convert(decimal(5,3),9)/2 as convertedValue;

select cast(convert(decimal(5,3),9)/2 as int) as convertedValue;


-- Original Statement:
select system_type_id, column_id, system_type_id / column_id as Calculation
from sys.all_columns

select system_type_id, column_id, cast(system_type_id as decimal) / column_id as Calculation
from sys.all_columns

select system_type_id, column_id, floor(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns

select system_type_id, column_id, ceiling(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns

select system_type_id, column_id, round(convert(decimal(7,2), system_type_id) / column_id, 1) as Calculation
from sys.all_columns


--

select top 10 system_type_id, column_id, cast(system_type_id as decimal) / column_id as Calculation
from sys.all_columns

select top 10 system_type_id, column_id, floor(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns

select top 10 system_type_id, column_id, ceiling(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns

select top 10 system_type_id, column_id, round(convert(decimal(7,2), system_type_id) / column_id, 1) as Calculation
from sys.all_columns


---- try_convert and try_cast:

select convert(tinyint, system_type_id * 2) , column_id, ceiling(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns -- error: Arithmetic overflow error for data type tinyint, value = 330.

select try_convert(tinyint, system_type_id * 2) , column_id, ceiling(cast(system_type_id as decimal) / column_id) as Calculation
from sys.all_columns
go

select cast(4 as tinyint) as Value;
select cast(286 as tinyint) as Value; -- error: Arithmetic overflow error for data type tinyint, value = 286.

select try_cast(286 as tinyint) as Value;
go
---- String data types:
--	CHAR -- work on ascii
--	VARCHAR -- work on ascii
--	NCHAR -- work on unicode
--	NVARCHAR -- work on unicode

-- Q. What does ASCII mean?
-- Q. What is Unicode?

declare @myCharacter as char(10);
set @myCharacter = 'random';
select @myCharacter as CharValue, len(@myCharacter) as CharLength, datalength(@myCharacter) as DataLen
go

declare @myCharacter as varchar(10);
set @myCharacter = 'random';
select @myCharacter as VarcharValue, len(@myCharacter) as VarcharLength, datalength(@myCharacter) as DataLen
go

-- Use of NCHAR and NVARCHAR:
declare @myCharacter as nchar(10); -- occupies double the bytes. -- So 10 would mean 20 bytes.
set @myCharacter = 'नीरज'; -- this would consider it as char and not nchar -- must provide N in the prefix
set @myCharacter = N'नीरज'; 
select 
	@myCharacter as CharValue, 
	len(@myCharacter) as CharLength, 
	datalength(@myCharacter) as DataLen
go

declare @myCharacter as nvarchar(10);
set @myCharacter = N'नीरज';;
select 
	@myCharacter as VarcharValue, 
	len(@myCharacter) as VarcharLength, 
	datalength(@myCharacter) as DataLen -- would occupy double the bytes
go

declare @oldChar as text; 
--text will be removed in future versions of sql server and should not be used. Also it is exactly same to varchar(max)
set @oldChar = 'Neeraj Nath is the name of a person who is alive but not kicking, trying his best but not succeeding'
select @oldChar as OldChar
go


------- String Functions:

SELECT ASCII('A') AS A, ASCII('B') AS B,   
ASCII('a') AS a, ASCII('b') AS b,  
ASCII(1) AS [1], ASCII(2) AS [2];

-- returns ascii values which are int

select char(2) as Check2Char
go

select char(12) as Check12Char
go

SELECT CHAR(65) AS [65], CHAR(66) AS [66],
CHAR(97) AS [97], CHAR(98) AS [98],
CHAR(49) AS [49], CHAR(50) AS [50];
--

DECLARE @document AS VARCHAR (64);

SELECT @document = 'Reflectors are vital safety' +
    ' components of your bicycle.';

SELECT CHARINDEX('bicycle', @document);
GO
--
DECLARE @document AS VARCHAR (64);

SELECT @document = 'Reflectors are vital safety' +
    ' components of your bicycle.';

SELECT CHARINDEX('vital', @document, 5);
SELECT CHARINDEX('vital', @document);
GO

-- query brought from AdventureWorks DB:
SELECT TOP (1000) [DepartmentID]
      ,[Name]
      ,[GroupName]
      ,[ModifiedDate]
  FROM [AdventureWorks2022].[HumanResources].[Department] Where GroupName like '%RESEARCH%' collate Latin1_General_CS_AS;
  go
 --
SELECT CONCAT ('Happy ', 'Birthday ', 11, '/', '25') AS Result;
go

CREATE TABLE #temp (
emp_name NVARCHAR(200) NOT NULL,
emp_middlename NVARCHAR(200) NULL,
emp_lastname NVARCHAR(200) NOT NULL
);

INSERT INTO #temp
VALUES ('Name', NULL, 'Lastname');

SELECT CONCAT (emp_name, emp_middlename, emp_lastname) AS Result
FROM #temp;

select * from #temp;
--
SELECT CONCAT_WS(' - ', database_id, recovery_model_desc, containment_desc) AS DatabaseInfo
FROM sys.databases;

------------------------****** NULL ******-------------------------------
declare @NullVar as INT
SELECT @NullVar as Value

SELECT @NullVar + 1 + 1 + 12 as UpdateValue

-------- JOINING STRINGS TOGETHER:

DECLARE @FirstName as NVARCHAR(10)
DECLARE @MiddleName as NVARCHAR(10)
DECLARE @LastName as NVARCHAR(10)

SET @FirstName = N'Neeraj';
--SET @MiddleName = N'Kumar';
SET @LastName = N'Nath';


SELECT @FirstName + 
	IIF(@MiddleName IS NULL, '', ' '+@MiddleName) +
	' '+@LastName

SELECT @FirstName + 
	CASE
		WHEN @MiddleName IS NULL
			THEN ''
			ELSE ' ' + @MiddleName
		END +
	' '+@LastName

SELECT @FirstName + 
COALESCE(' '+@MiddleName, '' )+
	' '+@LastName

SELECT CONCAT(@FirstName, ' '+@MiddleName, ' ', @LastName) -- null handled automatically -- do not need automatic handling


-------- JOINING STRING TO NUMBER:

SELECT 'The Number is:' + 4531; -- Fails due to Data Type Precedence Phenomena
GO
--Working statement:

Select 'The Number is:' + CAST(4531 as nvarchar) as NumberValue;

SELECT 'My Salary is: ' + FORMAT(1250000, 'C'); -- gives dollar here.
SELECT 'My Salary is: ' + FORMAT(1250000, 'C', 'en-IN') ; -- value/expression to format, type to implement: here currency, culture - english : India
SELECT 'My Salary is: ' + FORMAT(1250000, 'C', 'hi-IN') ;

----------Practice Based:
select LEN('NEERAJ')


select [name]
from sys.all_columns


select CONCAT([name] ,'A')
from sys.all_columns

select CONCAT([name] ,N'Ⱥ')
from sys.all_columns

select SUBSTRING([name],2,LEN([name]))
from sys.all_columns -- i wrote; works but not fundamentally correct.

--answer provided by tutor:
select substring([name],2,len([name])-1) as [name]
from sys.all_columns -- more correct

select SUBSTRING([name],0,LEN([name]))
from sys.all_columns -- works but not fundamentally correct.

--answer provided by tutor:
select substring([name],1,len([name])-1) as [name]
from sys.all_columns --more correct

--- Data Types: Date

DECLARE @myDate AS DATETIME2 = '2026-06-28 07:51:34.124'

SELECT @myDate as Today
GO

DECLARE @myDate AS DATETIME = '2026-06-28 07:51:34.124'

SELECT @myDate as Today -- using DateTime so accurate only to 1/3rd of a nanosecond. So third place will have 3,7,0
GO

DECLARE @myDate AS DATETIME2 = '20260628 07:51:34.124'
SELECT @myDate as DateToday
GO

DECLARE @myDate AS DATETIME2(2) = '20260628 07:51:34.124' -- goes to 7
SELECT @myDate AS DateToday,DATALENGTH(@myDate) AS BytesTaken 
GO

DECLARE @myDate AS DATETIME2(4) = '20260628 07:51:34.124' -- goes to 7
SELECT @myDate AS DateToday,DATALENGTH(@myDate) AS BytesTaken 
GO

DECLARE @myDate AS DATETIME2(6) = '20260628 07:51:34.124' -- goes to 7
SELECT @myDate AS DateToday,DATALENGTH(@myDate) AS BytesTaken 
GO

SELECT DATEFROMPARTS(2026,6,28) AS DateFromPartsNow

SELECT DATETIMEFROMPARTS(2026,6,28, 07, 51,34, 1267) AS DateTimeFromPartsNow -- fails
SELECT DATETIMEFROMPARTS(2026,6,28, 07, 51,34, 127) AS DateTimeFromPartsNow -- works

SELECT DATETIME2FROMPARTS(2026,6,28, 07, 51,34, 1267,3) AS DateTimeFromPartsNow ----fails
SELECT DATETIME2FROMPARTS(2026,6,28, 07, 51,34, 1267,5) AS DateTimeFromPartsNow -- works
SELECT DATETIME2FROMPARTS(2026,6,28, 07, 51,34, 12687,5) AS DateTimeFromPartsNow -- works

DECLARE @myDate AS DATETIME2(6) = '20260628 07:51:34.124'
--SELECT YEAR(@myDate) AS YearNow, MONTH(@myDate) AS MonthNow, DAY(@myDate) AS DayNow

SELECT DATEPART(YEAR, @myDate) as YearNow, DATEPART(MONTH, @myDate) as MonthNow, DATEPART(DAYOFYEAR, @myDate) as DayNow,
	   DATEPART(HOUR, @myDate) as HourNow, DATEPART(MINUTE, @myDate) as MinutesNow, DATEPART(SECOND, @myDate) as SecondsNow

SELECT DATEPART(YEAR, @myDate) as YearNow, DATEPART(MONTH, @myDate) as MonthNow, DATEPART(DAY, @myDate) as DayNow,
DATEPART(HOUR, @myDate) as HourNow, DATEPART(MINUTE, @myDate) as MinutesNow, DATEPART(SECOND, @myDate) as SecondsNow
SELECT DATENAME(WEEKDAY, GETDATE()) as NameOFday
GO

SELECT DATENAME(MONTH, GETDATE()) as NameOFday
GO

SELECT CURRENT_TIMESTAMP as NOWTIME -- Generic --Available to all sqls
SELECT GETDATE() as NOWTIME -- Created By MS. 
SELECT SYSDATETIME() as NOWTIME -- By MS. For higher precision

SELECT FORMAT(CONVERT(DATETIMEOFFSET,GETDATE()),'D','en-US') AS Offset
SELECT CONVERT(DATETIMEOFFSET,GETDATE()) AS Offset
SELECT CONVERT(DATETIMEOFFSET,SYSUTCDATETIME()) AS Offset
SELECT SYSUTCDATETIME()
SELECT SYSDATETIMEOFFSET()
SELECT CONVERT(DATETIMEOFFSET,SYSDATETIMEOFFSET()) AS Offset
SELECT CONVERT(DATETIMEOFFSET(2),SYSDATETIMEOFFSET()) AS Offset

SELECT TODATETIMEOFFSET(GETDATE(), '+05:30') as OFFSETTED;

SELECT SYSUTCDATETIME()
SELECT SWITCHOFFSET(SYSUTCDATETIME(), '+05:30') as IST;


DECLARE @myDate AS DATETIME2 = '2026-06-28 04:05:03.7109948'

--SELECT @myDate as NowDate

--SELECT 'The Time now is' + @myDate; -- fails

SELECT 'The Time now is: ' + CONVERT(NVARCHAR(20),@myDate);
SELECT 'The Time now is: ' + CAST(@myDate AS NVARCHAR(20));

SELECT CONVERT(DATE, 'Sunday, 28 June 2026'); --fails
--so we have parse
SELECT PARSE('Sunday, 28th June 2026' AS DATE); --fails
SELECT PARSE('Sunday, 28 June 2026' AS DATE); --Works

SELECT FORMAT(CAST('2026-06-28 04:20:02.1692338' AS DATETIME2),'D')
SELECT FORMAT(CAST('2026-06-28 04:20:02.1692338' AS DATETIME2),'d')
SELECT FORMAT(CAST('2026-06-28 04:20:02.1692338' AS DATETIME2),'dd-MM-YYYY') -- provides incorrect response. Check where?
SELECT FORMAT(CAST('2026-06-28 04:20:02.1692338' AS DATETIME2),'dd-MM-yyyy') -- works
 --Read about 104 and other such design formats


