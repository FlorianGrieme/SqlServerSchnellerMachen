SELECT @sql += '
USE [' + name + '];

GO

SELECT
DB_NAME() AS Datenbank,
mf.name,
mf.type_desc,
CAST(mf.size * 8 / 1024 AS INT),
CAST(FILEPROPERTY(mf.name, ''SpaceUsed'') * 8 / 1024 AS INT),
CASE
WHEN mf.is_percent_growth = 1 THEN CAST(mf.growth AS NVARCHAR) + ' %'
ELSE CAST(mf.growth * 8 / 1024 AS NVARCHAR) + ' MB'
END,
CASE
WHEN mf.is_percent_growth = 1 THEN 'Prozent'
ELSE 'MB'
END
FROM sys.database_files mf;

GO

EXEC sp_executesql @sql;

GO

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
