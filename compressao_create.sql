use autcom
go

alter PROCEDURE [dbo].[pr_compress_with_move]
--declare
@tabela             NVARCHAR(250) = NULL,      -- PARAMETRO OPICIONAL
@typeComp    VARCHAR (4) ,              -- PARAMETRO OBRIGAT�RIO
@objeto             NVARCHAR(250) = NULL       -- PARAMETRO OPICIONAL
AS
BEGIN
/************************************************************************
  N�O ESQUECER DE CRIAR OS FILEGROUPS NOVOS (FG_DATA_001 E FG_INDEX_001)
************************************************************************/

/************************************************************************
  EXEMPLO EXECU��O DA PROCEDURE
************************************************************************/

--   EXEC  pr_compress_with_move  @typeComp = 'ROW', Comprime todo o banco
--   EXEC  pr_compress_with_move  @typeComp = 'ROW', @tabela= 'tb_master_transacao_log' comprime apenas a tabela
--   EXEC  pr_compress_with_move  @typeComp = 'ROW', @tabela= 'tb_master_transacao_log', @objeto <index> comprime apena o indice
--   sp_spaceused tb_centralrisco_cliente

-- SELECT * FROM [RSQLADM\MAPS].dbalog.dbo.compress where ctrl = 44-- (select max(ctrl) from [RSQLADM\MAPS].dbalog.dbo.compress)


/************************************************************************
  DECLARA��O DE VARIAVEIS
************************************************************************/
DECLARE 
                    @ctrl               INT,
                    @typeIndex          tinyint ,
                    @cmd                NVARCHAR(4000)

       
-- Servidor/ Inst�ncia: RSQLADM/MAPS - Banco: Dbalog

--create TABLE [dbo].[compress](
--     ctrl int null,
--     server_name varchar(200),
--     [dbname] [varchar](50),
--     [table] [varchar](50),
--     [objeto] [nvarchar](250) NULL,
--     ty bit,
--     [start] [datetime] NULL,
--     [finished] [datetime] NULL,
--     [szidx] [bigint] NULL,
--     command nvarchar(4000)
--) ON [PRIMARY]

/************************************************************************
                    GERA ID CONTROLE
************************************************************************/

SET @ctrl= (SELECT ISNULL ( MAX(ctrl)+1,1) FROM [RSQLADM\MAPS].dbalog.dbo.compress)


/************************************************************************
  INSERE OBJETO(S) NA TABELA DE CONTROLE
************************************************************************/


INSERT INTO [RSQLADM\MAPS].dbalog.dbo.compress (ctrl, server_name, dbname, [table], objeto, ty , start, finished, szidx, command)
SELECT DISTINCT
             @ctrl AS ctrl,
             @@SERVERNAME AS server_name,
             DB_NAME() AS dbname,
             T.name AS [Table], 
             I.name AS [Index],
             I.is_unique AS [type],
             NULL AS start,
             NULL AS finished,
             (SUM(ps.used_page_count)*8)/1024/1024 AS IndexSizeGB,
             ' CREATE ' + CASE WHEN I.is_unique = 1 THEN ' UNIQUE ' ELSE '' END  + 
             I.type_desc COLLATE DATABASE_DEFAULT +' INDEX [' +  
             I.name + '] ON '  + 
             SCHEMA_NAME(T.SCHEMA_ID)+'.'+T.name + ' ( ' +
             KeyColumns + ' )  ' +
             ISNULL(' INCLUDE ('+IncludedColumns+' ) ','') +
             ISNULL(' WHERE  '+I.Filter_definition,'') + ' WITH ( ' +
             'FILLFACTOR = 90' + ','  +
             ' MAXDOP = 2 '  + ','  +
             ' DATA_COMPRESSION= ' +@typeComp + ','  +
             ' DROP_EXISTING = ON '  + ','+
             ' ONLINE = ON '+ ','  +
             ' ALLOW_ROW_LOCKS = ON '+ ','  +
             ' ALLOW_PAGE_LOCKS = ON '+ ') ON ['  +
             CASE WHEN I.is_unique = 1 THEN 'FG_DATA_001' 
                     ELSE 'FG_INDEX_001' END + '] '  [command]
