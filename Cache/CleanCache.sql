<<<<<<< HEAD
CHECKPOINT
GO
DBCC DROPCLEANBUFFERS
GO
-- 1 –  Eliminar as páginas de buffer limpas
DBCC DROPCLEANBUFFERS
GO
-- 2 – Eliminar todas as entradas do CACHE de "Procedures"
DBCC FREEPROCCACHE
GO 
-- 3 – Limpar as entradas de Cache não utilizadas
DBCC FREESYSTEMCACHE ( 'ALL' )
=======
CHECKPOINT
GO
DBCC DROPCLEANBUFFERS
GO
-- 1 –  Eliminar as páginas de buffer limpas
DBCC DROPCLEANBUFFERS
GO
-- 2 – Eliminar todas as entradas do CACHE de "Procedures"
DBCC FREEPROCCACHE
GO 
-- 3 – Limpar as entradas de Cache não utilizadas
DBCC FREESYSTEMCACHE ( 'ALL' )
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO