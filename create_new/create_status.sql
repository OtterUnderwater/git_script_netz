-- 1. Создание статусов
CREATE TABLE mes.ProcessStatus (
StatusID INT IDENTITY(1,1) PRIMARY KEY,
StatusName NVARCHAR(50) NOT NULL UNIQUE
);
ALTER TABLE mes.ProcessStatus ADD StatusColor nvarchar(50) NULL;

-- 2. Добавление базовых статусов
INSERT INTO mes.ProcessStatus (StatusName) VALUES
('План'), ('В работе'), ('Ожидание'), ('Готово')

-- Обновляем цвета для статусов (более яркие оттенки)
UPDATE mes.ProcessStatus 
SET StatusColor = '#90CAF9'  -- Ярко-синий (было #E3F2FD)
WHERE StatusName LIKE '%план%' OR StatusName LIKE '%plan%';

UPDATE mes.ProcessStatus 
SET StatusColor = '#ffc978'  -- Ярко-оранжевый (было #FFF3E0)
WHERE StatusName LIKE '%работ%' OR StatusName LIKE '%work%';

UPDATE mes.ProcessStatus 
SET StatusColor = '#99de9c'  -- Ярко-зеленый (было #E8F5E9)
WHERE StatusName LIKE '%готов%' OR StatusName LIKE '%done%' OR StatusName LIKE '%complete%';

UPDATE mes.ProcessStatus 
SET StatusColor = '#c4c4c4'  -- Ярко-серый (было #F5F5F5)
WHERE StatusName LIKE '%ожидан%' OR StatusName LIKE '%wait%';

-- 3. Добавление колонки StatusID и PersonID в таблицу ProdPlan
ALTER TABLE mes.ProdPlan ADD StatusID INT NULL;
ALTER TABLE mes.ProdPlan ADD CONSTRAINT FK_ProdPlan_ProcessStatus FOREIGN KEY (StatusID) REFERENCES mes.ProcessStatus(StatusID);

ALTER TABLE mes.ProdPlan ADD PersonID INT NULL;
ALTER TABLE mes.ProdPlan ADD CONSTRAINT FK_ProdPlan_Person FOREIGN KEY (PersonID) REFERENCES dbo.Person(PersonID);
ALTER TABLE mes.ProdPlan ADD IsApproved BIT NOT NULL DEFAULT 0;
ALTER TABLE mes.ProdPlan ADD Note NVARCHAR(500) NULL;

-- Добавление колонки WorkCenterID в таблицу Person
ALTER TABLE dbo.Person 
ADD WorkCenterID INT NULL;

-- Добавление внешнего ключа для связи с WorkCenter
ALTER TABLE dbo.Person 
ADD CONSTRAINT FK_Person_WorkCenter 
FOREIGN KEY (WorkCenterID) REFERENCES mes.WorkCenter(WorkCenterID);