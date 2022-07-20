<<<<<<< HEAD
--Application Name={"conn":{"user":"Alexandre Gama", "application":"Nome da Aplicação"}};

SELECT APP_NAME();

DECLARE @JASON VARCHAR(100) = N'{"conn":{"user":"Alexandre Gama", "application":"Nome da Aplicação"}};'

SELECT APP_NAME() AS json,
       JSON_VALUE(APP_NAME(), '$.conn.user') AS [user],
	   JSON_VALUE(APP_NAME(), '$.conn.application') AS [application]
=======
--Application Name={"conn":{"user":"Alexandre Gama", "application":"Nome da Aplicação"}};

SELECT APP_NAME();

DECLARE @JASON VARCHAR(100) = N'{"conn":{"user":"Alexandre Gama", "application":"Nome da Aplicação"}};'

SELECT APP_NAME() AS json,
       JSON_VALUE(APP_NAME(), '$.conn.user') AS [user],
	   JSON_VALUE(APP_NAME(), '$.conn.application') AS [application]
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
