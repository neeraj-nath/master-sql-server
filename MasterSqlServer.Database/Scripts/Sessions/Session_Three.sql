select * from tblEmployee

Select t.EmployeeNumber as TransactionEmployeeNumber,
     e.EmployeeNumber as EmployeeNumber,
     sum(Amount) as SumAmount
from tblTransaction as t
left join tblEmployee as e
on t.EmployeeNumber = e.EmployeeNumber
group by t.EmployeeNumber, e.EmployeeNumber
order by EmployeeNumber


--***** CONSTRAINTS *****

---- Unique Constraints
ALTER TABLE tblEmployee
ADD CONSTRAINT UQ_Employee_EmployeeGovernmentId UNIQUE ([EmployeeGovernmentId])
-- Error: The CREATE UNIQUE INDEX statement terminated because a duplicate key was found for the object name 'dbo.tblEmployee' 
          -- and the index name 'UQ_Employee_EmployeeGovernmentId'. The duplicate key value is (AB123456G ).

SELECT * FROM tblEmployee WHERE EmployeeGovernmentId = 'AB123456G'

DELETE FROM tblEmployee WHERE EmployeeGovernmentId = 'AB123456G' AND Department = 'HR'

--- Adding UNIQUE Constraint to Multitude of Columns:
ALTER TABLE tblTransaction
ADD CONSTRAINT UQ_Transaction_Amount_Date_EmpNumber UNIQUE (Amount, DateOfTransaction, EmployeeNumber)

-- How do we add constraint when creating a new table: -- temp table to be deleted/dropped later
create table tblTransactionTemp(
     [TransactionId] [int] IDENTITY(1,1) NOT NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[DateOfTransaction] [datetime2](7) NOT NULL,
	[EmployeeNumber] [int] NOT NULL
     
     constraint UQ_TransactionTemp_Amount_Date_EmpNumber unique (Amount, DateOfTransaction, EmployeeNumber)
)
    
insert into tblTransactionTemp
(Amount, DateOfTransaction, EmployeeNumber)
values(100,'2024-06-10',123)

Drop table tblTransactionTemp

---- DEFAULT CONSTRAINT

ALTER TABLE tblTransaction
ADD CreatedDate DATETIME2

ALTER TABLE tblTransaction
ADD CONSTRAINT DF_Transaction_CreatedDate DEFAULT(SYSDATETIME()) FOR CreatedDate

insert into tblTransaction
(Amount, DateOfTransaction, EmployeeNumber)
values(100,'2024-06-10',123) -- this will take the default SYSDATETIME since we are not providing any explicit value to insert

select * from tblTransaction where EmployeeNumber = 1111

insert into tblTransaction
(Amount, DateOfTransaction, EmployeeNumber, CreatedDate)
values(100,'2024-06-10',1111, null) -- this will also work -- since we are giving a value to insert explicitly

-- lets drop the column
ALTER TABLE tblTransaction
DROP COLUMN CreatedDate; -- Error : The object 'DF_Transaction_CreatedDate' is dependent on column 'CreatedDate'.
                              --    ALTER TABLE DROP COLUMN CreatedDate failed because one or more objects access this column.

-- Need to first drop the constraint f we wish to drop the column
ALTER TABLE tblTransaction
DROP CONSTRAINT DF_Transaction_CreatedDate

-- now the above drop column would work without any error
ALTER TABLE tblTransaction
DROP COLUMN CreatedDate; 

--- CHECK CONSTRAINT
ALTER TABLE tblTransaction
ADD CONSTRAINT CK_Transaction_DateOfTransaction CHECK(DateOfTransaction <= SYSDATETIME())

insert into tblTransaction
(Amount, DateOfTransaction, EmployeeNumber)
values(100,'2024-06-10',8989) 

insert into tblTransaction
(Amount, DateOfTransaction, EmployeeNumber)
values(100,'2027-06-10',8989) -- this would fail
-- Error: The INSERT statement conflicted with the CHECK constraint "CK_Transaction_DateOfTransaction". 
     --The conflict occurred in database "70-461-LearnSqlServer", table "dbo.tblTransaction", column 'DateOfTransaction'.

-- select 'true' where null = null
CREATE TABLE DtCreation (
     CreateDt DateTime2 CONSTRAINT CK_DtCreation_CreateDt CHECK (CreateDt <= GETDATE())
)
  
INSERT INTO DtCreation 
VALUES(SYSDATETIME())

SELECT * FROM DtCreation

INSERT INTO DtCreation 
VALUES(DATEADD(DAY,2,SYSDATETIME())) --would fail

DROP TABLE DtCreation

-- --
CREATE TABLE DtCreation (
     CreateDt DateTime2 CHECK (CreateDt <= GETDATE()) -- sql server would generate a name on its own
)
 
--- PRIMARY KEY

CREATE TABLE dbo.EmployeeTemp (
     Id INT PRIMARY KEY IDENTITY(1,1) -- sql server would generate a name on its own --IDENITY cannot be created by ALTER approach
)

DROP TABLE dbo.EmployeeTemp

CREATE TABLE dbo.EmployeeTemp (
     Id INT CONSTRAINT PK_EmployeeTemp_Id PRIMARY KEY IDENTITY(1,1) -- sql server would generate a name on its own --IDENITY cannot be created by ALTER approach
     ,EmployeeName NVARCHAR(100) NOT NULL
)

INSERT INTO dbo.EmployeeTemp
VALUES ('Neeraj');
 
SELECT * FROM dbo.EmployeeTemp

INSERT INTO dbo.EmployeeTemp
VALUES (5,'John'); -- Error: An explicit value for the identity column in table 'dbo.EmployeeTemp' can only be specified when a column list is used and IDENTITY_INSERT is ON.

SET IDENTITY_INSERT dbo.EmployeeTemp ON

INSERT INTO dbo.EmployeeTemp
VALUES (5,'John'); -- Same error as above

INSERT INTO dbo.EmployeeTemp(Id,EmployeeName)
VALUES (5,'John'); -- Error: Cannot insert explicit value for identity column in table 'EmployeeTemp' when IDENTITY_INSERT is set to OFF.

SET IDENTITY_INSERT dbo.EmployeeTemp ON -- set on

INSERT INTO dbo.EmployeeTemp(Id,EmployeeName)
VALUES (5,'John'); -- Works

INSERT INTO dbo.EmployeeTemp
VALUES ('Jason'); -- Error: Explicit value must be specified for identity column in table 'EmployeeTemp' either when IDENTITY_INSERT is set to ON 
                              --or when a replication user is inserting into a NOT FOR REPLICATION identity column.

INSERT INTO dbo.EmployeeTemp(EmployeeName)
VALUES ('Jason');


-- to fetch the last identity value used
SELECT @@IDENTITY
SELECT SCOPE_IDENTITY()
SELECT IDENT_CURRENT('dbo.EmployeeTemp')

--- FOREIGN KEY:

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ALTER TABLE tblTransaction
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber) --Error: There are no primary or candidate keys in the referenced table 'dbo.tblEmployee' 
                                                  --that match the referencing column list in the foreign key 'FK_tblTransaction_tblEmployee_EmployeeNumber'.

ALTER TABLE dbo.tblEmployee 
ADD CONSTRAINT PK_tblEmployee_EmployeeNumber PRIMARY KEY (EmployeeNumber)

SELECT * FROM dbo.tblEmployee where EmployeeNumber = 132

DELETE TOP(1) FROM dbo.tblEmployee WHERE EmployeeNumber = 132

SELECT * FROM dbo.tblEmployee where EmployeeNumber = 124

-- checking the following queries using transaction
-- so that we do not need to undo the changes explicitly
BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL -- since it is set to not Null on creation of table

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)

UPDATE tblEmployee SET EmployeeNumber = 9123 WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION

-- theb above transaction would give us the following error:
---- The UPDATE statement conflicted with the REFERENCE constraint "FK_tblTransaction_tblEmployee_EmployeeNumber". 
---- The conflict occurred in database "70-461-LearnSqlServer", table "dbo.tblTransaction", column 'EmployeeNumber'.

------------
BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL -- since it is set to not Null on creation of table

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE CASCADE -- when changes would be done to the EmployeeNumber in tblEmployee the changes would reflect in the tblTransaction table as well

