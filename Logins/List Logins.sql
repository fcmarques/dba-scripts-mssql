-- Get the list of all Login Accounts in a SQL Server

SELECT 
	name AS Login_Name, 
	type_desc AS Account_Type, 
	IIF(is_disabled = 1,'DISABLED', 'ENABLED') Login_Status, 
	LOGINPROPERTY(name,'PASSWORDHASH') as Hashed_Password
FROM sys.server_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc

SELECT 
	name AS Login_Name, 
	type_desc AS Account_Type, 
	CASE is_disabled 
		WHEN 1 THEN 'DISABLED'
		ELSE 'ENABLED' 
	END AS Login_Status, 
	LOGINPROPERTY(name,'PASSWORDHASH') as Hashed_Password
FROM sys.server_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc

-- Get the list of all SQL Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'S'
and name not like '%##%'

-- Get the list of all Windows Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'U'

-- Get the list of all Windows Group Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'G'