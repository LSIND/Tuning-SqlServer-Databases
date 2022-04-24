-- 1. Default Trace
SELECT * FROM sys.configurations WHERE name =
'default trace enabled';

SELECT * FROM sys.traces
WHERE is_default = 1;

SELECT *
FROM ::fn_trace_gettable('C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\log_245.trc',0)
INNER JOIN sys.trace_events e
ON eventclass = trace_event_id