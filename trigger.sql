-----TRIGGERS----
---"As a Head of HR department I would like to know about each update of employees records
---to ask my managers about some details if I only need them"
--------------------------------------------------------------------------------------------------
---show the changes in auditing table: "EmployeesAudit" - change employees salary ----
--------------------------------------------------------------------------------------------------

--SELECT * FROM Employees
--SELECT * FROM EmployeesAudit

--UPDATE Employees
--SET AssociatedPlaceID =  20 WHERE ID = 12

--UPDATE Employees
--SET Salary = Salary * 1.03 WHERE AssociatedPlaceID = 20


--INSERT INTO Employees (AssociatedPersonID, DepartmentID, ManagerID, Position, ContractStart, Salary, AssociatedPlaceID)
--VALUES(56, 1, 52, 'salesman', GETDATE(),4700, 16)


--INSERT INTO Employees (AssociatedPersonID, DepartmentID, ManagerID, Position, ContractStart, Salary, AssociatedPlaceID)
--VALUES(58, 1, 2, 'salesman', GETDATE(),4500, 16),
--		(59, 1, 2, 'salesman', GETDATE(),5500, 16),
--		(60, 1, 2, 'salesman', GETDATE(),6000, 16),
--		(61, 1, 2, 'salesman', GETDATE(),7000, 16),
--		(62, 1, 2, 'salesman', GETDATE(),3000, 16)



CREATE TRIGGER [dbo].[trEmployees_ForUpdate]
ON [dbo].[Employees]
FOR UPDATE 
AS
BEGIN

	  Declare @Id int
      Declare @OldAssociatedPersonID int, @NewAssociatedPersonID int
	  Declare @OldDepartmentID int, @NewDepartmentID int
	  Declare @OldManagerID int, @NewManagerID int
	  Declare @OldPosition varchar(50), @NewPosition varchar(50)
      Declare @OldContractStart date, @NewContractStart date  -- in case of person responsible will make an error and input the wrong date
	  Declare @OldContractEnd date, @NewContractEnd date	  -- in case of person responsible will make an error and input the wrong date
	  Declare @OldSalary decimal(12,2), @NewSalary decimal(12,2)
      Declare @OldAssociatedPlaceID int, @NewAssociatedPlaceID int
     
      -- Variable to build the audit string
      Declare @AuditString varchar(1000)
      
      -- Load the updated records into temporary table
      Select *
      into #TempTable
      from inserted  -- everything what we change goes to inserted table
     
      -- Loop through the records in temporary table, because there may be more than one record updated at once
      While(Exists(Select ID from #TempTable))
      Begin
            --Initialize the audit string to empty string
            Set @AuditString = ''
           
            -- Select first row data from temp table
            Select Top 1 @Id = ID, @NewAssociatedPersonID = AssociatedPersonID, @NewDepartmentID = DepartmentID, 
			@NewManagerID = ManagerID, @NewPosition = Position, @NewContractStart = ContractStart,
			@NewContractEnd = ContractEnd, @NewSalary = Salary, @NewAssociatedPlaceID = AssociatedPlaceID	
            from #TempTable
           
            -- Select the corresponding row from deleted table
            Select @OldAssociatedPersonID = AssociatedPersonID, @OldDepartmentID = DepartmentID, 
			@OldManagerID = ManagerID, @OldPosition = Position, @OldContractStart = ContractStart,
			@OldContractEnd = ContractEnd, @OldSalary = Salary, @OldAssociatedPlaceID = AssociatedPlaceID
            from deleted where ID = @Id
   
     -- Build the audit string dynamically           
            Set @AuditString = 'Employee with ID = ' + CAST(@Id as varchar(4)) + ' changed '
            if(@OldAssociatedPersonID  <> @NewAssociatedPersonID)
                  Set @AuditString = @AuditString + ' AssociatedPersonID  from ' + CAST(@OldAssociatedPersonID as varchar(50))+ ' to ' +
				  CAST(@NewAssociatedPersonID as varchar(50))
			if(@OldDepartmentID  <> @NewDepartmentID)
                  Set @AuditString = @AuditString + ' DepartmentID  from ' + CAST(@OldDepartmentID as varchar(50))+ ' to ' +
				  CAST(@NewDepartmentID as varchar(50))
			if(@OldManagerID  <> @NewManagerID)
                  Set @AuditString = @AuditString + ' ManagerID  from ' + CAST(@OldManagerID as varchar(50))+ ' to ' +
				  CAST(@NewManagerID as varchar(50))
			if(@OldPosition <> @NewPosition)
                  Set @AuditString = @AuditString + ' Position  from ' + @OldPosition + ' to ' +
				  @NewPosition
			if(@OldContractStart  <> @NewContractStart)
                  Set @AuditString = @AuditString + ' ContractStart  from ' + CAST(@OldContractStart as varchar(50))+ ' to ' +
				  CAST(@NewContractStart as varchar(50))
			if(@OldContractEnd  <> @NewContractEnd)
                  Set @AuditString = @AuditString + ' ContractEnd  from ' + CAST(@OldContractEnd as varchar(50))+ ' to ' +
				  CAST(@NewContractEnd as varchar(50))
			if(@OldSalary  <> @NewSalary)
                  Set @AuditString = @AuditString + ' Salary  from ' + CAST(@OldSalary as varchar(50))+ ' to ' +
				  CAST(@NewSalary as varchar(50))
			if(@OldAssociatedPlaceID  <> @NewAssociatedPlaceID)
                  Set @AuditString = @AuditString + ' AssociatedPlaceID  from ' + CAST(@OldAssociatedPlaceID as varchar(50))+ ' to ' +
				  CAST(@NewAssociatedPlaceID as varchar(50))


            INSERT INTO EmployeesAudit VALUES(@AuditString)
            
            -- Delete the row from temp table, so we can move to the next row
            Delete from #TempTable where Id = @Id
      End
End
GO


SELECT * FROM vEmployeesSalaries
--CREATE VIEW vEmployeesSalaries
--AS 
--SELECT e.ID, ap.Name, ap.Surname, e.DepartmentID, e.ManagerID, e.Position, e.Salary
--FROM Employees e
--	INNER JOIN AssociatedPersons ap
--		ON ap.ID = e.AssociatedPerson