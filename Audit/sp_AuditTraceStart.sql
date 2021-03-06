USE [master]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE name = N'sp_AuditTraceStart' AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_AuditTraceStart]
GO

CREATE PROCEDURE [dbo].[sp_AuditTraceStart]
AS 

/****************************************************/
/* Created by: Fabio Marques                        */
/* Date: 03/11/2016  13:58:15                       */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 100 
declare @DirName nvarchar(100)
set @DirName = 'E:\Dbalog\'
declare @FileName nvarchar(100)
set @FileName = @DirName + 'AuditTrace_' + @@SERVERNAME + '_' + replace(replace(replace(convert(nvarchar(25),GETDATE(),120), '-',''),' ',''),':','')

exec @rc = sp_trace_create @TraceID output, 0, @FileName, @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 14, 3, @on
exec sp_trace_setevent @TraceID, 14, 11, @on
exec sp_trace_setevent @TraceID, 14, 23, @on
exec sp_trace_setevent @TraceID, 14, 2, @on
exec sp_trace_setevent @TraceID, 14, 8, @on
exec sp_trace_setevent @TraceID, 14, 10, @on
exec sp_trace_setevent @TraceID, 14, 12, @on
exec sp_trace_setevent @TraceID, 14, 14, @on
exec sp_trace_setevent @TraceID, 14, 26, @on
exec sp_trace_setevent @TraceID, 14, 1, @on
exec sp_trace_setevent @TraceID, 14, 9, @on
exec sp_trace_setevent @TraceID, 14, 41, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

set @intfilter = 13
exec sp_trace_setfilter @TraceID, 3, 1, 0, @intfilter

set @intfilter = 6
exec sp_trace_setfilter @TraceID, 3, 1, 0, @intfilter

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 5c338792-cf85-4ad8-861c-9897b8288ab7'
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
