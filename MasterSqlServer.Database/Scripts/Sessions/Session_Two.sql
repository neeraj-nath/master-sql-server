CREATE TABLE tblEmployee
(
	EmployeeNumber			INT NOT NULL,
	EmployeeFirstName		NVARCHAR(50) NOT NULL,
	EmployeeMiddleName		NVARCHAR(20),
	EmployeeLastName		NVARCHAR(50) NOT NULL,
	EmployeeGovernmentId	CHAR(10) NULL,
	DateOfBirth				DATE NOT NULL
);

--ALTER TABLE tblEmployee
--	ADD COLUMN Department NVARCHAR(10); -- Not Correct. --Column name after add is not correct.

ALTER TABLE tblEmployee ADD Department NVARCHAR(10)

ALTER TABLE tblEmployee
ALTER COLUMN Department NVARCHAR(30)


SELECT * FROM tblEmployee;

INSERT INTO tblEmployee
(EmployeeNumber, EmployeeFirstName,EmployeeLastName,EmployeeGovernmentId,DateOfBirth, Department)
VALUES
(123,'Jane','Zwilling','AB123456G','01-01-1985','Commercial')


INSERT INTO tblEmployee
VALUES
(132,'Dylan','A','Word','HN513777D','19920914','Customer Relations');


-- Important finding is that if we have data in excel format and we need that inserted into our db
-- we can simply copy that excel data, go to ssms and click EDIT TOP 200 rows for that table where we want to insert the data
-- data and paste it there
-- insert of manually writing the data in insert statements.

SELECT * FROM tblEmployee WHERE [EmployeeLastName] = 'Word';
SELECT * FROM tblEmployee WHERE [EmployeeLastName] != 'Word';
SELECT * FROM tblEmployee WHERE [EmployeeLastName] <> 'Word';
SELECT * FROM tblEmployee WHERE [EmployeeLastName] < 'Word' ORDER BY EmployeeLastName; -- alphabetical order check followed.


SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE 'W%';
SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '%W'; -- case insensitive. 
--Check properties for the column by right clicking on object explorer.

SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '_W%'; --that is there should be one letter before W.

SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '[r-t]%'; --LastName should begin from any letter from r to t
-- if wish to, can also write it as "rst" instead of "r-t"

--SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '^[r-t]%'; --LastName should begin from any letter from r to t
--SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '^[rst]%';

SELECT * FROM tblEmployee WHERE [EmployeeLastName] LIKE '[^r-t]%';

SELECT * FROM tblEmployee WHERE [EmployeeNumber] > 200;

SELECT * FROM tblEmployee WHERE NOT [EmployeeNumber] > 200;

SELECT * FROM tblEmployee WHERE [EmployeeNumber] >= 200 AND EmployeeNumber <= 209;

SELECT * FROM tblEmployee WHERE NOT ([EmployeeNumber] >= 200 AND EmployeeNumber <= 209);

SELECT * FROM tblEmployee WHERE EmployeeNumber BETWEEN 200 AND 209; --Inclusive range --200 and 209 also will be included in the result.

SELECT * FROM tblEmployee WHERE EmployeeNumber IN (200,209,204);

-- 

SELECT * FROM tblEmployee ORDER BY DateOfBirth;
SELECT * FROM tblEmployee WHERE DateOfBirth BETWEEN '19651218' AND '19660212'


SELECT * FROM tblEmployee
WHERE YEAR(DateOfBirth) BETWEEN 1965 AND 1976

SELECT YEAR(DateOfBirth) AS YearOfBirth, COUNT(*) AS Births FROM tblEmployee
-- ERROR: Column 'tblEmployee.DateOfBirth' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

SELECT YEAR(DateOfBirth) AS YearOfBirth, COUNT(*) AS Births FROM tblEmployee GROUP BY Year(DateOfBirth)

SELECT YEAR(DateOfBirth) AS YearOfBirth, COUNT(*) AS Births FROM tblEmployee GROUP BY Year(DateOfBirth)

