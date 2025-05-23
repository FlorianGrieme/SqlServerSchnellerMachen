USE msdb;
GO

EXEC sp_add_job @job_name = N'DailyBackup';
GO

EXEC sp_add_jobstep
    @job_name = N'DailyBackup',
    @step_name = N'BackupStep',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE [MeineDatenbank] TO DISK = N''D:\Backup\meineDB.bak'' WITH INIT',
    @database_name = N'master';
GO

EXEC sp_add_schedule
    @schedule_name = N'Täglich_2Uhr',
    @freq_type = 4,              -- täglich
    @freq_interval = 1,          -- jeden Tag
    @active_start_time = 020000; -- 02:00 Uhr
GO

EXEC sp_attach_schedule
    @job_name = N'DailyBackup',
    @schedule_name = N'Täglich_2Uhr';
GO

EXEC sp_add_jobserver
    @job_name = N'DailyBackup';
GO
