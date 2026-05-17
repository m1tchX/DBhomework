USE master; 
DROP DATABASE IF EXISTS MilitaryNetwork; 
CREATE DATABASE MilitaryNetwork; 
GO
USE MilitaryNetwork;
GO

-- ============================================================================
-- 1 ПУНКТ ЗАДАЧИ: СОЗДАНИЕ ТАБЛИЦ УЗЛОВ (NODES) - минимум 3 (создано 4)
-- ============================================================================

CREATE TABLE Rank -- Звания
( 
    id INT NOT NULL PRIMARY KEY,  
    name NVARCHAR(50) NOT NULL,
    subordination_level INT NOT NULL -- Уровень подчиненности (чем выше, тем старше звание)
) AS NODE;

CREATE TABLE ServiceType -- Формы службы
( 
    id INT NOT NULL PRIMARY KEY,  
    name NVARCHAR(50) NOT NULL,  
    service_term_months INT NOT NULL -- Срок службы в месяцах
) AS NODE;

CREATE TABLE Unit -- Подразделения воинской части
( 
    id INT NOT NULL PRIMARY KEY,  
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Soldier -- Военнослужащие
( 
    id INT NOT NULL PRIMARY KEY,  
    last_name NVARCHAR(50) NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    middle_name NVARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL,
    birth_date DATE NOT NULL,
    address NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    passport_data NVARCHAR(30) NOT NULL
) AS NODE;
GO

-- ============================================================================
-- 2 ПУНКТ ЗАДАЧИ: СОЗДАНИЕ ТАБЛИЦ РЁБЕР (EDGES) - минимум 3 (создано 5)
-- ============================================================================

CREATE TABLE HasRank AS EDGE;          -- Связь: Военнослужащий -> Звание
CREATE TABLE HasServiceType AS EDGE;   -- Связь: Военнослужащий -> Форма службы
CREATE TABLE ServesIn AS EDGE;         -- Связь: Военнослужащий -> Подразделение (Один солдат только в одном подразделении)
CREATE TABLE Commands AS EDGE;         -- Связь: Военнослужащий -> Подразделение (Командир подразделения)
CREATE TABLE SubordinateTo AS EDGE;    -- Связь: Подразделение -> Подразделение (Иерархия подчиненности частей/отрядов)

-- Ограничения подключений для контроля целостности графа
ALTER TABLE HasRank ADD CONSTRAINT EC_HasRank CONNECTION (Soldier TO Rank);
ALTER TABLE HasServiceType ADD CONSTRAINT EC_HasServiceType CONNECTION (Soldier TO ServiceType);
ALTER TABLE ServesIn ADD CONSTRAINT EC_ServesIn CONNECTION (Soldier TO Unit);
ALTER TABLE Commands ADD CONSTRAINT EC_Commands CONNECTION (Soldier TO Unit);
ALTER TABLE SubordinateTo ADD CONSTRAINT EC_SubordinateTo CONNECTION (Unit TO Unit);
GO

-- ============================================================================
-- 3 ПУНКТ ЗАДАЧИ: ЗАПОЛНЕНИЕ ТАБЛИЦ УЗЛОВ (Минимум по 10 строк в каждой)
-- ============================================================================

-- 10 Званий (от Рядового до Генерала)
INSERT INTO Rank (id, name, subordination_level) VALUES 
(1, N'Рядовой', 1),  
(2, N'Ефрейтор', 2),  
(3, N'Младший сержант', 3),  
(4, N'Сержант', 4),  
(5, N'Старший сержант', 5),  
(6, N'Прапорщик', 6),  
(7, N'Лейтенант', 7),  
(8, N'Капитан', 8),  
(9, N'Майор', 9),  
(10, N'Полковник', 10);
GO 

-- 10 Форм службы (различные варианты призыва и контрактов)
INSERT INTO ServiceType (id, name, service_term_months) VALUES 
(1, N'Срочная служба (Призыв)', 12),  
(2, N'Краткосрочный контракт (Тип А)', 6),  
(3, N'Контракт первичный', 24),  
(4, N'Контракт стандартный', 36),  
(5, N'Контракт долгосрочный', 60),  
(6, N'Офицерский контракт (Дебют)', 60),  
(7, N'Контракт сверхсрочный', 12),  
(8, N'Служба в запасе (Сборы)', 2),  
(9, N'Альтернативная гражданская служба', 21),  
(10, N'Особый военный контракт', 18);  
GO

-- 10 Подразделений части (от мелких взводов до Управления)
INSERT INTO Unit (id, name) VALUES 
(1, N'Управление воинской части'),  
(2, N'1-я мотострелковая рота'),  
(3, N'2-я мотострелковая рота'),  
(4, N'1-й стрелковый взвод (1-й роты)'),  
(5, N'2-й стрелковый взвод (1-й роты)'),  
(6, N'Разведывательный взвод'),  
(7, N'Танковый батальон'),  
(8, N'1-я танковая рота'),  
(9, N'Артиллерийский дивизион'),  
(10, N'Взвод материального обеспечения');  
GO  

-- 10 Военнослужащих
INSERT INTO Soldier (id, last_name, first_name, middle_name, gender, birth_date, address, phone, passport_data) VALUES
(1, N'Иванов', N'Иван', N'Иванович', 'M', '1985-05-12', N'г. Москва, ул. Ленина 1', N'+79111111111', N'4505 111111'),
(2, N'Петров', N'Петр', N'Петрович', 'M', '1990-03-22', N'г. Санкт-Петербург, ул. Мира 5', N'+79222222222', N'4006 222222'),
(3, N'Сидоров', N'Алексей', N'Николаевич', 'M', '1995-08-15', N'г. Новосибирск, ул. Кирова 12', N'+79333333333', N'5007 333333'),
(4, N'Кузнецов', N'Сергей', N'Михайлович', 'M', '2000-01-10', N'г. Екатеринбург, ул. Уральская 8', N'+79444444444', N'6508 444444'),
(5, N'Попова', N'Анна', N'Сергеевна', 'F', '1992-11-30', N'г. Самара, ул. Полевая 3', N'+79555555555', N'3609 555555'),
(6, N'Смирнов', N'Дмитрий', N'Александрович', 'M', '1988-07-19', N'г. Нижний Новгород, ул. Окская 4', N'+79666666666', N'2210 666666'),
(7, N'Васильев', N'Андрей', N'Владимирович', 'M', '2001-04-25', N'г. Казань, ул. Татарская 15', N'+79777777777', N'9211 777777'),
(8, N'Павлов', N'Николай', N'Игоревич', 'M', '1994-09-05', N'г. Ростов-на-Дону, ул. Садовая 2', N'+79888888888', N'6012 888888'),
(9, N'Соколов', N'Роман', N'Олегович', 'M', '1997-12-12', N'г. Владивосток, ул. Морская 9', N'+79999999999', N'0513 999999'),
(10, N'Морозов', N'Виталий', N'Юрьевич', 'M', '1983-02-28', N'г. Мурманск, ул. Портовая 11', N'+79000000000', N'4704 000000');
GO

-- ============================================================================
-- 4 ПУНКТ ЗАДАЧИ: ЗАПОЛНЕНИЕ ТАБЛИЦ РЁБЕР (СВЯЗЕЙ)
-- ============================================================================

-- Привязка военнослужащих к званиям (HasRank)
INSERT INTO HasRank ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Soldier WHERE id = 1), (SELECT $node_id FROM Rank WHERE id = 10)), -- Иванов -> Полковник
((SELECT $node_id FROM Soldier WHERE id = 2), (SELECT $node_id FROM Rank WHERE id = 9)),  -- Петров -> Майор
((SELECT $node_id FROM Soldier WHERE id = 3), (SELECT $node_id FROM Rank WHERE id = 8)),  -- Сидоров -> Капитан
((SELECT $node_id FROM Soldier WHERE id = 4), (SELECT $node_id FROM Rank WHERE id = 1)),  -- Кузнецов -> Рядовой
((SELECT $node_id FROM Soldier WHERE id = 5), (SELECT $node_id FROM Rank WHERE id = 6)),  -- Попова -> Прапорщик
((SELECT $node_id FROM Soldier WHERE id = 6), (SELECT $node_id FROM Rank WHERE id = 7)),  -- Смирнов -> Лейтенант
((SELECT $node_id FROM Soldier WHERE id = 7), (SELECT $node_id FROM Rank WHERE id = 1)),  -- Васильев -> Рядовой
((SELECT $node_id FROM Soldier WHERE id = 8), (SELECT $node_id FROM Rank WHERE id = 4)),  -- Павлов -> Сержант
((SELECT $node_id FROM Soldier WHERE id = 9), (SELECT $node_id FROM Rank WHERE id = 3)),  -- Соколов -> Мл. Сержант
((SELECT $node_id FROM Soldier WHERE id = 10), (SELECT $node_id FROM Rank WHERE id = 8)); -- Морозов -> Капитан
GO