SELECT YEAR(DateOfBirth) AS YearOfBirth, COUNT(*) AS Births FROM tblEmployee GROUP BY Year(DateOfBirth) ORDER BY YEAR(DateOfBirth) DESC

-- NOTE from actual DB work that I am doing on. These computation of calculating YEAR(), DAY() on the Fly
-- Is expensive to the DB on the basis of resource exhaustion. So these are considered as NON SARGable predicament
-- and should be used wisely.

----- DATE: 8/7/2026

SELECT * FROM tblEmployee;

SELECT SUBSTRING(EmployeeLastName,1,1), COUNT(*) FROM tblEmployee GROUP BY SUBSTRING(EmployeeLastName,1,1);

SELECT EmployeeLastName, RIGHT(EmployeeLastName,4) FROM tblEmployee;

SELECT LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS FROM tblEmployee GROUP BY LEFT(EmployeeLastName,1);

SELECT LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
	FROM tblEmployee 
	GROUP BY LEFT(EmployeeLastName,1)
	ORDER BY LEFT(EmployeeLastName,1);

SELECT LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
	FROM tblEmployee 
	GROUP BY LEFT(EmployeeLastName,1)
	ORDER BY COUNT(*) DESC;

SELECT TOP(5) LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
FROM tblEmployee 
GROUP BY LEFT(EmployeeLastName,1)
ORDER BY COUNT(*) DESC;

--SELECT TOP(5) LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
--FROM tblEmployee 
--GROUP BY LEFT(EmployeeLastName,1)
--ORDER BY COUNT(*) DESC
--HAVING COUNT(*) > 49; --Incorrect syntax -- Order by should come last

SELECT LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
FROM tblEmployee 
GROUP BY LEFT(EmployeeLastName,1)
HAVING COUNT(*) > 49
ORDER BY COUNT(*) DESC; 

SELECT LEFT(EmployeeLastName,1) AS InitialSurname, COUNT(*) AS COUNTS 
FROM tblEmployee 
GROUP BY LEFT(EmployeeLastName,1)
HAVING COUNT(*) > 49
ORDER BY COUNTS; -- Order by runs after Select so we can USE the ALIAS.

SELECT * FROM tblEmployee WHERE EmployeeMiddleName = '';

UPDATE tblEmployee 
	SET EmployeeMiddleName = NULL
WHERE EmployeeMiddleName = '';

--*** Syntax order
------SELECT
------FROM 
------WHERE
------GROUP BY
------HAVING 
------ORDER BY

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE '%Employee%';

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tblEmployee';

SELECT MONTH(DateOfBirth), COUNT(*)
FROM tblEmployee
GROUP BY MONTH(DateOfBirth)

SELECT DATEPART(MONTH,DateOfBirth), COUNT(*)
FROM tblEmployee
GROUP BY DATEPART(MONTH,DateOfBirth)

SELECT DATENAME(MONTH,DateOfBirth), COUNT(*)
FROM tblEmployee
GROUP BY DATENAME(MONTH,DateOfBirth)
ORDER BY DATEPART(MONTH,DateOfBirth) -- we cannot order by a clause which is not part of the select statement

-- 09/07/2026

SELECT DATENAME(MONTH,DateOfBirth), COUNT(*) AS NumberOfEmployees
FROM tblEmployee
GROUP BY DATENAME(MONTH,DateOfBirth), DATEPART(MONTH,DateOfBirth)
ORDER BY DATEPART(MONTH,DateOfBirth) -- this would now work.


SELECT COUNT(*) FROM tblEmployee
WHERE EmployeeMiddleName IS NOT NULL;

SELECT DATENAME(MONTH,DateOfBirth), COUNT(*) AS NumberOfEmployees, COUNT(EmployeeMiddleName) AS NumberOfMiddleNames,
COUNT(*) - COUNT(EmployeeMiddleName) AS NoMiddleName -- this helps us get the count of Employees without the MiddleName
FROM tblEmployee
GROUP BY DATENAME(MONTH,DateOfBirth), DATEPART(MONTH,DateOfBirth)
ORDER BY DATEPART(MONTH,DateOfBirth) -- this would now work.


