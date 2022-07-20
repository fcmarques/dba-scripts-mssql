SELECT 
	name,
	CASE 
		WHEN isntgroup =1 AND isntuser=0 THEN 'Windows Group'
		WHEN isntgroup =0 AND isntuser=1 THEN 'Windows Login'
		ELSE 'SQL Login' 
	END AS 'Login Type',
	dbname,
    CASE WHEN sysadmin = 1 THEN 'sysadmin'
          WHEN securityadmin=1 THEN 'securityadmin'
          WHEN serveradmin=1 THEN 'serveradmin'
          WHEN setupadmin=1 THEN 'setupadmin'
          WHEN processadmin=1 THEN 'processadmin'
          WHEN diskadmin=1 THEN 'diskadmin'
          WHEN dbcreator=1 THEN 'dbcreator'
          WHEN bulkadmin=1 THEN 'bulkadmin'
          ELSE 'Public' 
     END AS 'ServerRole' 
FROM master.dbo.syslogins