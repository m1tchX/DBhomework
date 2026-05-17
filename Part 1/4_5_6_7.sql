/* ======================================================================
СКРИПТ ДЛЯ ВЫПОЛНЕНИЯ ПУНКТОВ 4, 5, 6, 7
Предметная область: 53. Воинская часть
ВНИМАНИЕ: Перед запуском верните РЕАЛЬНОЕ текущее время в Windows!
======================================================================
*/

USE MilitaryUnitDB;
GO

-- ======================================================================
-- ПУНКТ 4. Состояние всех таблиц на последний день каждого квартала 2022 года в 23:59:59.9999999
-- ======================================================================

-- --- КОНЕЦ 1 КВАРТАЛА (31 марта 2022) ---
SELECT 'Q1_Personnel' AS SnapshotPeriod, * FROM dbo.Personnel FOR SYSTEM_TIME AS OF '2022-03-31T23:59:59.9999999';
SELECT 'Q1_Ranks' AS SnapshotPeriod, * FROM dbo.Ranks FOR SYSTEM_TIME AS OF '2022-03-31T23:59:59.9999999';
SELECT 'Q1_Units' AS SnapshotPeriod, * FROM dbo.Units FOR SYSTEM_TIME AS OF '2022-03-31T23:59:59.9999999';
SELECT 'Q1_ServiceForms' AS SnapshotPeriod, * FROM dbo.ServiceForms FOR SYSTEM_TIME AS OF '2022-03-31T23:59:59.9999999';

-- --- КОНЕЦ 2 КВАРТАЛА (30 июня 2022) ---
SELECT 'Q2_Personnel' AS SnapshotPeriod, * FROM dbo.Personnel FOR SYSTEM_TIME AS OF '2022-06-30T23:59:59.9999999';
SELECT 'Q2_Ranks' AS SnapshotPeriod, * FROM dbo.Ranks FOR SYSTEM_TIME AS OF '2022-06-30T23:59:59.9999999';
SELECT 'Q2_Units' AS SnapshotPeriod, * FROM dbo.Units FOR SYSTEM_TIME AS OF '2022-06-30T23:59:59.9999999';
SELECT 'Q2_ServiceForms' AS SnapshotPeriod, * FROM dbo.ServiceForms FOR SYSTEM_TIME AS OF '2022-06-30T23:59:59.9999999';

-- --- КОНЕЦ 3 КВАРТАЛА (30 сентября 2022) ---
SELECT 'Q3_Personnel' AS SnapshotPeriod, * FROM dbo.Personnel FOR SYSTEM_TIME AS OF '2022-09-30T23:59:59.9999999';
SELECT 'Q3_Ranks' AS SnapshotPeriod, * FROM dbo.Ranks FOR SYSTEM_TIME AS OF '2022-09-30T23:59:59.9999999';
SELECT 'Q3_Units' AS SnapshotPeriod, * FROM dbo.Units FOR SYSTEM_TIME AS OF '2022-09-30T23:59:59.9999999';
SELECT 'Q3_ServiceForms' AS SnapshotPeriod, * FROM dbo.ServiceForms FOR SYSTEM_TIME AS OF '2022-09-30T23:59:59.9999999';

-- --- КОНЕЦ 4 КВАРТАЛА (31 декабря 2022) ---
SELECT 'Q4_Personnel' AS SnapshotPeriod, * FROM dbo.Personnel FOR SYSTEM_TIME AS OF '2022-12-31T23:59:59.9999999';
SELECT 'Q4_Ranks' AS SnapshotPeriod, * FROM dbo.Ranks FOR SYSTEM_TIME AS OF '2022-12-31T23:59:59.9999999';
SELECT 'Q4_Units' AS SnapshotPeriod, * FROM dbo.Units FOR SYSTEM_TIME AS OF '2022-12-31T23:59:59.9999999';
SELECT 'Q4_ServiceForms' AS SnapshotPeriod, * FROM dbo.ServiceForms FOR SYSTEM_TIME AS OF '2022-12-31T23:59:59.9999999';
GO

-- ======================================================================
-- ПУНКТ 5. Состояние всех таблиц за лето 2022 года (01.06.2022 - 31.08.2022)
-- ======================================================================
SELECT 'Summer_Personnel' AS Period, * FROM dbo.Personnel FOR SYSTEM_TIME BETWEEN '2022-06-01T00:00:00.0000000' AND '2022-08-31T23:59:59.9999999';
SELECT 'Summer_Ranks' AS Period, * FROM dbo.Ranks FOR SYSTEM_TIME BETWEEN '2022-06-01T00:00:00.0000000' AND '2022-08-31T23:59:59.9999999';
SELECT 'Summer_Units' AS Period, * FROM dbo.Units FOR SYSTEM_TIME BETWEEN '2022-06-01T00:00:00.0000000' AND '2022-08-31T23:59:59.9999999';
SELECT 'Summer_ServiceForms' AS Period, * FROM dbo.ServiceForms FOR SYSTEM_TIME BETWEEN '2022-06-01T00:00:00.0000000' AND '2022-08-31T23:59:59.9999999';
GO

-- ======================================================================
-- ПУНКТ 6. Строки, которые были вставлены и удалены за третий квартал 2022 года (01.07.2022 - 30.09.2022)
-- ======================================================================

-- 1. Вставленные за 3 квартал (время начала действия версии попало в Q3)
SELECT 'INSERTED_Q3_Personnel' AS Operation, * FROM dbo.Personnel FOR SYSTEM_TIME ALL 
WHERE SysStartTime >= '2022-07-01T00:00:00.0000000' AND SysStartTime <= '2022-09-30T23:59:59.9999999';

-- 2. Удаленные за 3 квартал (записи, у которых время окончания действия попало в Q3, и они ушли в историю)
SELECT 'DELETED_Q3_Personnel' AS Operation, * FROM dbo.PersonnelHistory 
WHERE SysEndTime >= '2022-07-01T00:00:00.0000000' AND SysEndTime <= '2022-09-30T23:59:59.9999999';
GO

-- ======================================================================
-- ПУНКТ 7. Запрос с несколькими темпоральными таблицами, используя JOIN
-- Срез данных на середину года (15 июля 2022) с объединением 4 таблиц
-- ======================================================================
SELECT 
    p.PersonnelID,
    p.LastName,
    p.FirstName,
    p.MiddleName,
    r.RankName,
    u.UnitName,
    sf.FormName,
    p.SysStartTime AS RowValidFrom
FROM dbo.Personnel FOR SYSTEM_TIME AS OF '2022-07-15T12:00:00.0000000' p
JOIN dbo.Ranks FOR SYSTEM_TIME AS OF '2022-07-15T12:00:00.0000000' r 
    ON p.RankID = r.RankID
JOIN dbo.Units FOR SYSTEM_TIME AS OF '2022-07-15T12:00:00.0000000' u 
    ON p.UnitID = u.UnitID
JOIN dbo.ServiceForms FOR SYSTEM_TIME AS OF '2022-07-15T12:00:00.0000000' sf 
    ON p.FormID = sf.FormID;
GO
