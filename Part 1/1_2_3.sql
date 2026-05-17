/* ======================================================================
СКРИПТ ДЛЯ ВЫПОЛНЕНИЯ ПУНКТОВ 1, 2, 3
Предметная область: 53. Воинская часть
======================================================================
*/

-- ======================================================================
-- ПУНКТ 1. Проектирование БД с темпоральными таблицами
-- ======================================================================
CREATE DATABASE MilitaryUnitDB;
GO
USE MilitaryUnitDB;
GO

-- 1. Таблица "Звания" (Справочник)
CREATE TABLE dbo.Ranks (
    RankID INT IDENTITY(1,1) PRIMARY KEY,
    RankName NVARCHAR(50) NOT NULL,
    SubLevel INT NOT NULL,
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.RanksHistory));

-- 2. Таблица "Формы службы" (Справочник)
CREATE TABLE dbo.ServiceForms (
    FormID INT IDENTITY(1,1) PRIMARY KEY,
    FormName NVARCHAR(100) NOT NULL,
    TermMonths INT NOT NULL,
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ServiceFormsHistory));

-- 3. Таблица "Подразделения" (Справочник)
CREATE TABLE dbo.Units (
    UnitID INT IDENTITY(1,1) PRIMARY KEY,
    UnitName NVARCHAR(100) NOT NULL,
    CommanderID INT NULL,
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UnitsHistory));

-- 4. Таблица "Военнослужащие" (Таблица фактов)
CREATE TABLE dbo.Personnel (
    PersonnelID INT IDENTITY(1,1) PRIMARY KEY,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    Gender CHAR(1) CHECK (Gender IN ('М', 'Ж')),
    BirthDate DATE,
    AddressData NVARCHAR(200),
    Phone NVARCHAR(20),
    PassportData NVARCHAR(50),
    RankID INT FOREIGN KEY REFERENCES dbo.Ranks(RankID),
    FormID INT FOREIGN KEY REFERENCES dbo.ServiceForms(FormID),
    UnitID INT FOREIGN KEY REFERENCES dbo.Units(UnitID),
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.PersonnelHistory));
GO

ALTER TABLE dbo.Units 
ADD CONSTRAINT FK_Units_Commander FOREIGN KEY (CommanderID) REFERENCES dbo.Personnel(PersonnelID);
GO

-- ======================================================================
-- ПУНКТ 2. Первичное заполнение (Январь 2022)
-- ВНИМАНИЕ: Перед запуском установите дату в Windows на 15 января 2022 г.
-- ======================================================================
-- Дата вставки строк (системная дата Windows): 15.01.2022

INSERT INTO dbo.Ranks (RankName, SubLevel) VALUES
('Рядовой', 1), ('Ефрейтор', 2), ('Младший сержант', 3), ('Сержант', 4), ('Старший сержант', 5),
('Старшина', 6), ('Прапорщик', 7), ('Старший прапорщик', 8), ('Младший лейтенант', 9), ('Лейтенант', 10);

INSERT INTO dbo.ServiceForms (FormName, TermMonths) VALUES
('По призыву', 12), ('Контракт', 24), ('Контракт', 36), ('Контракт', 60), ('Офицерская кадровая', 60),
('Офицерская кадровая', 120), ('Сверхсрочная', 12), ('АГС', 18), ('АГС', 21), ('Мобилизация', 6);

INSERT INTO dbo.Units (UnitName, CommanderID) VALUES
('1-й Взвод', NULL), ('2-й Взвод', NULL), ('3-й Взвод', NULL), ('1-я Рота', NULL), ('2-я Рота', NULL),
('Узел связи', NULL), ('Медпункт', NULL), ('Автопарк', NULL), ('Склад', NULL), ('Штаб', NULL);

