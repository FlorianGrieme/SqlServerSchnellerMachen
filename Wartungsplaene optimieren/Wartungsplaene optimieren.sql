SELECT value_in_use
FROM sys.configurations
WHERE name = 'fill factor (%)';

GO

EXEC sp_configure 'show advanced options', 1;

GO

RECONFIGURE;

GO

EXEC sp_configure 'fill factor (%)', 100;

GO

RECONFIGURE;
