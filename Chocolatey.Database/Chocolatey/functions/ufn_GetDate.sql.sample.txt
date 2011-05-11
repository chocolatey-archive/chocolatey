DECLARE @Name VarChar(100)
DECLARE @Type VarChar(20)
SET @Name = 'dbo.ufn_GetDate'
SET @Type = 'FUNCTION'
IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE [name] = @Name)
  BEGIN
	DECLARE @SQL varchar(1000)
	SET @SQL = 'CREATE ' + @Type + ' ' + @Name + ' (@i INT) RETURNS INT
    AS 
      BEGIN 
        RETURN (@i)
      END'
	EXECUTE(@SQL)
  END
Print 'Updating ' + @Type + ' ' + @Name
GO

ALTER FUNCTION dbo.ufn_GetDate (@i INT)
RETURNS DateTime
AS
 BEGIN
  DECLARE @Today DateTime
  
  SELECT @Today = GetDate()
  
  RETURN (@Today)
 END