DECLARE @i INT = 1;
WHILE @i <= 30
BEGIN
    INSERT INTO dbo.Personnel (LastName, FirstName, MiddleName, Gender, BirthDate, AddressData, Phone, PassportData, RankID, FormID, UnitID)
    VALUES (
        'Фамилия_' + CAST(@i AS NVARCHAR), 'Имя_' + CAST(@i AS NVARCHAR), 'Отчество_' + CAST(@i AS NVARCHAR), 
        'М', DATEADD(YEAR, -20 - (@i % 10), '2022-01-01'), 'Город, ул. Ленина ' + CAST(@i AS NVARCHAR), 
        '890000000' + RIGHT('0' + CAST(@i AS NVARCHAR), 2), '1234 5678' + RIGHT('0' + CAST(@i AS NVARCHAR), 2),
        (@i % 10) + 1, (@i % 10) + 1, (@i % 10) + 1
    );
    SET @i = @i + 1;
END;

UPDATE dbo.Units SET CommanderID = UnitID + 10 WHERE UnitID <= 10;
GO

-- ======================================================================
-- ПУНКТ 3. Имитация ежемесячных изменений (Февраль - Декабрь 2022)
-- ВНИМАНИЕ: Выполняйте блоки последовательно, каждый раз меняя дату в Windows!
-- ======================================================================

-- --- ФЕВРАЛЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.02.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Фев1', 'Иван', 'М', 1, 1, 1), ('Новый_Фев2', 'Петр', 'М', 1, 1, 2), ('Новый_Фев3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Фев4', 'Олег', 'М', 2, 2, 4), ('Новый_Фев5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112233' WHERE PersonnelID IN (4, 5, 6);
UPDATE dbo.Units SET UnitName = '1-й Взвод (Обн)' WHERE UnitID = 1;
UPDATE dbo.Ranks SET RankName = 'Рядовой (Обн)' WHERE RankID = 1;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (1, 2, 3);
GO

-- --- МАРТ 2022 ---
-- Дата изменений (системная дата Windows): 15.03.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Мар1', 'Иван', 'М', 1, 1, 1), ('Новый_Мар2', 'Петр', 'М', 1, 1, 2), ('Новый_Мар3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Мар4', 'Олег', 'М', 2, 2, 4), ('Новый_Мар5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112244' WHERE PersonnelID IN (7, 8, 9);
UPDATE dbo.Units SET UnitName = '2-й Взвод (Обн)' WHERE UnitID = 2;
UPDATE dbo.Ranks SET RankName = 'Ефрейтор (Обн)' WHERE RankID = 2;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (4, 5, 6);
GO

-- --- АПРЕЛЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.04.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Апр1', 'Иван', 'М', 1, 1, 1), ('Новый_Апр2', 'Петр', 'М', 1, 1, 2), ('Новый_Апр3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Апр4', 'Олег', 'М', 2, 2, 4), ('Новый_Апр5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112255' WHERE PersonnelID IN (10, 11, 12);
UPDATE dbo.Units SET UnitName = '3-й Взвод (Обн)' WHERE UnitID = 3;
UPDATE dbo.Ranks SET RankName = 'Младший сержант (Обн)' WHERE RankID = 3;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (7, 8, 9);
GO

-- --- МАЙ 2022 ---
-- Дата изменений (системная дата Windows): 15.05.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Май1', 'Иван', 'М', 1, 1, 1), ('Новый_Май2', 'Петр', 'М', 1, 1, 2), ('Новый_Май3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Май4', 'Олег', 'М', 2, 2, 4), ('Новый_Май5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112266' WHERE PersonnelID IN (13, 14, 15);
UPDATE dbo.Units SET UnitName = '1-я Рота (Обн)' WHERE UnitID = 4;
UPDATE dbo.Ranks SET RankName = 'Сержант (Обн)' WHERE RankID = 4;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (10, 11, 12);
GO

-- --- ИЮНЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.06.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Июн1', 'Иван', 'М', 1, 1, 1), ('Новый_Июн2', 'Петр', 'М', 1, 1, 2), ('Новый_Июн3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Июн4', 'Олег', 'М', 2, 2, 4), ('Новый_Июн5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112277' WHERE PersonnelID IN (16, 17, 18);
UPDATE dbo.Units SET UnitName = '2-я Рота (Обн)' WHERE UnitID = 5;
UPDATE dbo.Ranks SET RankName = 'Старший сержант (Обн)' WHERE RankID = 5;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (13, 14, 15);
GO

