
-- Step 1 - Collect physical index stats
USE AdventureWorks;
GO 

SELECT 
	   DB_NAME(ips.database_id)   AS DatabaseName, 
       OBJECT_NAME(ips.object_id) AS ObjectName, 
       ind.NAME                    AS IndexName, 
       ips.index_id, 
       ips.index_type_desc, 
       ips.avg_fragmentation_in_percent, 
       ips.fragment_count, 
	  ips.record_count,
	  ips.forwarded_record_count,
       ips.page_count, 
       ind.fill_factor, 
       GETDATE() As DataCollectionDate
FROM   sys.Dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, N'LIMITED') AS 
       ips 
       INNER JOIN sys.indexes AS ind WITH (nolock) 
               ON ips.[object_id] = ind.[object_id] 
                  AND ips.index_id = ind.index_id 
WHERE  ips.database_id = Db_id('AdventureWorks')
ORDER BY  ips.avg_fragmentation_in_percent desc;
GO 

-- Step 2 - Return current executing queries

SELECT 
	DB_NAME(er.database_id) AS DatabaseName,
	er.session_id, 
	er.blocking_session_id,
	(SELECT SUBSTRING(qt.[text],er.statement_start_offset/2, 
    (CASE WHEN er.statement_end_offset = -1 
    THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
    ELSE er.statement_end_offset END - er.statement_start_offset)/2))
	AS QueryText,
	er.start_time,
	er.status,
	er.Command, 
	er.last_wait_type,
	er.wait_type AS current_wait_type,
	er.wait_time,
	er.cpu_time,
	er.total_elapsed_time,
	er.reads, 
	er.writes,
	er.logical_reads
FROM sys.dm_exec_requests er
cross apply sys.dm_exec_sql_text(er.sql_handle) qt
ORDER BY total_elapsed_time DESC;
GO


-- Step 3 - Return I/O usage
SELECT
DB_NAME(VFS.Database_id) AS DataBaseName,
mf.file_id,
mf.name As FileName,
vfs.Sample_Ms,
vfs.Num_Of_Reads,
vfs.Num_Of_Bytes_Read,
vfs.IO_Stall_Read_ms,
vfs.Num_Of_Writes,
vfs.Num_Of_Bytes_Written,
vfs.IO_Stall_Write_ms,
vfs.IO_Stall,
GETDATE() AS DataCollectionDate
 FROM sys.Dm_io_virtual_file_stats(NULL, NULL) vfs
 INNER JOIN sys.master_files mf ON mf.FILE_ID = vfs.FILE_ID  AND
 mf.DataBase_ID = vfs.DataBase_ID;
GO



-- сведения об успешном резервном копировании за последние (N) месяца.
SELECT bs.database_name,
    backuptype = CASE
            WHEN bs.type = 'D'
            AND bs.is_copy_only = 0 THEN 'Full Database'
            WHEN bs.type = 'D'
            AND bs.is_copy_only = 1 THEN 'Full Copy-Only Database'
            WHEN bs.type = 'I' THEN 'Differential database backup'
            WHEN bs.type = 'L' THEN 'Transaction Log'
            WHEN bs.type = 'F' THEN 'File or filegroup'
            WHEN bs.type = 'G' THEN 'Differential file'
            WHEN bs.type = 'P' THEN 'Partial'
            WHEN bs.type = 'Q' THEN 'Differential partial'
        END + ' Backup',
    CASE bf.device_type
            WHEN 2 THEN 'Disk'
            WHEN 5 THEN 'Tape'
            WHEN 7 THEN 'Virtual device'
            WHEN 9 THEN 'Azure Storage'
            WHEN 105 THEN 'A permanent backup device'
            ELSE 'Other Device'
        END AS DeviceType,
    bms.software_name AS backup_software,
    bs.recovery_model,
    bs.compatibility_level,
    BackupStartDate = bs.Backup_Start_Date,
    BackupFinishDate = bs.Backup_Finish_Date,
    LatestBackupLocation = bf.physical_device_name,
    backup_size_mb = CONVERT(decimal(10, 2), bs.backup_size/1024./1024.),
    compressed_backup_size_mb = CONVERT(decimal(10, 2), bs.compressed_backup_size/1024./1024.),
    database_backup_lsn, -- For tlog and differential backups, this is the checkpoint_lsn of the FULL backup it is based on.
    checkpoint_lsn,
    begins_log_chain,
    bms.is_password_protected
FROM msdb.dbo.backupset bs
LEFT OUTER JOIN msdb.dbo.backupmediafamily bf ON bs.[media_set_id] = bf.[media_set_id]
INNER JOIN msdb.dbo.backupmediaset bms ON bs.[media_set_id] = bms.[media_set_id]
WHERE bs.backup_start_date > DATEADD(MONTH, -5, sysdatetime()) -- N = 5 - последние 5 месяцев
ORDER BY bs.Backup_Start_Date DESC, bs.database_name ASC;