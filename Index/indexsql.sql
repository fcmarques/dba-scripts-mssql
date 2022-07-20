--data criacao index
SELECT i.name,o.name,CREATE_DATE 
 FROM SYS.INDEXES I INNER JOIN SYS.OBJECTS O ON I.OBJECT_ID = O.OBJECT_ID
 WHERE I.NAME = 'IX_tb_cadastro_recusado_estacao_avancada_002'
==============================================================================================

go
SELECT distinct b.name,a.avg_fragmentation_in_percent,
case when (a.avg_fragmentation_in_percent > 30) then 'alter index '+b.name+' on '+c.name+' rebuild with (fillfactor = 90, online=on)'
	 when (a.avg_fragmentation_in_percent < 30) then 'ALTER INDEX '+b.name+' on '+c.name+' REORGANIZE WITH ( LOB_COMPACTION = ON )'
	 else '' 
	 end   as cmd
	 into ##index
 FROM sys.dm_db_index_physical_stats (db_id('SICC'),null, NULL, NULL ,NULL) as a 
		join sys.indexes as b on a.object_id = b.object_id and a.index_id = b.index_id
		join sys.objects as c on a.object_id = c.object_id
		--where a.avg_fragmentation_in_percent > 10

=================================================================================================
--Verifica quantas linha foram alteradas desde o ultimo rebuild

select  i.id ObjectId,  t.name TableName, i.indid Index_Stat_Id,  i.name Index_Stat_Name,  i.rowmodctr, i.rows, i.dpages
	from sysindexes i join sys.tables t on i.id = t.object_id
WHERE i.rowmodctr >= i.rows*0.20
	   and i.rowmodctr >0
=====================================================================================================
--Identica os indices que não estam sendo utilizados

SELECT OBJECT_NAME(SI.object_id),SI.name,* 
	FROM sys.dm_db_index_usage_stats IUS INNER JOIN sys.indexes SI ON SI.index_id = IUS.index_id
		AND SI.object_id = IUS.object_id INNER JOIN sys.partitions SP ON SP.object_id = IUS.object_id
		AND SP.index_id = IUS.index_id INNER JOIN sys.allocation_units AU ON AU.container_id = SP.partition_id
WHERE IUS.database_id = db_id('SICC')
	AND IUS.object_id > 100 AND SI.index_id > 0
	AND IUS.last_user_lookup is null
	and IUS.last_user_scan is null
	and IUS.last_user_lookup is null
	and IUS.last_user_seek is null
	and SI.type_desc ='NONCLUSTERED'
	--and IUS.last_user_seek < GETDATE() - 14)
ORDER BY user_updates DESC

=============================================================================================
SELECT o.name Object_Name,    SCHEMA_NAME(o.schema_id) Schema_name,
       i.name Index_name,i.index_id,   i.Type_Desc,     s.user_seeks,
       s.user_scans,        s.user_lookups,        s.user_updates  , s.last_user_lookup,s.last_user_scan,s.last_user_seek
 FROM sys.objects AS o  JOIN sys.indexes AS i ON o.object_id = i.object_id 
     JOIN  sys.dm_db_index_usage_stats AS s     ON i.object_id = s.object_id     AND i.index_id = s.index_id
 WHERE  o.name = 'tb_lancamento_evento_extrato'
order by s.user_seeks  

SELECT o.name Object_Name,  i.name Index_name,i.index_id,   i.Type_Desc,  
	   sum(   s.user_seeks),
       sum(s.user_scans), sum( s.user_lookups), max( s.user_updates)  ,max( s.last_user_lookup),max(s.last_user_scan),max(s.last_user_seek)
 FROM sys.objects AS o  JOIN sys.indexes AS i ON o.object_id = i.object_id 
     JOIN  sys.dm_db_index_usage_stats AS s     ON i.object_id = s.object_id     AND i.index_id = s.index_id
 WHERE  o.name = 'ged_doc'
 group by o.name,i.index_id,i.name,i.type_desc