SELECT DATENAME(MONTH,DateOfBirth), COUNT(*) AS NumberOfEmployees, COUNT(EmployeeMiddleName) AS NumberOfMiddleNames,
COUNT(*) - COUNT(EmployeeMiddleName) AS NoMiddleName, -- this helps us get the count of Employees without the MiddleName
MIN(DateOfBirth) AS EarliestDateOfBirth, MAX(DateOfBirth) AS LatestDateOfBirth -- Min and Max does not need to be in the GROUP BY clause
FROM tblEmployee
GROUP BY DATENAME(MONTH,DateOfBirth), DATEPART(MONTH,DateOfBirth)
ORDER BY DATEPART(MONTH,DateOfBirth) -- this would now work.

----**** Adding a Second Table:

-- Requirement is to create a Transaction table:
---- Fields that would be needed :
		---- Amount  NUMERIC/DECIMAL -- should we use MONEY?? Not recommended. Use DECIMAL/NUMERIC
		---- DateOfTransaction		 -- DATETIME2 
		---- EmployeeNumber		     -- Foreign Key Relationship to tblEmployee -- Currently tblEmployee does not EmployeeNumber as fully unique. -- INT
		----  

----  What are Slowly Changing Dimensions - SCD?

SELECT EmployeeNumber, COUNT(*) FROM tblEmployee GROUP BY EmployeeNumber HAVING COUNT(*) > 1; -- 132, 123
USE [70-461-LearnSqlServer]
GO


select max(EmployeeNumber) from dbo.tblEmployee