-- Привязка к формам службы (HasServiceType)
INSERT INTO HasServiceType ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Soldier WHERE id = 1), (SELECT $node_id FROM ServiceType WHERE id = 5)),
((SELECT $node_id FROM Soldier WHERE id = 2), (SELECT $node_id FROM ServiceType WHERE id = 5)),
((SELECT $node_id FROM Soldier WHERE id = 3), (SELECT $node_id FROM ServiceType WHERE id = 4)),
((SELECT $node_id FROM Soldier WHERE id = 4), (SELECT $node_id FROM ServiceType WHERE id = 1)), -- Срочник
((SELECT $node_id FROM Soldier WHERE id = 5), (SELECT $node_id FROM ServiceType WHERE id = 3)),
((SELECT $node_id FROM Soldier WHERE id = 6), (SELECT $node_id FROM ServiceType WHERE id = 6)),
((SELECT $node_id FROM Soldier WHERE id = 7), (SELECT $node_id FROM ServiceType WHERE id = 1)), -- Срочник
((SELECT $node_id FROM Soldier WHERE id = 8), (SELECT $node_id FROM ServiceType WHERE id = 3)),
((SELECT $node_id FROM Soldier WHERE id = 9), (SELECT $node_id FROM ServiceType WHERE id = 2)),
((SELECT $node_id FROM Soldier WHERE id = 10), (SELECT $node_id FROM ServiceType WHERE id = 6));
GO

