IF OBJECT_ID('tempdb..#DBSpace') IS NOT NULL DROP TABLE #DBSpace;

CREATE TABLE #DBSpace (
    Datenbank SYSNAME,
    Datei NVARCHAR(260),
    Typ NVARCHAR(10),
    Größe_MB INT,
    Belegt_MB INT,
    Freier_MB AS (Größe_MB - Belegt_MB),
    Füllstand_PCT AS CAST(100.0 * Belegt_MB / NULLIF(Größe_MB, 0) AS DECIMAL(5,2)),
    Autogrow NVARCHAR(20),
    Autogrow_Typ NVARCHAR(10)
);

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += '
USE [' + name + '];
INSERT INTO #DBSpace (Datenbank, Datei, Typ, Größe_MB, Belegt_MB, Autogrow, Autogrow_Typ)
SELECT
    DB_NAME() AS Datenbank,
    mf.name,
    mf.type_desc,
    CAST(mf.size * 8 / 1024 AS INT),
    CAST(FILEPROPERTY(mf.name, ''SpaceUsed'') * 8 / 1024 AS INT),
    CASE 
        WHEN mf.is_percent_growth = 1 THEN CAST(mf.growth AS NVAR-CHAR) + '' %''
        ELSE CAST(mf.growth * 8 / 1024 AS NVARCHAR) + '' MB''
    END,
    CASE 
        WHEN mf.is_percent_growth = 1 THEN ''Prozent''
        ELSE ''MB''
    END
FROM sys.database_files mf;
'
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND name NOT IN ('tempdb');

EXEC sp_executesql @sql;

SELECT 
    Datenbank,
    Datei,
    Typ,
    Größe_MB,
    Belegt_MB,
    Freier_MB,
    Füllstand_PCT,
    Autogrow,
    Autogrow_Typ
FROM #DBSpace
ORDER BY Füllstand_PCT DESC;