select max(EmployeeNumber),year(DateOfBirth) from dbo.tblEmployee group by year(DateOfBirth)
/****** Object:  Table [dbo].[tblTransaction]    Script Date: 09-07-2026 08:53:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

USE [70-461-LearnSqlServer]

CREATE TABLE [dbo].[tblTransaction](
	[TransactionId] INT PRIMARY KEY IDENTITY(1,1),
	[Amount] DECIMAL(18,2) NOT NULL,
	[DateOfTransaction] DATETIME2 NOT NULL,
	[EmployeeNumber] INT NOT NULL,
) 
GO -- Employee Number should have been FK'd but this was not in the initial creation -- so have to alter the table to add the FK reference.
	--- Quick Update: Since there is no Identity implemented on TransactionId I would have to provide TransactionId explicitly when trying to insert values.
	--- Also Identity cannot be inserted later by altering the table. So we would need to drop the table and recreate it with Identity.

--DROP TABLE dbo.tblTransaction



--========== The following code to be run later in the course: =================================
--ALTER TABLE [dbo].[tblTransaction]
--WITH CHECK
--ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber
--FOREIGN KEY (EmployeeNumber)
--REFERENCES dbo.tblEmployee(EmployeeNumber) -- this currently fails. Why?
--There are no primary or candidate keys in the referenced table 'dbo.tblEmployee' that match the referencing column list in the 
--foreign key 'FK_tblTransaction_tblEmployee_EmployeeNumber'.

--Could not create constraint or index. See previous errors.

-- Answer to the Why?
-- The column that the FK references to has to be either a UNIQUE Key or PRIMARY Key of that table.
-- Thus the Error.


INSERT INTO [dbo].[tblTransaction]
([Amount], [DateOfTransaction], [EmployeeNumber])
VALUES
(-964.05, '20150526', 658), 
(-105.23, '20150914', 987), 
(-506.8, '20150505', 695);


select count(*) from dbo.tblTransaction;
select distinct(EmployeeNumber) from dbo.tblTransaction;
select count(distinct(EmployeeNumber)) from dbo.tblTransaction;
select count(EmployeeNumber) from dbo.tblTransaction group by EmployeeNumber having Count(EmployeeNumber) > 1 order by count(EmployeeNumber) ;
--truncate table dbo.tblTransaction;

--******************** JOINS **********************


-- Basic Way to write the query:
SELECT * FROM dbo.tblEmployee
JOIN dbo.tblTransaction
ON dbo.tblEmployee.EmployeeNumber = dbo.tblTransaction.EmployeeNumber

--
SELECT 
	te.EmployeeNumber,
	te.EmployeeFirstName,
	te.EmployeeLastName,
	tt.Amount
FROM
	dbo.tblEmployee te
INNER JOIN 
	dbo.tblTransaction tt
ON te.EmployeeNumber = tt.EmployeeNumber

--
SELECT 
	te.EmployeeNumber,
	te.EmployeeFirstName,
	te.EmployeeLastName,
	SUM(tt.Amount) AS TotalTransactionAmount
FROM
	dbo.tblEmployee te
INNER JOIN 
	dbo.tblTransaction tt
ON te.EmployeeNumber = tt.EmployeeNumber
GROUP BY te.EmployeeNumber,	te.EmployeeFirstName, te.EmployeeLastName

--- Does EmployeeNumber = 1046 exist in the above JOINed query?

SELECT 
	te.EmployeeNumber,
	te.EmployeeFirstName,
	te.EmployeeLastName,
	SUM(tt.Amount) AS TotalTransactionAmount
FROM
	dbo.tblEmployee te
INNER JOIN 
	dbo.tblTransaction tt
ON te.EmployeeNumber = tt.EmployeeNumber
Where te.EmployeeNumber = 1046
GROUP BY te.EmployeeNumber,	te.EmployeeFirstName, te.EmployeeLastName;

-- Is 1046 a valid EmployeeNumber existing in the tblEmployee?
select * from dbo.tblEmployee where EmployeeNumber = 1046; -- So 1046 is a valid employee as it exists in the table.

-- LEFT JOIN

SELECT 
	te.EmployeeNumber,
	te.EmployeeFirstName,
	te.EmployeeLastName,
	SUM(tt.Amount) AS TotalTransactionAmount
	INTO #LeftEmpTransaction
FROM
	dbo.tblEmployee te --left table
LEFT JOIN -- everything from the left table will become part of the joined table.
			-- if the corresponding data for any row is not available in the right table, it will be populated with NULLs.
	dbo.tblTransaction tt -- right table
ON te.EmployeeNumber = tt.EmployeeNumber
GROUP BY te.EmployeeNumber,	te.EmployeeFirstName, te.EmployeeLastName
order by te.EmployeeNumber;

select * from #LeftEmpTransaction where EmployeeNumber = 1046;
select * from #LeftEmpTransaction where TotalTransactionAmount IS NULL;

--RIGHT JOIN: 
SELECT 
	te.EmployeeNumber,
	te.EmployeeFirstName,
	te.EmployeeLastName,
	SUM(tt.Amount) AS TotalTransactionAmount
FROM
	dbo.tblEmployee te --left table
RIGHT JOIN -- everything from the RIGHT table will become part of the joined table.
			-- if the corresponding data for any row is not available in the LEFT table, it will be populated with NULLs.
	dbo.tblTransaction tt -- right table
ON te.EmployeeNumber = tt.EmployeeNumber
GROUP BY te.EmployeeNumber,	te.EmployeeFirstName, te.EmployeeLastName
order by te.EmployeeNumber;

--******** Question :  How can we see the distinct Departments from the tblEmployee??
select Department from dbo.tblEmployee

-- OPTION 1 :- Getting the Distinct DEPARTMENTs using a Derived Table:
SELECT Department
FROM 
(
	SELECT Department, Count(*) As DepartmentCount --Error: No column name was specified for column 2 of 'Table_New'.
	FROM dbo.tblEmployee 
	GROUP BY Department
) AS Table_New -- Derived table must be alias'd

-- OPTION 2: Using the keyword DISTINCT:

select DISTINCT Department from dbo.tblEmployee

select DISTINCT Department, EmployeeGovernmentId from dbo.tblEmployee -- here DISTINCT applies on the combination of the two columns.

CREATE TABLE [dbo].[tblDepartment](
	DepartmentId INT PRIMARY KEY IDENTITY(1,1),
	Department NVARCHAR(30) NOT NULL,
	DepartmentHead NVARCHAR(30) NULL)

INSERT INTO [dbo].[tblDepartment]
(
	Department
)
SELECT DISTINCT Department from dbo.tblEmployee;

select * from dbo.tblDepartment

---- the old syntax:
-- this is a cross join on top of which the where filter is applied.
-- this is not considered a good practice anymore.
select * from tblDepartment, tblEmployee
where tblDepartment.Department = tblEmployee.Department

---
select * 
from dbo.tblDepartment td
join tblEmployee te
on td.Department = te.Department

---

select * 
from dbo.tblDepartment td
join tblEmployee te
on td.Department = te.Department
join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber

---
select * 
from dbo.tblDepartment td
left join tblEmployee te
on td.Department = te.Department
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber

----###

select * from dbo.tblDepartment


select td.DepartmentId, td.Department, SUM(tt.Amount) as TotalTransactionAmountPerDepartment
from dbo.tblDepartment td
left join tblEmployee te
on td.Department = te.Department
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
group by td.DepartmentId, td.Department
order by td.DepartmentId;

select * from dbo.tblDepartment

select td.DepartmentId, td.Department, td.DepartmentHead, SUM(tt.Amount) as TotalTransactionAmountPerDepartment
from dbo.tblDepartment td
left join tblEmployee te
on td.Department = te.Department
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
group by td.DepartmentId, td.Department, td.DepartmentHead
order by td.DepartmentId;

select td.DepartmentHead, SUM(tt.Amount) as TotalTransactionAmountPerDepartment
from dbo.tblDepartment td
left join tblEmployee te
on td.Department = te.Department
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
group by td.DepartmentHead;

---------------
select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
from tblEmployee te
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber 
order by ENumber;


select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
from tblEmployee te
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
where tt.EmployeeNumber IS NULL 
group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber 
order by ENumber;

--CHECK INTO THE BELOW QUERY..
--select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
--from dbo.tblDepartment td
--left join tblEmployee te
--on td.Department = te.Department
--left join tblTransaction tt
--on te.EmployeeNumber = tt.EmployeeNumber
--where tt.EmployeeNumber = NULL --this one does not work, why??
--group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber 
--order by ENumber;

-- we can implement the above join query in a derived table format as well which is hown below:

SELECT * FROM
(select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
from tblEmployee te
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber ) as s
where TNumber IS NULL 
order by ENumber;

select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
from  tblEmployee te
left join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
where tt.EmployeeNumber IS NULL 
group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber 
order by ENumber;

----
select te.EmployeeNumber as ENumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber as TNumber, SUM(tt.Amount) AS TotalTransactionAmount
from  tblEmployee te
right join tblTransaction tt
on te.EmployeeNumber = tt.EmployeeNumber
where te.EmployeeNumber IS NULL 
group by te.EmployeeNumber, te.EmployeeFirstName, te.EmployeeLastName, tt.EmployeeNumber 
order by ENumber;

----***** Delete those transaction which are not assigned to a real Employee ****----
DELETE t
from tblEmployee e
right join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where e.EmployeeNumber IS NULL

select * from tblTransaction

--==============

select * from tblEmployee Where EmployeeNumber = 194
select * from tblEmployee Where EmployeeNumber = 123
select * from tblTransaction Where EmployeeNumber = 123
select * from tblTransaction Where EmployeeNumber = 194

select * from tblTransaction order by EmployeeNumber --123
---

begin transaction

select * from tblTransaction Where EmployeeNumber = 194

update tblTransaction
set EmployeeNumber = 194
where EmployeeNumber = 123

select * from tblTransaction Where EmployeeNumber = 194

rollback transaction

----

begin transaction

	--select * from tblTransaction Where EmployeeNumber = 194

	update tblTransaction
	set EmployeeNumber = 194
	output inserted.* , deleted.*
	where EmployeeNumber = 123

	--select * from tblTransaction Where EmployeeNumber = 194

rollback transaction