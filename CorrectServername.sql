
-- Check that the internal @@SERVERNAME name machines the machine + Instance name
SELECT @@SERVERNAME As [@@SERVERNAME], 
		CAST(SERVERPROPERTY('MACHINENAME') AS VARCHAR(128)) + COALESCE('\' + CAST(SERVERPROPERTY('INSTANCENAME') AS VARCHAR(128)), '') As RealInstanceName;


-- Script to correct the @@SERVERNAME
DECLARE @InternalInstanceName sysname;
DECLARE @MachineInstanceName sysname;

SELECT @InternalInstanceName = @@SERVERNAME, 
 	@MachineInstanceName = CAST(SERVERPROPERTY('MACHINENAME') AS VARCHAR(128)) 
				+ COALESCE('\' + CAST(SERVERPROPERTY('INSTANCENAME') AS VARCHAR(128)), '');

IF @InternalInstanceName <> @MachineInstanceName
BEGIN

	-- Rename the instance
	EXEC sp_dropserver @InternalInstanceName;
	EXEC sp_addserver @MachineInstanceName, 'LOCAL';
END

-- You now need to restart the server for the changes to take effect
