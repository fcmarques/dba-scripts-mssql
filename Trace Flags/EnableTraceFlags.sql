USE [master]
GO
/****** Object:  StoredProcedure [dbo].[EnableTraceFlags]    Script Date: 29/07/2015 14:14:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[EnableTraceFlags]
-- Author  : Victor Isakov
-- Company : SQL Server Solutions (http://www.sqlserversolutions.com.au)
-- Purpose : Enable global trace flags upon SQL Server startup.
-- Notes   : Need to execute sp_procoption to enable this stored procedure to autoexecute
--           whenever SQL Server instance starts:
--           EXEC sp_procoption 'dbo.EnableTraceFlags', 'startup', 'true'
-- Bugs    : None
-- Version : 1.0
-- History :
-- DATE       DESCRIPTION
-- ========== ==================================================
-- 11/04/2011 Version 1.0 released.
AS
BEGIN
	DBCC TRACEON (4199, -1);
	-- Enable Query Optimiser fixes (http://support.microsoft.com/kb/974006)
	--DBCC TRACEON (1222, -1);
	-- Write deadlocks to errorlog (BOL)
	DBCC TRACEON (2549, -1);
	DBCC TRACEON (2562, -1);
	-- DBCC CHECKDB optimization
	DBCC TRACEON (3226, -1);
	-- Supress successfull backup messages (BOL)

	--Ajustadas pela DBACorp
	DBCC TRACEON (2371, -1);
	-- Change threshold for auto update stats
	--DBCC TRACEON (1117, -1);
	-- Simultaneous Autogrowth in Multiple-file database
	--DBCC TRACEON (1118, -1);
	-- Force Uniform Extent Allocation

	DBCC TRACEON (2335, -1);
	--  Generates Query Plans optimized for less memory
	--DBCC TRACEON (9024, -1); startup
	--SQL Server instance partitions the pointer to a memory object at node level
	--DBCC TRACEON (8048, -1);
	-- Force NUMA CPU based partitioning
	--DBCC TRACEON (1236, -1); startup
	--FIX: Performance problems occur when database lock activity increases in SQL Server
	--DBCC TRACEON (8032, -1); startup
	-- Reverts the cache limit parameters to the SQL Server 2005 RTM setting which in general allows caches to be larger
END;
GO

EXEC sp_procoption 'dbo.EnableTraceFlags', 'startup', 'true'
GO

EXEC dbo.EnableTraceFlags
GO
