ALTER DATABASE TESTE_LOG_SHIPPING_DEST SET SINGLE_USER WITH ROLLBACK
IMMEDIATE
GO
sp_renamedb TESTE_LOG_SHIPPING_DEST, TESTE_LOG_SHIPING_TARGET
RESTORE DATABASE TESTE_LOG_SHIPPING_DEST WITH RECOVERY
GO
ALTER DATABASE TESTE_LOG_SHIPING_TARGET SET MULTI_USER
GO