-- Распределение военнослужащих по подразделениям (ServesIn)
INSERT INTO ServesIn ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Soldier WHERE id = 1), (SELECT $node_id FROM Unit WHERE id = 1)),
((SELECT $node_id FROM Soldier WHERE id = 2), (SELECT $node_id FROM Unit WHERE id = 2)),
((SELECT $node_id FROM Soldier WHERE id = 3), (SELECT $node_id FROM Unit WHERE id = 4)),
((SELECT $node_id FROM Soldier WHERE id = 4), (SELECT $node_id FROM Unit WHERE id = 4)),
((SELECT $node_id FROM Soldier WHERE id = 5), (SELECT $node_id FROM Unit WHERE id = 10)),
((SELECT $node_id FROM Soldier WHERE id = 6), (SELECT $node_id FROM Unit WHERE id = 5)),
((SELECT $node_id FROM Soldier WHERE id = 7), (SELECT $node_id FROM Unit WHERE id = 5)),
((SELECT $node_id FROM Soldier WHERE id = 8), (SELECT $node_id FROM Unit WHERE id = 6)),
((SELECT $node_id FROM Soldier WHERE id = 9), (SELECT $node_id FROM Unit WHERE id = 8)),
((SELECT $node_id FROM Soldier WHERE id = 10), (SELECT $node_id FROM Unit WHERE id = 7));
GO

-- Назначение командиров подразделений (Commands)
INSERT INTO Commands ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Soldier WHERE id = 1), (SELECT $node_id FROM Unit WHERE id = 1)), -- Полковник Иванов командует Управлением части
((SELECT $node_id FROM Soldier WHERE id = 2), (SELECT $node_id FROM Unit WHERE id = 2)), -- Майор Петров командует 1-й ротой
((SELECT $node_id FROM Soldier WHERE id = 3), (SELECT $node_id FROM Unit WHERE id = 4)), -- Капитан Сидоров командует 1-м взводом
((SELECT $node_id FROM Soldier WHERE id = 6), (SELECT $node_id FROM Unit WHERE id = 5)), -- Лейтенант Смирнов командует 2-м взводом
((SELECT $node_id FROM Soldier WHERE id = 10), (SELECT $node_id FROM Unit WHERE id = 7)); -- Капитан Морозов командует Танковым батальоном
GO

-- Построение иерархии подразделений (SubordinateTo: Кто кому подчиняется)
INSERT INTO SubordinateTo ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Unit WHERE id = 4), (SELECT $node_id FROM Unit WHERE id = 2)),  -- 1-й взвод подчиняется 1-й роте
((SELECT $node_id FROM Unit WHERE id = 5), (SELECT $node_id FROM Unit WHERE id = 2)),  -- 2-й взвод подчиняется 1-й роте
((SELECT $node_id FROM Unit WHERE id = 2), (SELECT $node_id FROM Unit WHERE id = 1)),  -- 1-я рота подчиняется Управлению части
((SELECT $node_id FROM Unit WHERE id = 3), (SELECT $node_id FROM Unit WHERE id = 1)),  -- 2-я рота подчиняется Управлению части
((SELECT $node_id FROM Unit WHERE id = 8), (SELECT $node_id FROM Unit WHERE id = 7)),  -- 1-я танковая рота подчиняется Танковому батальону
((SELECT $node_id FROM Unit WHERE id = 7), (SELECT $node_id FROM Unit WHERE id = 1)),  -- Танковый батальон подчиняется Управлению части
((SELECT $node_id FROM Unit WHERE id = 6), (SELECT $node_id FROM Unit WHERE id = 1)),  -- Разведвзвод подчиняется Управлению части
((SELECT $node_id FROM Unit WHERE id = 9), (SELECT $node_id FROM Unit WHERE id = 1)),  -- Артдивизион подчиняется Управлению части
((SELECT $node_id FROM Unit WHERE id = 10), (SELECT $node_id FROM Unit WHERE id = 1)); -- Взвод обеспечения подчиняется Управлению части
GO

