USE [master]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'sp_AuditTraceStop' AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_AuditTraceStop]
GO

CREATE PROCEDURE [dbo].[sp_AuditTraceStop]
AS 

DECLARE @TraceID int
DECLARE @TraceFile sql_variant
DECLARE @TraceFileFin nvarchar(255)
DECLARE @DelCommand nvarchar(255)

DECLARE trace_cursor CURSOR  
    FOR 
		SELECT traceid,value FROM ::fn_trace_getinfo(default)
		WHERE convert(nvarchar(25), value) LIKE '%AuditTrace%'
OPEN trace_cursor  
FETCH NEXT FROM trace_cursor
INTO @TraceID,@TraceFile

WHILE @@FETCH_STATUS = 0
BEGIN
	exec sp_trace_setstatus @TraceID, 0
	exec sp_trace_setstatus @TraceID, 2	
	
	set @TraceFileFin = cast(@TraceFile as nvarchar(255)) + '.trc'
	set @DelCommand = 'del ' + @TraceFileFin

	INSERT INTO msdb..AuditTaceLog
	SELECT * FROM ::fn_trace_gettable(@TraceFileFin, 1)

	
	exec xp_cmdshell @DelCommand

	FETCH NEXT FROM trace_cursor
	INTO @TraceID,@TraceFile
END
CLOSE trace_cursor;  
DEALLOCATE trace_cursor;  