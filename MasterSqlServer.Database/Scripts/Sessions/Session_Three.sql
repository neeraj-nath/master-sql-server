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