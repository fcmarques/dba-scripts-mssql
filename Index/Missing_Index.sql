/*********************************************************
INÍCIO DA ROTINA
*********************************************************/             
/*********************************************************
CRIAÇÃO DE TABELAS TEMPORÁRIAS 
*********************************************************/                              

                  IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
                             DROP TABLE #tmp
                  CREATE TABLE #tmp(
                  name                    VARCHAR(500),
                  index_advantage         FLOAT,
                  stat                    NVARCHAR(4000),
                  avg_user_impact         FLOAT,
                  equality_columns  NVARCHAR(4000), 
                  inequality_columns      NVARCHAR(4000), 
                  included_columns  NVARCHAR(4000))
                  
                  IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL
                        DROP TABLE #tmp2

                  CREATE TABLE #tmp2(
                  stat        NVARCHAR(4000),
                  cmd         NVARCHAR(4000))


/*********************************************************
INSERINDO DADOS DAS DMVS NA TABELA TEMPORÁRIA
*********************************************************/             

                  INSERT INTO #tmp (name,index_advantage,stat,avg_user_impact,equality_columns, inequality_columns, included_columns)
                  SELECT db.name,index_advantage,statement AS stat,avg_user_impact,equality_columns, inequality_columns, included_columns
                  FROM (SELECT user_seeks * avg_total_user_cost *(avg_user_impact * 0.01) AS index_advantage, migs. * 
                          FROM sys.dm_db_missing_index_group_stats migs)AS migs_adv
                  INNER JOIN sys.dm_db_missing_index_groups AS mig
                        ON migs_adv.group_handle = mig.index_group_handle
                  INNER JOIN sys.dm_db_missing_index_details AS mid
                        ON mig.index_handle = mid.index_handle
                  INNER JOIN sys.databases AS db
                        ON mid.database_id = db.database_id
                  WHERE index_advantage > 95
                 -- AND statement like '%PLUSOFTCRM%' /* PARA FILTRAR SOMENTE UM BANCO DE DADOS, RETIRAR O COMENTÁRIO E INFORMAR O NOME DO BANCO DESEJADO */
                  ORDER BY db.name


      
/*********************************************************
GERANDO COMANDO PARA CRIAÇÃO DE ÍNDICES
*********************************************************/             
            -- CASO 1         
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ ' ('+equality_columns+') '+' INCLUDE '+'('+included_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NOT NULL AND inequality_columns IS NULL AND included_columns IS NOT NULL
            

            -- CASO 2
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+ ' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ ' ('+equality_columns+','+inequality_columns+') '+' INCLUDE '+ '('+included_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NOT NULL AND inequality_columns IS NOT NULL AND included_columns IS NOT NULL 
            

            -- CASO 3
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ '('+equality_columns+','+inequality_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NOT NULL AND inequality_columns IS NOT NULL AND included_columns IS NULL
            
            
            -- CASO 4
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ '('+equality_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NOT NULL AND inequality_columns IS NULL AND included_columns IS NULL
            
            
            -- CASO 5
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ '('+inequality_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NULL AND inequality_columns IS NOT NULL AND included_columns IS NULL
            
            
            -- CASO 6
            INSERT INTO #tmp2(stat,cmd)
            SELECT stat,'CREATE NONCLUSTERED INDEX '+' IX_'+REPLACE(RIGHT(stat,10),'.','')+'_'+LEFT(REPLACE(CONVERT(INT,CHECKSUM(NEWID())),'-',''),3)+' ON ' +stat+ '('+inequality_columns+')'+' INCLUDE '+ '('+included_columns+')' AS cmd
            FROM #tmp
            WHERE equality_columns IS NULL AND inequality_columns IS NOT NULL AND included_columns IS NOT NULL



/*********************************************************
RETIRANDO OS COLCHETES DO COMANDO
*********************************************************/             
            
            UPDATE #tmp2
            SET cmd = REPLACE(cmd,'[','')

            UPDATE #tmp2
            SET cmd = REPLACE(cmd,']','')
	
			update #tmp2
			set stat = replace (stat,'[PLUSOFTCRM].[dbo].[','')
			UPDATE #tmp2
            SET stat = REPLACE(stat,']','')
	
			
			
/*********************************************************
RRETORNO
*********************************************************/             
SELECT *
FROM #tmp2
where stat like '%posicao_do_estoque%'
order by stat

--select distinct (stat) from #tmp

/*********************************************************
FIM DA ROTINA
*********************************************************/             



             


