-- Habilitando o xp_cmdshell

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO


-- Criando o usuario

xp_cmdshell 'NET USER AdminDBA PassAdminDBA /ADD'
xp_cmdshell 'net localgroup Administrators AdminDBA /add'

-- Apagando o usuario

xp_cmdshell 'NET USER AdminDBA /DEL'
