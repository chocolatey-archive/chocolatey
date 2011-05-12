IF NOT EXISTS (SELECT * FROM dbo.sysusers WHERE NAME = 'App-ReadOnlyRole') EXEC sp_addrole 'App-ReadOnlyRole'
GO
