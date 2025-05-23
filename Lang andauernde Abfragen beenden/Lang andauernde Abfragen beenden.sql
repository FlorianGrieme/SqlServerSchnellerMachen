DECLARE @kill AS NVARCHAR(255)
DECLARE @pid AS NVARCHAR(255)
DECLARE @login AS NVARCHAR(255)
DECLARE @hostname AS NVARCHAR(255)
DECLARE @dbname AS NVARCHAR(255)
DECLARE @program AS NVARCHAR(255)

DECLARE kill_cursor CURSOR FOR

WITH qry AS
(
    SELECT DISTINCT spid
				   ,loginame AS Login
				   ,hostname 
				   ,sd.name AS DBName
				   ,program_name AS ProgramName   
    FROM master.dbo.sysprocesses sp 
    JOIN master.dbo.sysdatabases sd ON sp.dbid = sd.dbid
    WHERE program_name LIKE '%Office%'
	--WHERE program_name NOT IN (Whitelist)
)
SELECT spid, Login, hostname, DBName, ProgramName
FROM qry

OPEN kill_cursor
FETCH NEXT FROM kill_cursor INTO @pid, @login, @hostname, @dbname, @program

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @kill = N'BEGIN TRY KILL ' + @pid + '; END TRY BEGIN CATCH PRINT ''Session already expired'' END CATCH'
    EXECUTE sp_executesql @kill;

--Optional Vorgang loggen oder per Email informieren

    FETCH NEXT FROM kill_cursor INTO @pid, @login, @hostname, @dbname, @program
END
