-- 1. ��������� ����������� ������ 
-- �������� Powershell �� ����� ��������������, ��������� � ����� ..Tuning-SqlServer-Databases\mod04\lab
-- ��������� ������ .\start-load-ex.ps1 workload.sql
-- ������ �������� 10 ������� ����� (job), ����������� ���� � ��� �� ������ workload.sql
-- ��������� ��������� ���������� �����

-- 2. ���������� ���������� ��� ���� �������� MEMORY_ALLOCATION_EXT

SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'MEMORY_ALLOCATION_EXT';


-- 3. ���������� ����������� ������ �������, ������ 512 ��
-- ���������� ������������ ������ �������, ������ 4096 ��

EXEC sp_configure N'Min Server Memory','0';
EXEC sp_configure N'Max Server Memory','8196';

-- 4. ������������� ��������� Sql Server


-- 5. ����� ��������� ������ .\start-load-ex.ps1 workload.sql � ��������� ��������� ���������� �����

-- 6. ����� ���������� ���������� ��� ���� �������� MEMORY_ALLOCATION_EXT

select *
from sys.dm_os_wait_stats
where wait_type = 'MEMORY_ALLOCATION_EXT';

-- 7. �������� ���������� ������������ � ������������, ����������� � �.2