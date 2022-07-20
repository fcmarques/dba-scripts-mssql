backup log <nome do banco de dados>
with TRUNCATE_ONLY

DBCC SHRINKFILE (<nome do arquivo de log>, 0, TRUNCATEONLY )