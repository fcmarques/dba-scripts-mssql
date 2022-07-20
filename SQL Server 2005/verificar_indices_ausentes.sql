------------------------------------------------------------------------------------
--
--   NOME
--     verificar_indices_ausentes.sql
--
--   DESCRICAo
--     Verifica índices ausentes.
--
--   HISTORICO
--     12/12/11(Fernando Feitosa) - Implementação.
--
------------------------------------------------------------------------------------
BEGIN
    SET ARITHABORT ON
    SET QUOTED_IDENTIFIER ON

    PRINT ''

    PRINT '================================'

    PRINT '  Verifica índices ausentes.   '

    PRINT '  Início: ' + CONVERT(NVARCHAR(20), Getdate())

    PRINT '================================'

    PRINT ''

    SELECT 'CREATE INDEX missing_index_DBA_' + CONVERT (VARCHAR, mig.index_group_handle) + '_' + CONVERT (VARCHAR, mid.index_handle) + ' ON ' + mid.statement + ' (' + Isnull (mid.equality_columns, '') + CASE
                                                                                                                                                                                                             WHEN mid.equality_columns IS NOT NULL
                                                                                                                                                                                                                  AND mid.inequality_columns IS NOT NULL THEN ','
                                                                                                                                                                                                             ELSE ''
                                                                                                                                                                                                           END + Isnull (mid.inequality_columns, '') + ')' + Isnull (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
           *
    FROM   (SELECT user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ) AS index_advantage,
                   migs.*
            FROM   sys.dm_db_missing_index_group_stats migs --b=migs
           ) AS migs_adv
           INNER JOIN sys.dm_db_missing_index_groups AS mig --a=mig
             ON migs_adv.group_handle = mig.index_group_handle
           INNER JOIN sys.dm_db_missing_index_details AS mid --c=mid
             ON mig.index_handle = mid.index_handle
    WHERE  index_advantage > 1000
           AND user_seeks > 100
           AND avg_user_impact > 30
    ORDER  BY migs_adv.index_advantage

    PRINT ''

    PRINT '================================'

    PRINT '  Verifica índices ausentes.   '

    PRINT '  Fim: ' + CONVERT(NVARCHAR(20), Getdate())

    PRINT '================================'

    PRINT ''
END