-- --- ИЮЛЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.07.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Июл1', 'Иван', 'М', 1, 1, 1), ('Новый_Июл2', 'Петр', 'М', 1, 1, 2), ('Новый_Июл3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Июл4', 'Олег', 'М', 2, 2, 4), ('Новый_Июл5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112288' WHERE PersonnelID IN (19, 20, 21);
UPDATE dbo.Units SET UnitName = 'Узел связи (Обн)' WHERE UnitID = 6;
UPDATE dbo.Ranks SET RankName = 'Старшина (Обн)' WHERE RankID = 6;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (16, 17, 18);
GO

-- --- АВГУСТ 2022 ---
-- Дата изменений (системная дата Windows): 15.08.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Авг1', 'Иван', 'М', 1, 1, 1), ('Новый_Авг2', 'Петр', 'М', 1, 1, 2), ('Новый_Авг3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Авг4', 'Олег', 'М', 2, 2, 4), ('Новый_Авг5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991112299' WHERE PersonnelID IN (22, 23, 24);
UPDATE dbo.Units SET UnitName = 'Медпункт (Обн)' WHERE UnitID = 7;
UPDATE dbo.Ranks SET RankName = 'Прапорщик (Обн)' WHERE RankID = 7;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (19, 20, 21);
GO

-- --- СЕНТЯБРЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.09.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Сен1', 'Иван', 'М', 1, 1, 1), ('Новый_Сен2', 'Петр', 'М', 1, 1, 2), ('Новый_Сен3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Сен4', 'Олег', 'М', 2, 2, 4), ('Новый_Сен5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991113300' WHERE PersonnelID IN (25, 26, 27);
UPDATE dbo.Units SET UnitName = 'Автопарк (Обн)' WHERE UnitID = 8;
UPDATE dbo.Ranks SET RankName = 'Старший прапорщик (Обн)' WHERE RankID = 8;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (22, 23, 24);
GO

-- --- ОКТЯБРЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.10.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Окт1', 'Иван', 'М', 1, 1, 1), ('Новый_Окт2', 'Петр', 'М', 1, 1, 2), ('Новый_Окт3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Окт4', 'Олег', 'М', 2, 2, 4), ('Новый_Окт5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991113311' WHERE PersonnelID IN (28, 29, 30);
UPDATE dbo.Units SET UnitName = 'Склад (Обн)' WHERE UnitID = 9;
UPDATE dbo.Ranks SET RankName = 'Младший лейтенант (Обн)' WHERE RankID = 9;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (25, 26, 27);
GO

-- --- НОЯБРЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.11.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Ноя1', 'Иван', 'М', 1, 1, 1), ('Новый_Ноя2', 'Петр', 'М', 1, 1, 2), ('Новый_Ноя3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Ноя4', 'Олег', 'М', 2, 2, 4), ('Новый_Ноя5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991113322' WHERE PersonnelID IN (31, 32, 33);
UPDATE dbo.Units SET UnitName = 'Штаб (Обн)' WHERE UnitID = 10;
UPDATE dbo.Ranks SET RankName = 'Лейтенант (Обн)' WHERE RankID = 10;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (28, 29, 30);
GO

-- --- ДЕКАБРЬ 2022 ---
-- Дата изменений (системная дата Windows): 15.12.2022
INSERT INTO dbo.Personnel (LastName, FirstName, Gender, RankID, FormID, UnitID) VALUES 
('Новый_Дек1', 'Иван', 'М', 1, 1, 1), ('Новый_Дек2', 'Петр', 'М', 1, 1, 2), ('Новый_Дек3', 'Анна', 'Ж', 7, 3, 7), ('Новый_Дек4', 'Олег', 'М', 2, 2, 4), ('Новый_Дек5', 'Макс', 'М', 3, 2, 5);
UPDATE dbo.Personnel SET Phone = '89991113333' WHERE PersonnelID IN (34, 35, 36);
UPDATE dbo.Units SET UnitName = '1-й Взвод (Финал)' WHERE UnitID = 1;
UPDATE dbo.Ranks SET RankName = 'Рядовой (Финал)' WHERE RankID = 1;
DELETE FROM dbo.Personnel WHERE PersonnelID IN (31, 32, 33);
GO
