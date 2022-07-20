IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'GrantUserRoleMembership')
  DROP PROCEDURE dbo.GrantUserRoleMembership;
GO 

CREATE PROC dbo.GrantUserRoleMembership
  @NewLogin sysname,
  @LoginToClone sysname,
  @DBNAME sysname
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TSQL nvarchar(MAX);
  DECLARE @RETURN int;

  BEGIN TRAN; 

  CREATE TABLE #RoleMembershipSQL 
  (
    RoleMembersTSQL nvarchar(MAX)
  );

  SET @TSQL = 'INSERT INTO #RoleMembershipSQL (RoleMembersTSQL) 
	SELECT ''EXEC sp_addrolemember @rolename = '''''' + R.name 
      + '''''', @membername = ''''' + @NewLogin + ''''';''
    FROM [' + @DBNAME + '].sys.database_principals AS U
      JOIN [' + @DBNAME + '].sys.database_role_members AS RM
        ON U.principal_id = RM.member_principal_id
      JOIN [' + @DBNAME + '].sys.database_principals AS R
        ON RM.role_principal_id = R.principal_id
    WHERE U.name = ''' + @LoginToClone + ''';';

  EXEC @RETURN = sp_executesql @TSQL;

  IF (@RETURN <> 0)
  BEGIN
    ROLLBACK TRAN; 
	RAISERROR('Could not retrieve role memberships.', 16, 1);
	RETURN(1)
  END;

  DECLARE cursDBRoleMembersSQL CURSOR FAST_FORWARD
  FOR
  SELECT RoleMembersTSQL 
  FROM #RoleMembershipSQL;

  OPEN cursDBRoleMembersSQL;

  FETCH FROM cursDBRoleMembersSQL INTO @TSQL;

  WHILE (@@FETCH_STATUS = 0)
    BEGIN
	  SET @TSQL = 'USE [' + @DBNAME + ']; ' + @TSQL;
      EXECUTE @RETURN = sp_executesql @TSQL;

      IF (@RETURN <> 0)
        BEGIN
          ROLLBACK TRAN;
	      RAISERROR('Error encountered assigning DB role memberships.', 16, 1);
		  CLOSE cursDBRoleMembersSQL;
		  DEALLOCATE cursDBRoleMembersSQL;
        END;

      FETCH NEXT FROM cursDBRoleMembersSQL INTO @TSQL;
    END;

  CLOSE cursDBRoleMembersSQL;
  DEALLOCATE cursDBRoleMembersSQL;

  DROP TABLE #RoleMembershipSQL;

  COMMIT TRAN;
END;
GO