UPDATE tblEmployee SET EmployeeNumber = 9123 WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION

----------
BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL -- since it is set to not Null on creation of table

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE SET NULL -- the tableTransaction where we have the Foreign Key - the column will set to NULL

UPDATE tblEmployee SET EmployeeNumber = 9123 WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION
----------

BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL -- since it is set to not Null on creation of table

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber -- default configured here

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE SET DEFAULT -- the tableTransaction where we have the Foreign Key - the column will set to the DEFAULT value

UPDATE tblEmployee SET EmployeeNumber = 9123 WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION
---------

BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL -- since it is set to not Null on creation of table

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE CASCADE
--/ we can write ON DELETE NO ACTION which is anyways the default case when we do not write anything

DELETE tblEmployee WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION
---------

BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL 

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE CASCADE
ON DELETE CASCADE

DELETE tblEmployee WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION
---------

BEGIN TRANSACTION

ALTER TABLE tblTransaction ALTER COLUMN EmployeeNumber INT NULL 

ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction_EmployeeNumber DEFAULT 124 FOR EmployeeNumber

ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_tblEmployee_EmployeeNumber FOREIGN KEY (EmployeeNumber)
REFERENCES dbo.tblEmployee(EmployeeNumber)
ON UPDATE CASCADE
--ON DELETE SET NULL
ON DELETE SET DEFAULT

DELETE tblEmployee WHERE EmployeeNumber = 123

select e.EmployeeNumber, t.*
from dbo.tblEmployee e
right join dbo.tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.Amount in (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRANSACTION
---------

-----------================ VIEWS:

select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
order by d.Department, t.EmployeeNumber

--we can create a view for the top requirement using the following sql query:
go --without the GO we were seeing the following error: Incorrect syntax: 'CREATE VIEW' must be the only statement in the batch.
CREATE VIEW ViewByDepartment AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
order by d.Department, t.EmployeeNumber -- Error : The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions,
                                                  -- unless TOP, OFFSET or FOR XML is also specified.

GO

--We can resolve the error by a walk around by simply adding TOP(100) percent to the Create view syntax:
CREATE VIEW ViewByDepartment AS
select TOP(100) PERCENT d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
order by d.Department, t.EmployeeNumber

GO

select * from ViewByDepartment

-- But the best approach is to remove the ORDER BY Clause from the CREATE VIEW Statement:
DROP VIEW ViewByDepartment

GO

CREATE VIEW ViewByDepartment AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
--order by d.Department, t.EmployeeNumber 
GO

-- DROP and ALTER View

GO
ALTER VIEW [dbo].[ViewByDepartment] AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
--order by d.Department, t.EmployeeNumber 
GO

DROP VIEW dbo.ViewByDepartment

GO
ALTER VIEW [dbo].[ViewByDepartment] AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
--order by d.Department, t.EmployeeNumber 
GO -- this will fail since the View has been dropped already. So we can use the CREATE OR ALTER

GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartment] AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
--order by d.Department, t.EmployeeNumber 
GO

-- Securing a View:

SELECT * FROM sys.syscomments
SELECT * FROM sys.views

SELECT v.name, sc.text
FROM sys.syscomments sc
JOIN sys.views v
ON sc.id = v.object_id

select OBJECT_DEFINITION(OBJECT_ID('dbo.ViewByDepartment'))

select * FROM sys.sql_modules where object_id = OBJECT_ID('dbo.ViewByDepartment')

---- All the above queries are providing us the definition of the View --
---- thus the View is not secured because any user can find themselves the underlying definition of the view or any view. 

-- When we secure the View -- even we will not be able to check its definition -- so it will be secured even for us.

GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartment] WITH ENCRYPTION AS
select d.Department, t.EmployeeNumber as EmpNum, SUM(t.Amount) AS TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
group by d.Department, t.EmployeeNumber
--order by d.Department, t.EmployeeNumber 
GO

---- Verify either any one of the above queries provides us the definition or not.
-- we would see a  NULL definition
-- it still is not 100% secured -- we can still get it but it requires us to dive deep down into the core.

------ What is Chaining???


----- Inserting new rows to Views -- that is inserting more data into the View 

GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where e.EmployeeNumber BETWEEN 120 AND 139
-- group by d.Department, t.EmployeeNumber

