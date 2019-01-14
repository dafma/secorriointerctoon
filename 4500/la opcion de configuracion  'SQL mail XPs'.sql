if not substring(@@version, 1, 25) in ('Microsoft SQL Server 2012')
EXEC sp_configure N'Database Mail XPs', N'1'
reconfigure 