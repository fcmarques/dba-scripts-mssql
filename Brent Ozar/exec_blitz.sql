EXEC [dbo].[sp_Blitz]
    @CheckUserDatabaseObjects = 1 ,
    @CheckProcedureCache = 1 ,
    @OutputType = 'TABLE' ,
    @OutputProcedureCache = 0 ,
    @CheckProcedureCacheFilter = NULL,
    @CheckServerInfo = 1