--order by d.Department, t.EmployeeNumber 
GO

select OBJECT_DEFINITION(OBJECT_ID('dbo.ViewByDepartmentForEmployees'))

BEGIN TRANSACTION

INSERT INTO ViewByDepartmentForEmployees (Department, EmployeeNumber, DateOfTransaction, TotalAmount)
VALUES('Software R&D',132,'2026-01-26',999.99);

select * from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction

ROLLBACK TRANSACTION

--- Error we would get in the above query: 
--------- View or function 'ViewByDepartmentForEmployees' is not updatable because the modification affects multiple base tables.

BEGIN TRANSACTION

INSERT INTO ViewByDepartmentForEmployees (EmployeeNumber, DateOfTransaction, TotalAmount)
VALUES(132,'2026-01-26',999.99);

select * from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction

ROLLBACK TRANSACTION -- this will work because inserting data to the same base table via the view is allowed

---- Updating in view

----------------======================= There are issues in the below code ========================
------ Based on the design of the VIEW:
               --GO
               -- CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
               -- select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
               -- from tblDepartment as d
               -- left join tblEmployee e
               -- on d.Department = e.Department
               -- left join tblTransaction t
               -- on e.EmployeeNumber = t.EmployeeNumber
               -- where e.EmployeeNumber BETWEEN 120 AND 139
               -- -- group by d.Department, t.EmployeeNumber

               -- --order by d.Department, t.EmployeeNumber 
               -- GO

               -- -- ** I am selecting the EmployeeNumber from the tblTransaction but the where clause is checked upon the tblEmployee.EmployeeNumber

------------------- Understand the issues in detail:
BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
-- select * from ViewByDepartmentForEmployees where EmployeeNumber = 132 order by EmployeeNumber, DateOfTransaction 
select count(*) from ViewByDepartmentForEmployees 
select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 132
-- SELECT * from tblTransaction where EmployeeNumber in (132,142)

update ViewByDepartmentForEmployees
set EmployeeNumber = 142
where EmployeeNumber = 132
---- What I updated is the tblTransaction.EmployeeNumber
---- But as we are applying the where clause on the tblEmployee.EmployeeNumber thus we do not see the changes correctly
---- We see 5 rows being affected which is correct.
---- but as we are applying the clause on tblEmployee.EmployeeNumber we see 30 rows. because tblEmployee.EmployeeNumber not updated.

select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
select count(*) from ViewByDepartmentForEmployees
-- select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 142

----- Debuggind the difference to understand better where is the issue.
select * From #TempTblView_New
EXCEPT
SELECT * from #TempTblView_Old

SELECT * from #TempTblView_Old
EXCEPT
select * From #TempTblView_New
ROLLBACK TRAN

EXEC sp_helptext 'ViewByDepartmentForEmployees';

BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction


update ViewByDepartmentForEmployees
set EmployeeNumber = 142
where EmployeeNumber = 132

select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction

SELECT COUNT(*) AS OldCount
FROM #TempTblView_Old;

SELECT COUNT(*) AS NewCount
FROM #TempTblView_New;

SELECT COUNT(*) AS Removed
FROM (
    SELECT * FROM #TempTblView_Old
    EXCEPT
    SELECT * FROM #TempTblView_New
) x;

SELECT COUNT(*) AS Added
FROM (
    SELECT * FROM #TempTblView_New
    EXCEPT
    SELECT * FROM #TempTblView_Old
) x;
ROLLBACK TRAN -- there is some issue - 5 rows disappear - but the count drops from 34 to 30

-- This way updating a view is obviously a security risk which we can prevent using the WITH CHECK OPTION

GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where e.EmployeeNumber BETWEEN 120 AND 139

WITH CHECK OPTION -- this is supposed to prevent us from updating the VIEW but why??
-- group by d.Department, t.EmployeeNumber

--order by d.Department, t.EmployeeNumber 
GO

BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
-- select * from ViewByDepartmentForEmployees where EmployeeNumber = 132 order by EmployeeNumber, DateOfTransaction 
select count(*) from ViewByDepartmentForEmployees 
select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 132
-- SELECT * from tblTransaction where EmployeeNumber in (132,142)

