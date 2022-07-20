<<<<<<< HEAD
CHECKPOINT; 
GO

DECLARE @FREEPROCCACHE NVARCHAR(300)

-- Cursor para percorrer os nomes dos objetos
DECLARE cursor_plans CURSOR FOR
	SELECT 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(1000), cp.plan_handle, 1) + ');' AS FREEPROCCACHE
	FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
	WHERE text
	LIKE N'%ORDER BY CHAM.ID_CHAM_CD_CHAMADO %' OPTION (RECOMPILE); 
	
-- Abrindo Cursor para leitura
OPEN cursor_plans

-- Lendo a próxima linha
FETCH NEXT FROM cursor_plans INTO @FREEPROCCACHE

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

    EXECUTE sp_executesql @FREEPROCCACHE

    -- Lendo a próxima linha
    FETCH NEXT FROM cursor_plans INTO @FREEPROCCACHE
END

-- Fechando Cursor para leitura
CLOSE cursor_plans

-- Desalocando o cursor
DEALLOCATE cursor_plans 
GO

CHECKPOINT; 
=======
CHECKPOINT; 
GO

DECLARE @FREEPROCCACHE NVARCHAR(300)

-- Cursor para percorrer os nomes dos objetos
DECLARE cursor_plans CURSOR FOR
	SELECT 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(1000), cp.plan_handle, 1) + ');' AS FREEPROCCACHE
	FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
	WHERE text
	LIKE N'%ORDER BY CHAM.ID_CHAM_CD_CHAMADO %' OPTION (RECOMPILE); 
	
-- Abrindo Cursor para leitura
OPEN cursor_plans

-- Lendo a próxima linha
FETCH NEXT FROM cursor_plans INTO @FREEPROCCACHE

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

    EXECUTE sp_executesql @FREEPROCCACHE

    -- Lendo a próxima linha
    FETCH NEXT FROM cursor_plans INTO @FREEPROCCACHE
END

-- Fechando Cursor para leitura
CLOSE cursor_plans

-- Desalocando o cursor
DEALLOCATE cursor_plans 
GO

CHECKPOINT; 
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO