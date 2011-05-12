IF NOT EXISTS (SELECT * FROM dbo.sysusers WHERE NAME = 'App-ApplicationRole') EXEC sp_addrole 'App-ApplicationRole'
GO