update ViewByDepartmentForEmployees
set EmployeeNumber = 142
where EmployeeNumber = 132

select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
select count(*) from ViewByDepartmentForEmployees
-- select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 142

select * From #TempTblView_New
EXCEPT
SELECT * from #TempTblView_Old

SELECT * from #TempTblView_Old
EXCEPT
select * From #TempTblView_New
ROLLBACK TRAN
-- the above one should fail but why it did not in my case. See NOTION notes


-- the correction was needed in this line: where t.EmployeeNumber BETWEEN 120 AND 139 /// ** It was previously e.EmployeeNumber BETWEEN 120 AND 139
GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.EmployeeNumber BETWEEN 120 AND 139
-- group by d.Department, t.EmployeeNumber

--order by d.Department, t.EmployeeNumber 
GO

-------------------=========================== the one below works correctly now:

BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction


update ViewByDepartmentForEmployees
set EmployeeNumber = 142
where EmployeeNumber = 132

select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction

SELECT COUNT(*) AS OldCount
FROM #TempTblView_Old;

SELECT COUNT(*) AS NewCount
FROM #TempTblView_New;

SELECT COUNT(*) AS Removed
FROM (
    SELECT * FROM #TempTblView_Old
    EXCEPT
    SELECT * FROM #TempTblView_New
) x;

SELECT COUNT(*) AS Added
FROM (
    SELECT * FROM #TempTblView_New
    EXCEPT
    SELECT * FROM #TempTblView_Old
) x;
ROLLBACK TRAN 


GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.EmployeeNumber BETWEEN 120 AND 139

WITH CHECK OPTION
-- group by d.Department, t.EmployeeNumber

--order by d.Department, t.EmployeeNumber 
GO

BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
-- select * from ViewByDepartmentForEmployees where EmployeeNumber = 132 order by EmployeeNumber, DateOfTransaction 
select count(*) from ViewByDepartmentForEmployees 
select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 132
-- SELECT * from tblTransaction where EmployeeNumber in (132,142)

update ViewByDepartmentForEmployees
set EmployeeNumber = 142
where EmployeeNumber = 132

------- WITH CHECK OPTION prevents the update syntax to defy the where clause of the view.
------- since the where clause refers the filter to be done on the employee number range 120-139
------- thus we are allowed to update the tblTransaction.EmployeeNumber in the range 120-139

select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
select count(*) from ViewByDepartmentForEmployees
-- select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 142

select * From #TempTblView_New
EXCEPT
SELECT * from #TempTblView_Old

SELECT * from #TempTblView_Old
EXCEPT
select * From #TempTblView_New
ROLLBACK TRAN
-- ERROR: The attempted insert or update failed because the target view either specifies 
--WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.


BEGIN TRAN

select * INTO #TempTblView_Old from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
-- select * from ViewByDepartmentForEmployees where EmployeeNumber = 132 order by EmployeeNumber, DateOfTransaction 
select count(*) from ViewByDepartmentForEmployees 
select count(*) from ViewByDepartmentForEmployees where EmployeeNumber = 132
-- SELECT * from tblTransaction where EmployeeNumber in (132,142)

update ViewByDepartmentForEmployees
set EmployeeNumber = 138
where EmployeeNumber = 132


select * INTO #TempTblView_New from ViewByDepartmentForEmployees order by EmployeeNumber, DateOfTransaction
select count(*) from ViewByDepartmentForEmployees


ROLLBACK TRAN


-----=================== DELETING ROWS FROM VIEWS:
GO
CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
from tblDepartment as d
left join tblEmployee e
on d.Department = e.Department
left join tblTransaction t
on e.EmployeeNumber = t.EmployeeNumber
where t.EmployeeNumber BETWEEN 120 AND 139

WITH CHECK OPTION
-- group by d.Department, t.EmployeeNumber

--order by d.Department, t.EmployeeNumber 
GO

BEGIN TRANSACTION

DELETE FROM ViewByDepartmentForEmployees WHERE EmployeeNumber = 132

ROLLBACK TRANSACTION
---- ERROR: View or function 'ViewByDepartmentForEmployees' is not updatable because the modification affects multiple base tables.
          -- The reason it fails is that one row in this view is based out of different base tables and not one table

