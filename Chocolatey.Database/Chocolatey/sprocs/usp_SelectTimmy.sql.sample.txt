DECLARE @Name VarChar(100)
DECLARE @Type VarChar(20)
SET @Name = 'usp_SelectTimmy'
SET @Type = 'PROCEDURE'
IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE [name] = @Name)
  BEGIN
	DECLARE @SQL varchar(1000)
	SET @SQL = 'CREATE ' + @Type + ' ' + @Name + ' AS SELECT * FROM sysobjects'
	EXECUTE(@SQL)
  END
Print 'Updating ' + @Type + ' ' + @Name
GO

ALTER PROCEDURE dbo.usp_SelectTimmy AS

SELECT  * FROM vw_Timmy