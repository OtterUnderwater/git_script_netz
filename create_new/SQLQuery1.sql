--Редктирование
ALTER TABLE wrh.RequestRow ADD ProdPlanRowID INT NULL;
ALTER TABLE wrh.Request ADD OrderID INT NULL;
ALTER TABLE mes.WorkCenter ADD DepID INT NULL;

ALTER TABLE wrh.RequestRow ADD CONSTRAINT FK_RequestRow_ProdPlan 
FOREIGN KEY (ProdPlanRowID) REFERENCES mes.ProdPlan(ProdPlanRowID);
ALTER TABLE wrh.Request ADD CONSTRAINT FK_Request_Order 
FOREIGN KEY (OrderID) REFERENCES mes.Orders(OrderID);
ALTER TABLE mes.WorkCenter ADD CONSTRAINT FK_WorkCenter_Department 
FOREIGN KEY (DepID) REFERENCES dbo.Department(DepartmentID);

-- Добавляем поле ProdPlanRowID в таблицу wrh.DocRows
ALTER TABLE wrh.docrows ADD ProdPlanRowID INT NULL
ALTER TABLE wrh.docrows ADD CONSTRAINT FK_docrows_ProdPlan
FOREIGN KEY (ProdPlanRowID) REFERENCES mes.ProdPlan(ProdPlanRowID)

-- Добавляем поле OrderID в таблицу wrh.Docs
ALTER TABLE wrh.docs ADD OrderID INT NULL
ALTER TABLE wrh.docs ADD CONSTRAINT FK_docs_ProdPlan
FOREIGN KEY (OrderID) REFERENCES mes.ProdPlan(ProdPlanRowID)

CREATE TABLE mes.Unit (
    UnitID INT IDENTITY(1,1) PRIMARY KEY,
    ProdPlanRowID INT NOT NULL,
    ProcessID INT NOT NULL,
    Qty DECIMAL(18,9) NOT NULL DEFAULT 0,
    DepID INT NULL,
    RestQty DECIMAL(18,9) NOT NULL DEFAULT 0,

    CONSTRAINT CK_Unit_Qty CHECK (Qty >= 0),
    CONSTRAINT CK_Unit_RestQty CHECK (RestQty >= 0),
    CONSTRAINT FK_Unit_ProdPlan FOREIGN KEY (ProdPlanRowID) REFERENCES mes.ProdPlan(ProdPlanRowID),
    CONSTRAINT FK_Unit_Process FOREIGN KEY (ProcessID) REFERENCES mes.Process(ProcessID),
    CONSTRAINT FK_Unit_Department FOREIGN KEY (DepID) REFERENCES dbo.Department(DepartmentID)
);

CREATE TABLE mes.Order_Unit (
    OrderUnitID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    UnitID INT NOT NULL,
    Qty DECIMAL(18,9) NOT NULL DEFAULT 0,
    OnDate DATE NOT NULL,
    RegID INT NULL,
    -- Ограничения
    CONSTRAINT CK_Order_Unit_Qty CHECK (Qty >= 0),
    CONSTRAINT FK_Order_Unit_Order FOREIGN KEY (OrderID) REFERENCES mes.Orders(OrderID),
    CONSTRAINT FK_Order_Unit_Unit FOREIGN KEY (UnitID) REFERENCES mes.Unit(UnitID)
);