---- But say if we have this VIEW:

GO
CREATE OR ALTER VIEW [dbo].[ViewOfEmployee] AS
select * from tblEmployee
GO

BEGIN TRANSACTION

DELETE FROM ViewOfEmployee WHERE EmployeeNumber = 132

ROLLBACK TRANSACTION
--- This would work fully fine.

----- **** NOTE: There is a walk around for this issue using TRIGGERS


-------=================== INDEX AND INDEXED VIEWS =======================
select * from dbo.ViewByDepartmentForEmployees

--- Creating the Indexed VIEW:
----=== FIRST CREATE QUERY:

GO
    CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] AS
    select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
    from tblDepartment as d
    left join tblEmployee e
    on d.Department = e.Department
    left join tblTransaction t
    on e.EmployeeNumber = t.EmployeeNumber
    where t.EmployeeNumber BETWEEN 120 AND 139
    --WITH CHECK OPTION -- Check whether the WITH CHECK OPTION is allowed or not??
GO

CREATE UNIQUE CLUSTERED INDEX IX_ViewByDepartmentForEmployees ON dbo.ViewByDepartmentForEmployees(EmployeeNumber, Department)
--- Error : Cannot create index on view 'ViewByDepartmentForEmployees' because the view is not schema bound.

----=== SECOND CREATE QUERY:
GO
    CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] WITH SCHEMABINDING AS
    select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
    from dbo.tblDepartment as d
    left join dbo.tblEmployee e
    on d.Department = e.Department
    left join dbo.tblTransaction t
    on e.EmployeeNumber = t.EmployeeNumber
    where t.EmployeeNumber BETWEEN 120 AND 139
    --WITH CHECK OPTION -- Check whether the WITH CHECK OPTION is allowed or not??
GO

CREATE UNIQUE CLUSTERED INDEX IX_ViewByDepartmentForEmployees ON dbo.ViewByDepartmentForEmployees(EmployeeNumber, Department)
-- Error: Cannot create index on view "70-461-LearnSqlServer.dbo.ViewByDepartmentForEmployees" because it uses a LEFT, RIGHT, or FULL OUTER join, and no OUTER joins are allowed in indexed views. Consider using an INNER join instead.

----=== THIRD CREATE QUERY:
GO
    CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] WITH SCHEMABINDING AS
    select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
    from dbo.tblDepartment as d
    join dbo.tblEmployee e
    on d.Department = e.Department
    join dbo.tblTransaction t
    on e.EmployeeNumber = t.EmployeeNumber
    where t.EmployeeNumber BETWEEN 120 AND 139
    --WITH CHECK OPTION -- Check whether the WITH CHECK OPTION is allowed or not??
GO

CREATE UNIQUE CLUSTERED INDEX IX_ViewByDepartmentForEmployees ON dbo.ViewByDepartmentForEmployees(EmployeeNumber, Department)
--Error: The CREATE UNIQUE INDEX statement terminated because a duplicate key was found for the object name 
            --'dbo.ViewByDepartmentForEmployees' and the index name 'IX_ViewByDepartmentForEmployees'. The duplicate key value is (123, Commercial).

-----*** Due to existence of Duplicate Rows the Creation of Indexed View failed. So let us add a third column DateOfTransaction to Index
        -- to make it unique

        ----=== THIRD CREATE QUERY:
GO
    CREATE OR ALTER VIEW [dbo].[ViewByDepartmentForEmployees] WITH SCHEMABINDING AS
    select d.Department, t.EmployeeNumber ,t.DateOfTransaction , t.Amount as TotalAmount
    from dbo.tblDepartment as d
    join dbo.tblEmployee e
    on d.Department = e.Department
    join dbo.tblTransaction t
    on e.EmployeeNumber = t.EmployeeNumber
    where t.EmployeeNumber BETWEEN 120 AND 139
    --WITH CHECK OPTION -- Check whether the WITH CHECK OPTION is allowed or not??
GO

CREATE UNIQUE CLUSTERED INDEX IX_ViewByDepartmentForEmployees ON dbo.ViewByDepartmentForEmployees(EmployeeNumber, Department, DateOfTransaction)