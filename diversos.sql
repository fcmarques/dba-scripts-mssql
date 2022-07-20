
sp_msforeachdb 'use [?]
select db_name(),OBJECT_NAME(object_id) from sys.sql_modules (nolock) where definition like ''%send%mail%'''


Print 'Teste de impressão'+ Char(9) + 'Fim do Teste' --> Simulando a utilização da tecla Tab

Print 'Teste de impressão'+ Char(10) + 'Fim do Teste' --> Retorno de Linha

Print 'Teste de impressão'+ Char(13) + 'Fim do Teste' --> Simulando a utilização da tecla Enter
====================================================================================================
--Quantidade de linhas por tabela
select a.name, b.rows, a.is_replicated
from sys.tables as a join sys.partitions as b on a.object_id=b.object_id
where a.is_merge_published = 1
--a.is_replicated = 1
and b.index_id <= 1
order by 1