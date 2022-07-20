DECLARE     @ServerName SYSNAME
,@InstanceID NVARCHAR(128)
,@InstanceName NVARCHAR(128)
,@tcp_port NVARCHAR(10)
,@InstanceKey NVARCHAR(255)
SELECT @ServerName = @@SERVERNAME
SELECT @InstanceName = ISNULL((CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))), 'MSSQLSERVER')
EXECUTE xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
,@key = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
,@value_name = @InstanceName
,@value = @InstanceID OUTPUT
SELECT @InstanceKey = 'SOFTWARE\MICROSOFT\Microsoft SQL Server\' + @InstanceID + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'
EXEC xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
,@key = @InstanceKey
,@value_name = 'TcpDynamicPorts'
,@value = @tcp_port OUTPUT
IF @tcp_port IS NOT NULL
SELECT 'SQL Server (' + @InstanceName + ') uses dynamic tcp port: ' + CAST(@tcp_port AS NVARCHAR(128))
ELSE
BEGIN
EXEC xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
,@key = @InstanceKey
,@value_name = 'TcpPort'
,@value = @tcp_port OUTPUT
SELECT 'SQL Server (' + @InstanceName + ') on ' + @ServerName+ ' uses static tcp port: ' + CAST(@tcp_port AS NVARCHAR(128))
END
GO