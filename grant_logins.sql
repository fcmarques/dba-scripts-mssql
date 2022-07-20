--select name from sys.syslogins where name = 'riachuelo\yamada'
declare @cmd nvarchar(1500), 
		@schema nvarchar(60),
		@user nvarchar(60)

		set @user='USRDEVSISTFINAN'

if not exists (select * from sys.database_principals  WHERE type = 'R' and name = 'RLESISTFININC' )
	begin
	create role RLESISTFININC
	end


if not exists (select name from sys.syslogins  WHERE name = @user)
	begin
	set @cmd='CREATE LOGIN ['+@user+'] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
	exec sp_executesql @cmd
	end

	DECLARE cursor_n1 CURSOR FOR
select name from sys.schemas 
OPEN cursor_n1
	FETCH NEXT FROM cursor_n1 INTO @schema
	WHILE @@FETCH_STATUS = 0
		BEGIN
            set @cmd = 'grant select,insert,update,delete,execute on schema :: ['+ltrim(@schema)+'] to RLESISTFININC'
			
		exec sp_executesql @cmd
	            
    FETCH NEXT FROM cursor_n1 INTO @schema
	END
CLOSE cursor_n1
DEALLOCATE cursor_n1

DECLARE cursor_n2 CURSOR FOR
select 'create user ['+@user+'] for login ['+@user+']', name from sys.syslogins where name =@user
OPEN cursor_n2
	FETCH NEXT FROM cursor_n2 INTO @cmd,@user
	WHILE @@FETCH_STATUS = 0
		BEGIN
        IF NOT EXISTS (SELECT NAME FROM SYS.sysusers WHERE NAME = @USER)
		BEGIN
				exec sp_executesql @cmd
		END
		set @cmd='sp_addrolemember ''RLESISTFININC'','''+@user+''''
		exec sp_executesql @cmd
		
		                  
    FETCH NEXT FROM cursor_n2 INTO @cmd, @user
	END
CLOSE cursor_n2
DEALLOCATE cursor_n2 