============================================================================================
--Verificar como esta o processo de rebuild quando executamos online
SELECT OBJECT_NAME(object_id) AS [Object Name], 
    SUM(Rows) AS [RowCount], data_compression_desc AS [Compression Type]
    FROM sys.partitions WITH (NOLOCK)
    WHERE 
	--index_id < 2
     OBJECT_NAME(object_id) = 'item_venda_hist'
    GROUP BY object_id, data_compression_desc
    ORDER BY SUM(Rows) DESC;

	SELECT OBJECT_NAME(object_id) AS [Object Name], Rows
    FROM sys.partitions WITH (NOLOCK)
    WHERE index_id < 2
    AND object_id=1582068822


======================================================
--verifica o tamanho do indice
SELECT OBJECT_NAME(object_id) AS [Object Name], index_id,
    Rows, data_compression_desc AS [Compression Type]
    FROM sys.partitions WITH (NOLOCK)
    WHERE --index_id != 0 and
     OBJECT_NAME(object_id) = 'MBEWH'
    order by index_id
    
    
======================================================
    
    select a.name,
        a.index_id,
		a.type_desc,
		(SUM(b.used_page_count)*8)/1024/1024 AS IndexSizeGB
 from sys.indexes as a join sys.dm_db_partition_stats as b on a.object_id=b.object_id and a.index_id=b.index_id
 where a.object_id =object_id('MBEWH')
 --and a.index_id!=0
 group by a.name, a.index_id,a.type_desc
 

 
 
 =======================================================
 create unique clustered index [MSEG~0] on [qa1].[MSEG] 
(
	[MANDT] ASC,
	[MBLNR] ASC,
	[MJAHR] ASC,
	[ZEILE] ASC
)WITH (maxdop=4,drop_existing=on, data_compression=page,PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
 IGNORE_DUP_KEY = OFF, ONLINE = on, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
 ON [PRIMARY]
GO

 create unique clustered index [MSEG~0] on [qa1].[MSEG] 
(
	[MANDT] ASC,
	[MBLNR] ASC,
	[MJAHR] ASC,
	[ZEILE] ASC
)WITH (maxdop=4,drop_existing=on, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
 IGNORE_DUP_KEY = OFF, ONLINE = on, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
 ON [PRIMARY]
GO
--=================================================================================
--mostra as colunas indexadas por indice
select s.name, t.name, i.name, c.name
 from sys.tables t
inner join sys.schemas s on t.schema_id = s.schema_id
inner join sys.indexes i on i.object_id = t.object_id
inner join sys.index_columns ic on ic.object_id = t.object_id
	inner join sys.columns c on c.object_id = t.object_id and
		ic.column_id = c.column_id

where i.index_id > 0    
and i.type in (1, 2) -- clustered & nonclustered only
and i.is_primary_key = 0 -- do not include PK indexes
and i.is_unique_constraint = 0 -- do not include UQ
and i.is_disabled = 0
and i.is_hypothetical = 0
and ic.key_ordinal > 0

order by ic.key_ordinal
================
--select * from sys.index_columns
select s.name, t.name as [table], i.name as index_name, c.name as column_name
 from sys.tables t
inner join sys.schemas s on t.schema_id = s.schema_id
inner join sys.indexes i on i.object_id = t.object_id
inner join sys.index_columns ic on ic.object_id = t.object_id
	inner join sys.columns c on c.object_id = t.object_id and
		ic.column_id = c.column_id

where i.index_id > 0    
and i.type in (1, 2) -- clustered & nonclustered only
and i.is_primary_key = 0 -- do not include PK indexes
and i.is_unique_constraint = 0 -- do not include UQ
and i.is_disabled = 0
and i.is_hypothetical = 0
and ic.key_ordinal > 0
and i.name in (

select  c.name
from sys.dm_db_index_usage_stats as a join sys.tables as b on a.object_id=b.object_id 
									  join sys.indexes as c on a.object_id=c.object_id
									  join sys.index_columns as d  on a.object_id=d.object_id
									  
where user_lookups =0
and user_scans=0
and user_seeks=0
)


sp_helpdb autcom