FROM   sys.indexes I
             JOIN sys.tables T 
                    ON T.object_id = I.object_id
      JOIN sys.partitions as p 
                    ON T.object_id = p.object_id
                    and p.index_id = p.index_id
             JOIN sys.dm_db_partition_stats as ps
                    ON p.object_id = ps.object_id 
                     AND p.index_id = ps.index_id 
                      and p.partition_id = ps.partition_id
             JOIN sys.sysindexes SI 
                    ON I.object_id = SI.id 
                    AND I.index_id = SI.indid  
             
             JOIN ( SELECT * 
                           FROM ( SELECT IC2.object_id , 
                                                      IC2.index_id , 
                                                      STUFF((SELECT ' , ' + C.name + 
                                                      CASE WHEN MAX(CONVERT(INT,IC1.is_descending_key)) = 1 THEN ' DESC ' ELSE ' ASC ' END
                                        FROM   sys.index_columns IC1 
                                                      JOIN sys.columns C  
                                                            ON C.object_id = IC1.object_id  
                                                            AND C.column_id = IC1.column_id  
                                                            AND IC1.is_included_column = 0 
                                        WHERE  IC1.object_id = IC2.object_id  
                                                      AND IC1.index_id = IC2.index_id
                                        GROUP BY IC1.object_id,C.name,index_id 
                                        ORDER BY MAX(IC1.key_ordinal) 
                                        FOR XML PATH('')), 1, 2, '') KeyColumns  
             FROM sys.index_columns IC2  
             GROUP BY IC2.object_id ,IC2.index_id) tmp3 )tmp4  
             ON I.object_id = tmp4.object_id AND I.Index_id = tmp4.index_id 
             JOIN sys.stats ST 
                    ON ST.object_id = I.object_id 
                    AND ST.stats_id = I.index_id  
             JOIN sys.data_spaces DS 
                    ON I.data_space_id=DS.data_space_id  
             JOIN sys.filegroups FG 
                    ON I.data_space_id=FG.data_space_id  
             LEFT JOIN (SELECT  * FROM (  
                                                            SELECT  IC2.object_id , IC2.index_id ,  
                                                            STUFF((SELECT ' , ' + C.name 
                                                            FROM   sys.index_columns IC1  
                                                                          JOIN Sys.columns C   
                                                                   ON C.object_id = IC1.object_id   
                                                                   AND C.column_id = IC1.column_id   
                                                                   AND IC1.is_included_column = 1  
                                                            WHERE IC1.object_id = IC2.object_id   
                                                                   AND IC1.index_id = IC2.index_id   
                                                            GROUP BY IC1.object_id,C.name,index_id  
                                                            FOR XML PATH('')), 1, 2, '') IncludedColumns   
                                                            FROM sys.index_columns IC2   
                                                            GROUP BY IC2.object_id ,IC2.index_id) tmp1  
                                  WHERE IncludedColumns IS NOT NULL ) tmp2   
                                  ON tmp2.object_id = I.object_id 
                                  AND tmp2.index_id = I.index_id  
                    WHERE 
                    I.is_unique_constraint = 0              
                    AND p.data_compression = 0 
                    AND I.type_desc NOT LIKE '%SYSTEM%'
                    AND t.name NOT LIKE '%sys%'  
                    AND t.name NOT LIKE '%MS%'  
                    AND (@tabela IS NULL OR T.name  = @tabela)
                    AND (@objeto IS NULL OR I.name  = @objeto)
GROUP BY T.name, 
             I.name ,
             I.index_id,
             I.type_desc,
             I.is_unique,
             T.schema_id,
             I.filter_definition,
             tmp4.KeyColumns,
             tmp2.IncludedColumns,
             DS.name,
             I.is_primary_key
             --,          ps.used_page_count  
ORDER BY T.name


/************************************************************************
  EXECUTAR COMPRESS�O E PREENCHER CONTROLE NA TABELA COMPRESS
************************************************************************/

DECLARE cursor_n1 CURSOR FOR
SELECT [table],objeto, ty FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE ctrl=@ctrl AND finished IS NULL
OPEN cursor_n1
FETCH NEXT FROM cursor_n1 INTO @tabela, @objeto, @typeIndex
WHILE @@FETCH_STATUS = 0
      BEGIN
            
            BEGIN
                          SET   @cmd = (SELECT  command FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE objeto = @objeto AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl AND finished is null)
                  UPDATE [RSQLADM\MAPS].dbalog.dbo.compress set start = GETDATE() WHERE objeto=@objeto AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl
                             --update na tabela compress para controlar o inicio do processo
                  
                             BEGIN TRY
                                  EXEC sp_executesql @cmd
                             END TRY
                             BEGIN CATCH
                                  SET   @cmd = (SELECT REPLACE (command,'ONLINE = ON','ONLINE = OFF') FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE objeto = @objeto 
                                   AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl)
                                  EXEC sp_executesql @cmd
                           END CATCH

                  UPDATE [RSQLADM\MAPS].dbalog.dbo.compress SET finished = GETDATE(), command = @cmd WHERE objeto=@objeto  AND ty = @typeIndex AND [table] = @tabela 
                             AND ctrl = @ctrl
            end
            
                  
      FETCH NEXT FROM cursor_n1 INTO @tabela, @objeto, @typeIndex
END
CLOSE cursor_n1
DEALLOCATE cursor_n1

/***********************************************************************
  AO TERMINAR O PROCESSO N�O ESQUECER DE EXECUTAR O SHRINK PARA LIBERAR 
  O ESPA�O EM DISCO
************************************************************************/


/***********************************************************************
                                        COMPRIMINDO TABELAS HEAPS

************************************************************************/
--if object_id ('tempdb..#cmp') is not null
--drop table #cmp


--select @ctrl as ctrl, @@SERVERNAME as server_name, DB_NAME() as dbname, object_name (a.object_id) as objeto, 2 as ty, null as start, null as finished, (SUM(b.used_page_count)*8)/1024/1024 AS IndexSizeGB
--into #cmp
--from sys.indexes as a 
--       join sys.dm_db_partition_stats as b 
--       on a.object_id=b.object_id 
--       and a.index_id=b.index_id
--       inner join sys.partitions as p
--       on (b.object_id = p.object_id
--       and b.index_id = p.index_id
--       and b.partition_id = p.partition_id)
--where (@tabela IS NULL OR a.object_id =object_id(@tabela))
--and [type_desc] = 'HEAP'
--and p.data_compression = 0

--group by a.object_id, type



--INSERT INTO [RSQLADM\MAPS].dbalog.dbo.compress (ctrl, server_name, dbname, [table], objeto, ty , start, finished, szidx, command)
--select     @ctrl,
--           server_name,
--           dbname,
--           ISNULL(@tabela, objeto) as Tabela,
--           objeto,
--           ty,
--           start,
--           finished,
--           IndexSizeGB,
--           'ALTER TABLE ['+ ISNULL(@tabela, objeto) +'] REBUILD WITH (DATA_COMPRESSION = '+ @typeComp +', ONLINE = ON)' as Command
--from #cmp
--where objeto not like '%sys%'



--DECLARE cursor_n2 CURSOR FOR
--SELECT [table],objeto, ty FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE ctrl=@ctrl AND finished IS NULL
--OPEN cursor_n2
--FETCH NEXT FROM cursor_n2 INTO @tabela, @objeto, @typeIndex
--WHILE @@FETCH_STATUS = 0
--      BEGIN
            
--            BEGIN
--                        SET   @cmd = (SELECT  command FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE objeto = @objeto AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl AND finished is null)
--                  UPDATE [RSQLADM\MAPS].dbalog.dbo.compress set start = GETDATE() WHERE objeto=@objeto AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl
--                           --update na tabela compress para controlar o inicio do processo
                  
--                           BEGIN TRY
--                                EXEC sp_executesql @cmd
--                           END TRY
--                           BEGIN CATCH
--                                SET   @cmd = (SELECT REPLACE (command,'ONLINE = ON','ONLINE = OFF') FROM [RSQLADM\MAPS].dbalog.dbo.compress WHERE objeto = @objeto 
--                                AND ty = @typeIndex AND [table] = @tabela AND ctrl = @ctrl)
--                                EXEC sp_executesql @cmd
--                         END CATCH

--                  UPDATE [RSQLADM\MAPS].dbalog.dbo.compress SET finished = GETDATE(), command = @cmd WHERE objeto=@objeto  AND ty = @typeIndex AND [table] = @tabela 
--                           AND ctrl = @ctrl
--            end
            
                  
--      FETCH NEXT FROM cursor_n2 INTO @tabela, @objeto, @typeIndex
--END
--CLOSE cursor_n2
--DEALLOCATE cursor_n2



end
