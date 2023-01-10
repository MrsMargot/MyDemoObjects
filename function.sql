-----FUNCTION---------------------------------------------------------------------------
---"As an HR manager I would like to quickly see information about each employee separately
---just after I'll type his/her ID or Name or Surname"----------------------------------------------------
---function to show the information about the employee/employees------------------------------------------
---inline table valued function---------------------------------------------------------------------------


CREATE FUNCTION fnEmployeesByIDNameOrSurname (@Id int, @Name varchar(50), @Surname varchar(50))
RETURNS TABLE
AS
	RETURN (SELECT ap.Name, ap.Surname, ap.DateOfBirth, ap.Gender, e.DepartmentID, e.ManagerID,
			e.Position, e.ContractStart, e.ContractEnd, e.Salary, apl.Name AS ShopName
			FROM Employees e
			INNER JOIN AssociatedPersons ap
				ON ap.ID = e.AssociatedPersonID
			INNER JOIN AssociatedPlaces apl
				ON apl.ID = e.AssociatedPlaceID
			WHERE apl.PlaceType = 'Shop'
			AND (e.ID = @Id OR ap.Name = @Name OR ap.Surname = @Surname))

SELECT * FROM fnEmployeesByIDNameOrSurname (null ,'Hugo', null) --you need to specify three parameters,
--but there can be nulls or some default values, you/or some API need to provide one correct to find 
--a matching record
--id 3 and 5
SELECT * FROM Employees

--how to connect with some console app?---