-- ============================================================================
-- 5 ПУНКТ ЗАДАЧИ: ЗАПРОСЫ С MATCH (Не менее 5 различных запросов)
-- ============================================================================

-- Запрос 1: Найти звание конкретного военнослужащего по фамилии (Иванов)
SELECT S.last_name + ' ' + S.first_name AS [Военнослужащий], R.name AS [Звание]
FROM Soldier AS S, HasRank AS hr, Rank AS R
WHERE MATCH(S-(hr)->R)
  AND S.last_name = N'Иванов';

-- Запрос 2: Вывести список всех солдат, служащих в подразделении "1-й стрелковый взвод (1-й роты)"
SELECT S.last_name + ' ' + S.first_name AS [Солдат], U.name AS [Подразделение]
FROM Soldier AS S, ServesIn AS si, Unit AS U
WHERE MATCH(S-(si)->U)
  AND U.name = N'1-й стрелковый взвод (1-й роты)';

-- Запрос 3: Найти ФИО и звание командира для подразделения "1-я мотострелковая рота"
SELECT U.name AS [Подразделение], S.last_name + ' ' + S.first_name AS [Командир], R.name AS [Звание командира]
FROM Unit AS U, Commands AS c, Soldier AS S, HasRank AS hr, Rank AS R
WHERE MATCH(R<-(hr)-S-(c)->U)
  AND U.name = N'1-я мотострелковая рота';

-- Запрос 4: Вывести всех военнослужащих, проходящих службу по форме "Срочная служба (Призыв)"
SELECT S.last_name + ' ' + S.first_name AS [Призывник], ST.name AS [Форма службы], ST.service_term_months AS [Срок (мес)]
FROM Soldier AS S, HasServiceType AS hst, ServiceType AS ST
WHERE MATCH(S-(hst)->ST)
  AND ST.id = 1;

-- Запрос 5: Комплексный поиск — Найти форму службы и звание командира того подразделения, в котором служит рядовой 'Кузнецов'
-- Цепочка: Кузнецов -> где служит (Unit) <- кто командир (Soldier) -> его форма службы (ServiceType)
SELECT 
    Sol.last_name AS [Солдат], 
    U.name AS [Его подразделение], 
    Boss.last_name AS [Его командир], 
    ST.name AS [Форма службы командира]
FROM Soldier AS Sol, ServesIn AS si, Unit AS U, Commands AS c, Soldier AS Boss, HasServiceType AS hst, ServiceType AS ST
WHERE MATCH(Sol-(si)->U<-(c)-Boss-(hst)->ST)
  AND Sol.last_name = N'Кузнецов';
GO

-- ============================================================================
-- 6 ПУНКТ ЗАДАЧИ: ЗАПРОСЫ С SHORTEST_PATH (Не менее 2 запросов, шаблоны "+" и "{1,n}")
-- ============================================================================

-- Запрос 1 (Шаблон "+"): Построить полную иерархическую цепочку подчиненности вверх для "1-го стрелкового взвода (1-й роты)"
SELECT UnitStart.name AS [Начальное подразделение], 
       STRING_AGG(UnitHigher.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS [Цепочка подчинения (до Управления)]
FROM Unit AS UnitStart,
     SubordinateTo FOR PATH AS sub,
     Unit FOR PATH AS UnitHigher
WHERE MATCH(SHORTEST_PATH(UnitStart(-(sub)->UnitHigher)+))
  AND UnitStart.name = N'1-й стрелковый взвод (1-й роты)';

-- Запрос 2 (Шаблон "{1,n}"): Найти подразделения, находящиеся в прямой подчиненности на расстоянии ровно от 1 до 2 уровней от "Управления воинской части"
-- Обратите внимание: Ищем "кто подчиняется Управлению", разворачивая стрелку связи в обратную сторону в MATCH.
SELECT UnitManagement.name AS [Штаб],
       STRING_AGG(SubUnit.name, ', ') WITHIN GROUP (GRAPH PATH) AS [Подразделения 1-2 уровней иерархии]
FROM Unit AS UnitManagement,
     SubordinateTo FOR PATH AS sub,
     Unit FOR PATH AS SubUnit
WHERE MATCH(SHORTEST_PATH(UnitManagement<-(sub)-SubUnit{1,2}))
  AND UnitManagement.name = N'Управление воинской части';
GO

-- ============================================================================
-- 0 ПУНКТ: УДАЛЕНИЕ ДАННЫХ (Для перезапуска или очистки скрипта)
-- ============================================================================
/*
DELETE FROM SubordinateTo;
DELETE FROM Commands;
DELETE FROM ServesIn;
DELETE FROM HasServiceType;
DELETE FROM HasRank;
DELETE FROM Soldier;
DELETE FROM Unit;
DELETE FROM ServiceType;
DELETE FROM Rank;
*/