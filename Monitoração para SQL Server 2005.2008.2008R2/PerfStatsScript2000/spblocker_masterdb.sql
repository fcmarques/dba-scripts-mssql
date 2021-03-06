if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spBlockerPFE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spBlockerPFE]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE [dbo].[spBlockerPFE] (@endTime DATETIME)
AS

SET NOCOUNT ON
SET LANGUAGE 'us_english'

DECLARE @interval INT
SET @interval = 1

CREATE TABLE #sqlhandle(sql_handle BINARY(20), stmt_start INT, stmt_end INT)
	
EXEC [master].[dbo].[spBlockerPFE_Collect80]  @info = 1, @trace = 1

WHILE GETDATE() < @endTime
BEGIN

   IF @interval % 60 = 0 -- 15 minutes
   
        EXEC [dbo].[spBlockerPFE_Collect80]  @process = 1, @inputbuffer = 1, @sqlhandle_collect = 1, @sqlhandle_flush = 1, 
                                        @lock = 1, @waitstat = 1, @opentran = 1, @logspace = 1, @filestats = 1,
                                        @memstatus = 1, @trace = 1, @spinlock = 1
								 
   ELSE IF @interval % 12 = 0 -- 1 minute
   
        EXEC [dbo].[spBlockerPFE_Collect80]  @process = 1, @inputbuffer = 1, @sqlhandle_collect = 1, @sqlhandle_flush = 1, 
                                        @lock = 1, @opentran = 1, @logspace = 1
	   
   ELSE -- 10 seconds
        EXEC [dbo].[spBlockerPFE_Collect80]  @process = 1, @inputbuffer = 1, @sqlhandle_collect = 1
   
   SET @interval = @interval + 1
   
   RAISERROR('',0,1) WITH NOWAIT

   WAITFOR DELAY '0:0:10'

END
        EXEC [dbo].[spBlockerPFE_Collect80]  
                                        @waitstat = 1, 
                                        @memstatus = 1, 
                                        @trace = 1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

