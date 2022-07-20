--Comando com maior uso de CPU

SELECT TOP 100
	db_name (qt.dbid) DATA, --nome do banco
	qt.text AS comando, --consulta ou store procedure
	qs.total_worker_time AS 'TotalWorkerTime', --Tempo total de processamento
	qs.total_worker_time/qs.execution_count AS 'AvgWorkerTime', --media de tempo de processamento
	qs.execution_count AS Quantidade_Execucao, -- numero de vezes que o comando foi executado
	ISNULL (qs.execution_count/DATEDIFF(Second, qs.creation_time, GetDate()),0) AS chamadas_seg, --numero de chama por seg
	ISNULL (qs.total_elapsed_time/qs.execution_count, 0) AS Media_Tempo_Gasto, --
	qs.max_logical_reads, qs.max_logical_writes, --numero maximo de escritas logicas
	DATEDIFF(Minute,qs.creation_time, GetDate()) AS Tempo_em_cache -- a quanto tempo que está no cache (minutos)
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS qt
order by qs.total_worker_time DESC


