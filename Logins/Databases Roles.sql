SET NOCOUNT ON

CREATE TABLE #DatabaseRoleMemberShip 
   (
        Username VARCHAR(100),
        Rolename VARCHAR(100),
        Databasename VARCHAR(100)
         
    )
DECLARE @Cmd AS VARCHAR(MAX)
DECLARE @PivotColumnHeaders VARCHAR(4000)           

SET @Cmd = 'USE [?] ;insert into #DatabaseRoleMemberShip 
select U.name,R.name,''?'' from sys.database_role_members RM inner join 
sys.database_principals U on U.principal_id=RM.member_principal_id
inner join sys.database_principals R on R.principal_id=RM.role_principal_id
where U.type<>''R'''

EXEC sp_MSforeachdb @command1=@Cmd

SELECT  @PivotColumnHeaders =                         
  COALESCE(@PivotColumnHeaders + ',[' + CAST(Rolename AS VARCHAR(MAX)) + ']','[' + CAST(Rolename AS VARCHAR(MAX))+ ']'                     
  )                     
  FROM (SELECT DISTINCT Rolename FROM #DatabaseRoleMemberShip )a ORDER BY Rolename  ASC


SET @Cmd = 'select 
Databasename,Username,'+@PivotColumnHeaders+'
from 
(
select   * from #DatabaseRoleMemberShip) as p
pivot 
(
count(Rolename  )
for Rolename in ('+@PivotColumnHeaders+') )as pvt'EXECUTE(@Cmd )       
DROP TABLE #DatabaseRoleMemberShip