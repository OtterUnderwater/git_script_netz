ALTER PROCEDURE [wrh].[sys_CreateRequestFromProdPlan]
    @ProdPlanRowID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrderID INT,
            @ProcessID INT,
            @ClientOrderID INT,
            @SrcDepID INT,
            @DepID_Dst INT,
            @WorkCenterID INT,
			@RequestID INT,
            @TotalQty DECIMAL(18,9),
			@DocNumber INT;

    -- Получаем данные из строки плана
    SELECT @OrderID = OrderID, @ProcessID = ProcessID, @WorkCenterID = WorkCenterID
    FROM mes.ProdPlan WHERE ProdPlanRowID = @ProdPlanRowID;  
    
	-- Получаем заказ клиента
    SELECT @ClientOrderID = t2.ClientOrderID FROM mes.Orders t1
    JOIN crm.ClientOrder_Goods t2 ON t1.OrderGoodID = t2.OrderGoodID
    WHERE t1.OrderID = @OrderID;
    
    -- Получаем цех-получатель
    SELECT @DepID_Dst = wc.DepID
    FROM mes.WorkCenter wc
    WHERE wc.WorkCenterID = @WorkCenterID;
    
    -- 1. Получаем состав детали с расчетом потребности
	SELECT i.ItemID, i.WrhDepID AS SrcDepID, p.Qty, ISNULL(p.MeasureID, i.MeasureID) AS ProcMeasureID, i.MeasureID AS ItemMeasureID
	INTO #RequirementsTemp
	FROM mes.Process_Component p
	JOIN dbo.Item i ON p.ItemID = i.ItemID
	WHERE p.ProcessID = @ProcessID
    
    -- 2. Группируем по складам-источникам
    SELECT SrcDepID, SUM(Qty) AS TotalQty
    INTO #RequirementsByDep
    FROM #RequirementsTemp
    GROUP BY SrcDepID
    HAVING SUM(Qty) > 0;
    
    -- 3. Создаём требования для каждого склада
    DECLARE cur CURSOR FOR
        SELECT SrcDepID
        FROM #RequirementsByDep;
    
    OPEN cur;
    FETCH NEXT FROM cur INTO @SrcDepID;
    
    WHILE @@FETCH_STATUS = 0 BEGIN
        -- Создаём ТК
		exec dbo.sys_DocNumber_Generate @DocNumberID = 11 /*Требование на комплектование*/, @NewDocNumber = @DocNumber output
		INSERT INTO wrh.Request (DocNumber,  DocDate,   StateID,         DepID_Src,  DepID_Dst,  OrderID,  ClientOrderID)
						 VALUES (@DocNumber, GETDATE(), 1 /*в работе */, @SrcDepID, @DepID_Dst, @OrderID, @ClientOrderID)
		SET @RequestID = SCOPE_IDENTITY()

        -- Добавляем строки к ТК
		INSERT INTO wrh.RequestRow (ProdPlanRowID, RequestID,  ItemID, Qty, RowNumber, MeasureID,     BaseQty)
		SELECT					   @ProdPlanRowID, @RequestID, ItemID, Qty, 0,         ProcMeasureID, dbo.MeasureRecalc(ItemID, Qty, ProcMeasureID, ItemMeasureID)
		FROM #RequirementsTemp WHERE SrcDepID = @SrcDepID

        -- Нумеруем строки Требования
		exec wrh.obc_RequestRow @ActionID = 100, @RequestID = @RequestID

        FETCH NEXT FROM cur INTO @SrcDepID
    END
    
    CLOSE cur
    DEALLOCATE cur
    
    -- 4. Очистка
    DROP TABLE #RequirementsTemp;
    DROP TABLE #RequirementsByDep;
END;
GO