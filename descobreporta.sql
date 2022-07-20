SET NOCOUNT ON
DECLARE @test VARCHAR(20), 
            @key VARCHAR(100)
      IF CHARINDEX('\',@@SERVERNAME,0) <>0
      BEGIN
            SET @key = 'SOFTWARE\MICROSOFT\Microsoft SQL Server\'+@@servicename+'\MSSQLServer\Supersocketnetlib\TCP'
      END
      ELSE
      BEGIN
      SET @key = 'SOFTWARE\MICROSOFT\MSSQLServer\MSSQLServer\Supersocketnetlib\TCP'
      END
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE',@key=@key,@value_name='Tcpport',@value=@test OUTPUT
SELECT 'Server Name: '+@@SERVERNAME + ' Port Number:'+CONVERT(VARCHAR(10),@test)

