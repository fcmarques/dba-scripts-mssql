<<<<<<< HEAD
-- If the version is not SP1 then do not run the script
IF SERVERPROPERTY(N'ProductVersion') <> '9.00.2047.00'
BEGIN
	RAISERROR('You can turn on EAL1 trace only on SQL Server 2005 SP1', 20, 127) WITH LOG
END

USE master
GO

if object_id('dbo.sp_create_evaltrace','P') IS NOT NULL
	drop procedure dbo.sp_create_evaltrace
GO

CREATE PROCEDURE sp_create_evaltrace
-- Create the trace
AS
	-- Declare local variables
	declare @rc int
	declare @on bit
	declare @instanceroot nvarchar(256)
	declare @scriptname nvarchar(50)
	declare @tracefile nvarchar(256)
	declare @maxfilesize bigint
	declare @filecount int
	declare @traceid int 

	set @maxfilesize =100
	set @filecount =100

	-- Trace file name
	set @scriptname = 'cc_trace_' + REPLACE(REPLACE(CONVERT( varchar(50), getdate(),126), ':', ''), '.','')

	-- Get the instance specific LOG directory
	-- Get the instance specific root directory.
	set @instanceroot = ''
=======
-- If the version is not SP1 then do not run the script
IF SERVERPROPERTY(N'ProductVersion') <> '9.00.2047.00'
BEGIN
	RAISERROR('You can turn on EAL1 trace only on SQL Server 2005 SP1', 20, 127) WITH LOG
END

USE master
GO

if object_id('dbo.sp_create_evaltrace','P') IS NOT NULL
	drop procedure dbo.sp_create_evaltrace
GO

CREATE PROCEDURE sp_create_evaltrace
-- Create the trace
AS
	-- Declare local variables
	declare @rc int
	declare @on bit
	declare @instanceroot nvarchar(256)
	declare @scriptname nvarchar(50)
	declare @tracefile nvarchar(256)
	declare @maxfilesize bigint
	declare @filecount int
	declare @traceid int 

	set @maxfilesize =100
	set @filecount =100

	-- Trace file name
	set @scriptname = 'cc_trace_' + REPLACE(REPLACE(CONVERT( varchar(50), getdate(),126), ':', ''), '.','')

	-- Get the instance specific LOG directory
	-- Get the instance specific root directory.
	set @instanceroot = ''
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @instanceroot OUTPUT

	IF @instanceroot = '' OR @instanceroot = NULL
	BEGIN
		-- Exit the procedure
		raiserror ('Could not obtain the instance root directory using xp_instance_regread.', 18,127)
		return(1)
	END

	-- Prepare the Trace file.
	IF SUBSTRING(@instanceroot, Len(@instanceroot)-1, 1) != '\'
		set @instanceroot = @instanceroot + '\'
<<<<<<< HEAD

	set @tracefile = @instanceroot + 'LOG\'+ @scriptname


	-- Create the trace
	exec @rc = sp_trace_create @traceid OUTPUT, 6, @tracefile, @maxfilesize, NULL , @filecount
	IF (@rc != 0) 
	begin
		return (1)
	end


	-- Add Trace Events
	set @on = 1
 
	-- Audit Login
	exec sp_trace_setevent @TraceID, 14, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 14, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 14, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 14, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 14, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 14, 64, @on  -- SessionLoginName
	 
	-- Audit Logout
	exec sp_trace_setevent @TraceID, 15, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 15, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 15, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 15, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 15, 64, @on  -- SessionLoginName

	-- Audit Login Failed
	exec sp_trace_setevent @TraceID, 20, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 20, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 20, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 20, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 20, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 20, 31, @on  -- Error
	exec sp_trace_setevent @TraceID, 20, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 20, 64, @on  -- SessionLoginName
	 
	-- Audit Database Scope GDR Event
	exec sp_trace_setevent @TraceID, 102, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 102, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 102, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 102, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 102, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 102, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 102, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 102, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 102, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object GDR Event
	exec sp_trace_setevent @TraceID, 103, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 103, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 103, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 103, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 103, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 103, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 103, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 103, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 103, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 103, 64, @on  -- SessionLoginName
	 
	-- Audit Login Change Property Event
	exec sp_trace_setevent @TraceID, 106, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 106, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 106, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 106, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 106, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 106, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 106, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 106, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 106, 64, @on  -- SessionLoginName
	 
	-- Audit Login Change Password Event
	exec sp_trace_setevent @TraceID, 107, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 107, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 107, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 107, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 107, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 107, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 107, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 107, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 107, 64, @on  -- SessionLoginName
	 
	-- Audit Add Login to Server Role Event
	exec sp_trace_setevent @TraceID, 108, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 108, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 108, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 108, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 108, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 108, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 108, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 108, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 108, 64, @on  -- SessionLoginName
	 
	-- Audit Add Member to DB Role Event
	exec sp_trace_setevent @TraceID, 110, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 110, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 110, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 110, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 110, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 110, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 110, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 110, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 110, 64, @on  -- SessionLoginName
	 
	-- Audit App Role Change Password Event
	exec sp_trace_setevent @TraceID, 112, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 112, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 112, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 112, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 112, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 112, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 112, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 112, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Access Event
	exec sp_trace_setevent @TraceID, 114, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 114, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 114, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 114, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 114, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 114, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 114, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 114, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 114, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 114, 64, @on  -- SessionLoginName
	 
	-- Audit Backup/Restore Event
	exec sp_trace_setevent @TraceID, 115, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 115, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 115, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 115, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 115, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 115, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 115, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 115, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 115, 64, @on  -- SessionLoginName
	 
	-- Audit DBCC Event
	exec sp_trace_setevent @TraceID, 116, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 116, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 116, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 116, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 116, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 116, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 116, 64, @on  -- SessionLoginName
	 
	-- Audit Change Audit Event
	exec sp_trace_setevent @TraceID, 117, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 117, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 117, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 117, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 117, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 117, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 117, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 117, 64, @on  -- SessionLoginName
	 
	-- Audit Database Management Event
	exec sp_trace_setevent @TraceID, 128, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 128, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 128, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 128, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 128, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 128, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 128, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 128, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 128, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Management Event
	exec sp_trace_setevent @TraceID, 129, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 129, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 129, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 129, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 129, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 129, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 129, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 129, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 129, 64, @on  -- SessionLoginName
	 
	-- Audit Database Principal Management Event
	exec sp_trace_setevent @TraceID, 130, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 130, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 130, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 130, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 130, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 130, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 130, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 130, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 130, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Management Event
	exec sp_trace_setevent @TraceID, 131, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 131, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 131, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 131, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 131, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 131, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 131, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 131, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 131, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 131, 64, @on  -- SessionLoginName
	 
	-- Audit Server Principal Impersonation Event
	exec sp_trace_setevent @TraceID, 132, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 132, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 132, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 132, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 132, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 132, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 132, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 132, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 132, 64, @on  -- SessionLoginName
	 
	-- Audit Database Principal Impersonation Event
	exec sp_trace_setevent @TraceID, 133, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 133, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 133, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 133, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 133, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 133, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 133, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 133, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 133, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 134, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 134, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 134, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 134, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 134, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 134, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 134, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 134, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 135, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 135, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 135, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 135, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 135, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 135, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 135, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 135, 64, @on  -- SessionLoginName
	 
	-- Audit Change Database Owner
	exec sp_trace_setevent @TraceID, 152, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 152, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 152, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 152, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 152, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 152, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 152, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 152, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 153, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 153, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 153, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 153, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 153, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 153, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 153, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 153, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 153, 64, @on  -- SessionLoginName
	 
	-- Audit Server Scope GDR Event
	exec sp_trace_setevent @TraceID, 170, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 170, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 170, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 170, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 170, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 170, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 170, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 170, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 170, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object GDR Event
	exec sp_trace_setevent @TraceID, 171, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 171, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 171, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 171, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 171, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 171, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 171, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 171, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 171, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object GDR Event
	exec sp_trace_setevent @TraceID, 172, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 172, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 172, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 172, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 172, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 172, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 172, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 172, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 172, 64, @on  -- SessionLoginName
	 
	-- Audit Server Operation Event
	exec sp_trace_setevent @TraceID, 173, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 173, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 173, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 173, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 173, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 173, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 173, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 173, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 173, 64, @on  -- SessionLoginName
	 
	-- Audit Server Alter Trace Event
	exec sp_trace_setevent @TraceID, 175, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 175, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 175, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 175, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 175, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 175, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 175, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 175, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object Management Event
	exec sp_trace_setevent @TraceID, 176, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 176, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 176, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 176, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 176, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 176, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 176, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 176, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 176, 64, @on  -- SessionLoginName
	 
	-- Audit Server Principal Management Event
	exec sp_trace_setevent @TraceID, 177, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 177, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 177, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 177, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 177, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 177, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 177, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 177, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 177, 64, @on  -- SessionLoginName
	 
	-- Audit Database Operation Event
	exec sp_trace_setevent @TraceID, 178, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 178, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 178, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 178, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 178, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 178, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 178, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 178, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 178, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Access Event
	exec sp_trace_setevent @TraceID, 180, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 180, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 180, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 180, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 180, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 180, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 180, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 180, 64, @on  -- SessionLoginName



	-- Set the trace status to start
	exec sp_trace_setstatus @TraceID, 1
	
	print 'INFO: Successfully created the trace with ID ' + CAST (@traceid AS varchar(10))
	return (0)
GO

declare @rc int

-- Set the proc for autostart
exec @rc = sp_procoption 'dbo.sp_create_evaltrace', 'startup', 'on'
IF @rc != 0
BEGIN
	print 'ERROR: sp_procoption returned ' + CAST(@rc AS NVARCHAR(10))
	print 'ERROR: Could not set sp_create_evaltrace for autostart'
END

-- start the eval trace
exec dbo.sp_create_evaltrace
=======

	set @tracefile = @instanceroot + 'LOG\'+ @scriptname


	-- Create the trace
	exec @rc = sp_trace_create @traceid OUTPUT, 6, @tracefile, @maxfilesize, NULL , @filecount
	IF (@rc != 0) 
	begin
		return (1)
	end


	-- Add Trace Events
	set @on = 1
 
	-- Audit Login
	exec sp_trace_setevent @TraceID, 14, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 14, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 14, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 14, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 14, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 14, 64, @on  -- SessionLoginName
	 
	-- Audit Logout
	exec sp_trace_setevent @TraceID, 15, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 15, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 15, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 15, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 15, 64, @on  -- SessionLoginName

	-- Audit Login Failed
	exec sp_trace_setevent @TraceID, 20, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 20, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 20, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 20, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 20, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 20, 31, @on  -- Error
	exec sp_trace_setevent @TraceID, 20, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 20, 64, @on  -- SessionLoginName
	 
	-- Audit Database Scope GDR Event
	exec sp_trace_setevent @TraceID, 102, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 102, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 102, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 102, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 102, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 102, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 102, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 102, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 102, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object GDR Event
	exec sp_trace_setevent @TraceID, 103, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 103, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 103, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 103, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 103, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 103, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 103, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 103, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 103, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 103, 64, @on  -- SessionLoginName
	 
	-- Audit Login Change Property Event
	exec sp_trace_setevent @TraceID, 106, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 106, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 106, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 106, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 106, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 106, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 106, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 106, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 106, 64, @on  -- SessionLoginName
	 
	-- Audit Login Change Password Event
	exec sp_trace_setevent @TraceID, 107, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 107, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 107, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 107, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 107, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 107, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 107, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 107, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 107, 64, @on  -- SessionLoginName
	 
	-- Audit Add Login to Server Role Event
	exec sp_trace_setevent @TraceID, 108, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 108, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 108, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 108, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 108, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 108, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 108, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 108, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 108, 64, @on  -- SessionLoginName
	 
	-- Audit Add Member to DB Role Event
	exec sp_trace_setevent @TraceID, 110, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 110, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 110, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 110, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 110, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 110, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 110, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 110, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 110, 64, @on  -- SessionLoginName
	 
	-- Audit App Role Change Password Event
	exec sp_trace_setevent @TraceID, 112, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 112, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 112, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 112, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 112, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 112, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 112, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 112, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Access Event
	exec sp_trace_setevent @TraceID, 114, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 114, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 114, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 114, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 114, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 114, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 114, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 114, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 114, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 114, 64, @on  -- SessionLoginName
	 
	-- Audit Backup/Restore Event
	exec sp_trace_setevent @TraceID, 115, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 115, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 115, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 115, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 115, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 115, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 115, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 115, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 115, 64, @on  -- SessionLoginName
	 
	-- Audit DBCC Event
	exec sp_trace_setevent @TraceID, 116, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 116, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 116, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 116, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 116, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 116, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 116, 64, @on  -- SessionLoginName
	 
	-- Audit Change Audit Event
	exec sp_trace_setevent @TraceID, 117, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 117, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 117, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 117, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 117, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 117, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 117, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 117, 64, @on  -- SessionLoginName
	 
	-- Audit Database Management Event
	exec sp_trace_setevent @TraceID, 128, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 128, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 128, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 128, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 128, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 128, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 128, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 128, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 128, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Management Event
	exec sp_trace_setevent @TraceID, 129, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 129, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 129, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 129, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 129, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 129, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 129, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 129, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 129, 64, @on  -- SessionLoginName
	 
	-- Audit Database Principal Management Event
	exec sp_trace_setevent @TraceID, 130, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 130, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 130, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 130, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 130, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 130, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 130, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 130, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 130, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Management Event
	exec sp_trace_setevent @TraceID, 131, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 131, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 131, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 131, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 131, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 131, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 131, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 131, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 131, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 131, 64, @on  -- SessionLoginName
	 
	-- Audit Server Principal Impersonation Event
	exec sp_trace_setevent @TraceID, 132, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 132, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 132, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 132, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 132, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 132, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 132, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 132, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 132, 64, @on  -- SessionLoginName
	 
	-- Audit Database Principal Impersonation Event
	exec sp_trace_setevent @TraceID, 133, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 133, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 133, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 133, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 133, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 133, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 133, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 133, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 133, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 134, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 134, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 134, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 134, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 134, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 134, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 134, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 134, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 135, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 135, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 135, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 135, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 135, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 135, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 135, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 135, 64, @on  -- SessionLoginName
	 
	-- Audit Change Database Owner
	exec sp_trace_setevent @TraceID, 152, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 152, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 152, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 152, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 152, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 152, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 152, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 152, 64, @on  -- SessionLoginName
	 
	-- Audit Schema Object Take Ownership Event
	exec sp_trace_setevent @TraceID, 153, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 153, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 153, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 153, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 153, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 153, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 153, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 153, 59, @on  -- ParentName
	exec sp_trace_setevent @TraceID, 153, 64, @on  -- SessionLoginName
	 
	-- Audit Server Scope GDR Event
	exec sp_trace_setevent @TraceID, 170, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 170, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 170, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 170, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 170, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 170, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 170, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 170, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 170, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object GDR Event
	exec sp_trace_setevent @TraceID, 171, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 171, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 171, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 171, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 171, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 171, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 171, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 171, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 171, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object GDR Event
	exec sp_trace_setevent @TraceID, 172, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 172, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 172, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 172, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 172, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 172, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 172, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 172, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 172, 64, @on  -- SessionLoginName
	 
	-- Audit Server Operation Event
	exec sp_trace_setevent @TraceID, 173, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 173, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 173, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 173, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 173, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 173, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 173, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 173, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 173, 64, @on  -- SessionLoginName
	 
	-- Audit Server Alter Trace Event
	exec sp_trace_setevent @TraceID, 175, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 175, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 175, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 175, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 175, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 175, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 175, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 175, 64, @on  -- SessionLoginName
	 
	-- Audit Server Object Management Event
	exec sp_trace_setevent @TraceID, 176, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 176, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 176, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 176, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 176, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 176, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 176, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 176, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 176, 64, @on  -- SessionLoginName
	 
	-- Audit Server Principal Management Event
	exec sp_trace_setevent @TraceID, 177, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 177, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 177, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 177, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 177, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 177, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 177, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 177, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 177, 64, @on  -- SessionLoginName
	 
	-- Audit Database Operation Event
	exec sp_trace_setevent @TraceID, 178, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 178, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 178, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 178, 21, @on  -- EventSubClass
	exec sp_trace_setevent @TraceID, 178, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 178, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 178, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 178, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 178, 64, @on  -- SessionLoginName
	 
	-- Audit Database Object Access Event
	exec sp_trace_setevent @TraceID, 180, 1, @on  -- TextData
	exec sp_trace_setevent @TraceID, 180, 11, @on  -- LoginName
	exec sp_trace_setevent @TraceID, 180, 14, @on  -- StartTime
	exec sp_trace_setevent @TraceID, 180, 23, @on  -- Success
	exec sp_trace_setevent @TraceID, 180, 34, @on  -- ObjectName
	exec sp_trace_setevent @TraceID, 180, 35, @on  -- DatabaseName
	exec sp_trace_setevent @TraceID, 180, 40, @on  -- DBUserName
	exec sp_trace_setevent @TraceID, 180, 64, @on  -- SessionLoginName



	-- Set the trace status to start
	exec sp_trace_setstatus @TraceID, 1
	
	print 'INFO: Successfully created the trace with ID ' + CAST (@traceid AS varchar(10))
	return (0)
GO

declare @rc int

-- Set the proc for autostart
exec @rc = sp_procoption 'dbo.sp_create_evaltrace', 'startup', 'on'
IF @rc != 0
BEGIN
	print 'ERROR: sp_procoption returned ' + CAST(@rc AS NVARCHAR(10))
	print 'ERROR: Could not set sp_create_evaltrace for autostart'
END

-- start the eval trace
exec dbo.sp_create_evaltrace
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO