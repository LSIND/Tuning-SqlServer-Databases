-- 1. ������� ������ � ������� SSMS
-- Management -> Sessions -> Add Session...
-- New Session -> General -> "Session name" -> �������� Waits by Session
-- New Session -> Events -> Event library ����� � �������� wait_info � Selected events list
-- ��� wait_info -> Event configuration options -> Global Fields (Actions) ������� session_id
-- ��� wait_info -> Event configuration options -> Filter (Predicate) -> �������� ������� sqlserver.session_id > 50.
-- New Session -> Data Storage -> �������� ���� (Add) -> ������� event_file, � ����� ������������ ����� .XEL
-- ������������ ������ ����� - 5 Mb
-- OK
-- ��������� ������ Start Session


-- ��������������� ��� T-SQL ������
CREATE EVENT SESSION [Waits by Session] ON SERVER 
ADD EVENT sqlos.wait_info(
    ACTION(sqlserver.session_id)
    WHERE ([sqlserver].[session_id]>(50)))
ADD TARGET package0.event_file(
SET filename=N'<���� � �����>\waitbysession.xel',max_file_size=(5))
WITH (MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [Waits by Session] ON SERVER
	STATE=START
GO


-- 2. ��������� ������ load_script1.sql (~60 �����)


-- 3. ������������� ����������� �� ����� �� session_id
WITH xeCTE
AS
(
	SELECT CAST(event_data AS xml) AS xe_xml
	FROM sys.fn_xe_file_target_read_file('<���� � �����>\waitbysession*.xel', NULL, NULL, NULL)
)
,valueCTE
AS
(
	SELECT xe_xml.value('(event/action[@name="session_id"]/value)[1]','int') AS sessionID,
	xe_xml.value('(event/data[@name="wait_type"]/text)[1]','varchar(50)') AS wait_type,
	xe_xml.value('(event/data[@name="duration"]/value)[1]','int') AS wait_duration,
	xe_xml.value('(event/data[@name="signal_duration"]/value)[1]','int') AS wait_signal_duration
	FROM xeCTE
)
SELECT sessionID, wait_type, 
SUM(wait_duration) AS total_wait_duration, 
SUM(wait_signal_duration) AS signal_wait_duration, 
SUM(wait_duration - wait_signal_duration) AS resource_wait_duration
FROM valueCTE
WHERE wait_duration > 0
GROUP BY sessionID, wait_type
ORDER BY sessionID, wait_type;

-- 4. �������� � �������� ������, � ����� ��������� �������� load_script1.sql
ALTER EVENT SESSION [Waits by Session] ON SERVER
	STATE=STOP
GO

DROP EVENT SESSION [Waits by Session] ON SERVER
GO

CREATE TABLE ##stopload (id int)
GO
