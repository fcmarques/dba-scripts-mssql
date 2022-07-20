----------------------------------------------------------------------------------
--
-- Trace management scripts for use with ClearTrace
--
-- Copyright scaleSQL Consulting, LLC 2011
-- 
----------------------------------------------------------------------------------
if exists (select * 
			from dbo.sysobjects 
			where id = object_id(N'[dbo].[admin_trace_filepurge]') 
			and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[admin_trace_filepurge]
GO

if exists (select * 
			from dbo.sysobjects 
			where id = object_id(N'[dbo].[admin_trace_start]') 
			and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[admin_trace_start]
GO

if exists (select * 
			from dbo.sysobjects 
			where id = object_id(N'[dbo].[admin_trace_stopall]') 
			and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[admin_trace_stopall]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE admin_trace_filepurge (
	@Directory NVARCHAR(1000) = NULL, 
	@FileName NVARCHAR(1000) = NULL,
	@DaysToRetain INT = 21 )
AS

----------------------------------------------------------------------------------
--
-- Trace management scripts for use with ClearTrace
--
-- Copyright scaleSQL Consulting, LLC 2011
-- 
----------------------------------------------------------------------------------


SET NOCOUNT ON 

IF @Directory IS NULL OR @FileName is NULL 
  BEGIN
	PRINT 'Usage: admin_trace_filepurge 
	@Directory (Required), 
	@FileName (Required),
	@DaysToRetain (Optional) defaults to 21 days'
	return 1
  END

DECLARE @FileNameFilter NVARCHAR(1000)
DECLARE @TraceFileName NVARCHAR(1000)
DECLARE @Cmd NVARCHAR(1000)

DECLARE	@LastWriteDate DATETIME
DECLARE @LastWriteText VARCHAR(8)

IF OBJECT_ID('tempdb..#FileExistResult') IS NOT NULL
    DROP TABLE #FileExistResult	

IF OBJECT_ID('tempdb..#DirResult') IS NOT NULL
    DROP TABLE #DirResult

IF OBJECT_ID('tempdb..#FileDetails') IS NOT NULL
    DROP TABLE #FileDetails

IF OBJECT_ID('tempdb..#DelResult') IS NOT NULL
    DROP TABLE #DelResult


CREATE TABLE #FileExistResult (FileExists INT, Directory INT, Parent INT)
CREATE TABLE #DirResult ( FileName VARCHAR(1000) )
CREATE TABLE #DelResult ( [Output]  VARCHAR(1000) )


CREATE TABLE #FileDetails  (
	[Alternate Name] NVARCHAR(1000) NULL,
	[Size] INT NULL,
	[Creation Date] VARCHAR(8) NULL,
	[Creation Time] VARCHAR(8) NULL,
	[Last Written Date]  VARCHAR(8) NULL,
	[Last Written Time] VARCHAR(8) NULL,
	[Last Accessed Date] VARCHAR(8) NULL,
	[Last Accessed Time] VARCHAR(8) NULL,
	Attributes INT NULL )


-- Parse Directory
IF @Directory IS NULL
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END

-- Check that the directory exists
INSERT #FileExistResult
EXEC xp_fileexist @Directory

IF NOT EXISTS ( SELECT * FROM #FileExistResult WHERE Directory = 1)
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END


-- Parse FileName
IF @FileName IS NULL
    BEGIN
	RAISERROR ('Invalid FileName specified', 16, 1)
	return 1
    END


IF RIGHT(@Directory, 1) <> '\'
	SET @Directory = @Directory + '\'

IF RIGHT(@FileName, 4) = '.trc'
	SET @FileName = LEFT(@FileName, LEN(@FileName) - 4)


SELECT	@FileNameFilter = @Directory + @FileName + '*.trc'

SET @Cmd = 'dir /b ' + @FileNameFilter

INSERT #DirResult
EXEC master.dbo.xp_cmdshell @Cmd

-- SELECT * 
-- FROM #DirResult
-- WHERE FileName IS NOT NULL

DECLARE cFiles CURSOR
READ_ONLY
FOR 
SELECT FileName
FROM #DirResult
WHERE FileName IS NOT NULL

OPEN cFiles

FETCH NEXT FROM cFiles INTO @TraceFileName
WHILE (@@fetch_status = 0)
    BEGIN

	SET @TraceFileName = @Directory + @TraceFileName

	--PRINT @TraceFileName

	DELETE #FileDetails

	INSERT #FileDetails
	EXEC xp_getfiledetails @TraceFileName

	SELECT @LastWriteDate = [Last Written Date]
	FROM #FileDetails

	-- Print @TraceFileName + ' :::: ' + CAST(@LastWriteDate AS VARCHAR)

	IF @LastWriteDate < DATEADD(dd, -1* @DaysToRetain, GETDATE() )
	    BEGIN	
		Print 'Deleting ' + @TraceFileName + ' (' + CONVERT(VARCHAR, @LastWriteDate, 1) + ')'
		SET @Cmd = 'DEL ' + @TraceFileName
		--Print @Cmd

		DELETE #DelResult

		INSERT #DelResult
		exec master.dbo.xp_cmdshell @Cmd


		If (SELECT COUNT(*) FROM #DelResult) <> 1
			OR (SELECT COUNT(*) FROM #DelResult WHERE [output] IS NULL ) <> 1
			    BEGIN
				SELECT * FROM #DelResult
				RAISERROR('Error deleting file: %s', 16, 1, @TraceFileName)
			    END
	    END
	ELSE
		PRINT 'Skipping ' + @TraceFileName + ' (' + CONVERT(VARCHAR, @LastWriteDate, 1) + ')'
	

--	SELECT @LastWrite

	FETCH NEXT FROM cFiles INTO @TraceFileName
    END

CLOSE cFiles
DEALLOCATE cFiles





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE admin_trace_start (
	@Directory NVARCHAR(1000) = NULL, 
	@FileName NVARCHAR(1000) = NULL,
	@TraceMinutes INT = 5,
	@IncludeTimeStamp bit = 1,
	@MaxFileSize BIGINT = 50,
	@MinCPU INT = NULL,
	@MinReads BIGINT = NULL,
	@MinDuration BIGINT = NULL,
	@MinWrites BIGINT = NULL )
AS

----------------------------------------------------------------------------------
--
-- Trace management scripts for use with ClearTrace
--
-- Copyright ClearData Consulting, Inc. 2006
-- 
-- V2 (3/19/2007)
-- ---------------------------------------------------------
-- Changed the default file size to 50MB
-- Removed the filter on database ID 7
-- Added characters to the date and time stamp to play better with SQL Server 2005
----------------------------------------------------------------------------------

SET NOCOUNT ON 

IF @Directory IS NULL OR @FileName is NULL 
  BEGIN
	PRINT 'Usage: admin_trace_start 
	@Directory (Required), 
	@FileName (Required),
	@TraceMinutes (Optional -- Defaults to 5),
	@IncludeTimeStamp (Optional -- Defaults to 1),
	@MaxFileSize (Optional -- Defaults to 50),
	@MinCPU (Optional),
	@MinReads (Optional),
	@MinDuration (Optional),
	@MinWrites (Optional)'
	return 1
  END

DECLARE @TraceFileName NVARCHAR(1000)
DECLARE @TempFileName NVARCHAR(1000)
DECLARE @TraceID INT
DECLARE @RC INT

DECLARE @TraceStopTime DATETIME
SELECT @TraceStopTime = DATEADD(mi, @TraceMinutes, GETDATE())

IF OBJECT_ID('tempdb..#FileExistResult') IS NOT NULL
    DROP TABLE #FileExistResult	

CREATE TABLE #FileExistResult (FileExists INT, Directory INT, Parent INT)

-- Parse Directory
IF @Directory IS NULL
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END

-- Check that the directory exists
INSERT #FileExistResult
EXEC xp_fileexist @Directory

IF NOT EXISTS ( SELECT * FROM #FileExistResult WHERE Directory = 1)
    BEGIN
	RAISERROR ('Invalid Directory specified', 16, 1)
	return 1
    END


-- Parse FileName
IF @FileName IS NULL
    BEGIN
	RAISERROR ('Invalid FileName specified', 16, 1)
	return 1
    END


-- Build the trace file name
IF RIGHT(@Directory, 1) <> '\'
	SET @Directory = @Directory + '\'

IF RIGHT(@FileName, 4) = '.trc'
	SET @FileName = LEFT(@FileName, LEN(@FileName) - 4)

-- Add an optional datestamp to the file name
if @IncludeTimestamp = 1
	SET @FileName = @FileName + '_D' + CONVERT(VARCHAR, GETDATE(), 112) + '_Z' +  REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '')

SET @TraceFileName = @Directory + @FileName

-- Start the trace
exec @rc = sp_trace_create @TraceID output, 2, @TraceFileName, @maxfilesize, @TraceStopTime 
if (@rc <> 0) 
    BEGIN
	RAISERROR ('Error calling sp_trace_create', 16, 1)
	return @RC
    END

-- Set the events
declare @on bit
set @on = 1
------------------------------------------------------------------------------------------
-- Paste all sp_trace_setevent statements here
------------------------------------------------------------------------------------------
-- Text Data
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 12, 1, @on

-- Host Name
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 12, 8, @on

-- Application Name
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 12, 10, @on

-- Login Name
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 12, 11, @on

exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
------------------------------------------------------------------------------------------
-- End sp_trace_setevent statements
------------------------------------------------------------------------------------------

-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'

-- exclude the connectioin pooling reset command
exec sp_trace_setfilter @TraceID, 1, 0, 7, N'exec sp_reset_connection'

-- Duration Filter
IF @MinDuration IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 13, 1, 4, @MinDuration
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Duration', 16, 1)
		return @RC
	    END


-- Reads Filter
IF @MinReads IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 16, 1, 4, @MinReads
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Reads', 16, 1)
		return @RC
	    END

-- CPU Filter
IF @MinCPU IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 18, 1, 4, @MinCPU
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Reads', 16, 1)
		return @RC
	    END


-- Writes Filter
IF @MinWrites IS NOT NULL
	exec @RC = sp_trace_setfilter @TraceID, 17, 1, 4, @MinWrites
	if (@RC <> 0) 
	    BEGIN
		RAISERROR ('Failed to set filter on Writes', 16, 1)
		return @RC
	    END


-- Set the trace status to start
exec @RC = sp_trace_setstatus @TraceID, 1
if (@rc <> 0) 
    BEGIN
	RAISERROR ('Trace failed to start', 16, 1)
	return @RC
    END

-- display trace id for future references
Print 'TraceID: ' + CAST(@TraceID AS VARCHAR)
PRINT 'Tracing to: ' + @TempFileName
Print 'Run for ' + CAST(@TraceMinutes AS VARCHAR) + ' minute(s) until ' + CONVERT(VARCHAR, @TraceStopTime)

IF @MinDuration IS NOT NULL
	PRINT 'Duration Filter: ' + CAST(@MinDuration AS VARCHAR) + 'ms'

IF @MinCPU IS NOT NULL
	PRINT 'CPU Filter: ' + CAST(@MinCPU AS VARCHAR) + 'ms'

IF @MinReads IS NOT NULL
	PRINT 'Reads Filter: ' + CAST(@MinReads AS VARCHAR) + 'ms'

IF @MinWrites IS NOT NULL
	PRINT 'Writes Filter: ' + CAST(@MinWrites AS VARCHAR) + 'ms'




DROP TABLE #FileExistResult
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE admin_trace_stopall (
	@BaseFile NVARCHAR(1000) = NULL )
AS

----------------------------------------------------------------------------------
--
-- Trace management scripts for use with ClearTrace
--
-- Copyright scaleSQL Consulting, LLC 2011
-- 
----------------------------------------------------------------------------------

DECLARE @TraceID INT
DECLARE @RC INT

DECLARE cTraces CURSOR
READ_ONLY
FOR 
SELECT DISTINCT TraceID 
FROM :: fn_trace_getinfo(default) 
where 	property = 2
AND 	CAST(value AS NVARCHAR(2000)) LIKE @BaseFile + '%'


OPEN cTraces

FETCH NEXT FROM cTraces INTO @TraceID
WHILE (@@fetch_status = 0 )
    BEGIN
	
	-- Stop the trace
	EXEC @RC = sp_trace_setstatus @TraceID, 0
	IF @RC = 0 PRINT 'Stopping TraceID: ' + CAST(@TraceID AS VARCHAR)
	ELSE 
	    BEGIN
		PRINT 'Error Stopping TraceID: ' + CAST(@TraceID AS VARCHAR)
			+ ' Error Code: ' + CAST(@RC AS VARCHAR)
		RAISERROR ('Unable to stop Trace', 16, 1)
	    END
	
	-- Delete the trace
	EXEC @RC = sp_trace_setstatus @TraceID, 2
	IF @RC = 0 PRINT 'Deleting TraceID: ' + CAST(@TraceID AS VARCHAR)
	ELSE 
	    BEGIN
		PRINT 'Error Deleting TraceID: ' + CAST(@TraceID AS VARCHAR)
			+ ' Error Code: ' + CAST(@RC AS VARCHAR)
		RAISERROR ('Unable to delete Trace', 16, 1)
	    END

	FETCH NEXT FROM cTraces INTO @TraceID
    END

CLOSE cTraces
DEALLOCATE cTraces


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

