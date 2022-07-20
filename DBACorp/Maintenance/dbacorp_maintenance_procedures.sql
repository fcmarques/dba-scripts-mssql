<<<<<<< HEAD
USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCheckdb]    Script Date: 05/15/2014 17:34:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCheckdb]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE 
			@databasename               NVARCHAR(128),
			@vSql                       NVARCHAR(4000),
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT,
			@vCount         			INT,
			@vErrorProcedure			NVARCHAR(200),
			@vRoutineName   			NVARCHAR(128),
			@vErrorNumber   			INT,
			@vErrorSeverity 			INT,
			@vErrorState    			INT,
			@vErrorLine     			INT,
			@vErrorMessage  			NVARCHAR(4000),
			@vErrorCount				INT,
			@vErrorCountAux				INT,
			@vDateCheckdbStart			DATETIME,
			@vDateCheckdbFinish			DATETIME,	
			@vCheckdbTimeId				INT,					
			@command					NVARCHAR(4000),
			@MSGError       			NVARCHAR(4000)


	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('CHECKDB',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[name]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND [MD].[IndCheckdb] = 'Y'	
			   AND 
			   (
					( CASE
						WHEN [IndAlwaysOn] = 'Y' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) = 'READ_ONLY'
					OR 
					( CASE
						WHEN [IndAlwaysOn] = 'N' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) IN ( 'READ_WRITE', 'READ_ONLY')
				)
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @databasename
            IF @@FETCH_STATUS < 0
              BREAK;
          
		  SET @command = 'dbcc checkdb('''+@databasename+''')'

		  PRINT N'Executing: ' + @command;

		  SELECT @vDateCheckdbStart = GETDATE()

	      INSERT INTO [dbo].[MaintenanceCheckdbTimes]
						([DatabaseName],
						 [StartTime])
		  VALUES      (@DatabaseName,
					   @vDateCheckdbStart) 

		  SELECT @vCheckdbTimeId = SCOPE_IDENTITY()

		  BEGIN TRY
			EXEC (@command);
			
			SELECT @vDateCheckdbFinish = GETDATE()
			
			UPDATE [dbo].[MaintenanceCheckdbTimes]
			SET    [EndTime] = @vDateCheckdbFinish
				   ,[CheckdbStatus] = 'Finalizado com Sucesso'
			WHERE  [CheckdbId] = @vCheckdbTimeId			
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'CHECKDB',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Checkdb do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vDateCheckdbFinish = GETDATE()
					
					UPDATE [dbo].[MaintenanceCheckdbTimes]
					SET    [EndTime] = @vDateCheckdbFinish
						   ,[CheckdbStatus] = 'Finalizado com Erro'
					WHERE  [CheckdbId] = @vCheckdbTimeId	                    
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de CHECKDB finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de CHECKDB finalizada com sucesso.')
	END
  
  END


GO


USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCollectDegraf]    Script Date: 05/15/2014 17:34:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCollectDegraf]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE @databaseid                 INT,
			@databasename               NVARCHAR(128),
			@objectid                   INT,
			@indexid                    INT,
			@partitioncount             BIGINT,
			@schemaname                 NVARCHAR(130),
			@objectname                 NVARCHAR(130),
			@indexname                  NVARCHAR(130),
			@partitionnum               BIGINT,
			@partitions                 BIGINT,
			@frag                       FLOAT,
			@command                    NVARCHAR(4000),
			@vSql                       NVARCHAR(4000),
			@vAvgFragmentationInPercent FLOAT, 
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT

	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('COLLECTDEFRAG',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vAvgFragmentationInPercent = 0.0
	
	IF (SELECT Object_id('MaintenanceControlFragmentation')) IS NULL
	BEGIN
		CREATE TABLE [dbo].[MaintenanceControlFragmentation]
		  (
			 [DatabaseId]					INT,
			 [DatabaseName]					NVARCHAR(128),
			 [ObjectId]						BIGINT,
			 [IndexId]						INT,
			 [PartitionNumer]				INT,
			 [AvgFragmentationInPercent]	FLOAT,
			 [DateCollect]					DATETIME DEFAULT Getdate(),
			 [StartTime]					DATETIME,
			 [EndTime]						DATETIME,
			 [RebuildStatus]                CHAR(3) DEFAULT '',
			 [RebuildType]					NVARCHAR(20)
		  )
	END 
	
	UPDATE [dbo].[MaintenanceControlFragmentation]
	SET    [RebuildStatus] = 'Último rebuild não finalizado.'
	WHERE  [RebuildStatus] = ''

      DECLARE @dbId INT
      SET @dbId = 1
      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[dbid]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND Databasepropertyex ([SD].[name] , 'UPDATEABILITY' ) = 'READ_WRITE'
               AND [MD].[IndRebuild] = 'Y'	
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @dbId
            IF @@FETCH_STATUS < 0
              BREAK;
              
				SELECT @vAvgFragmentationInPercent = NULL
              
				SELECT @vAvgFragmentationInPercent = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REBUILD'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = db_name(@dbId)
				
				IF (@vAvgFragmentationInPercent IS NULL)
				BEGIN
					SELECT @vAvgFragmentationInPercent = [Value]
					FROM [dbo].[MaintenanceParameters]
					WHERE [RoutineName] = 'REBUILD'
						  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
						  AND [DatabaseName] = 'ALL'				
				END
				
				INSERT INTO [dbo].[MaintenanceControlFragmentation]
							([DatabaseName],
							 [DatabaseId],
							 [ObjectId],
							 [IndexId],
							 [PartitionNumer],
							 [AvgFragmentationInPercent])
				SELECT DB_NAME([database_id]),
					   [database_id],
					   [object_id],
					   [index_id],
					   [partition_number],
					   [avg_fragmentation_in_percent]
				FROM   [sys].[Dm_db_index_physical_stats] (@dbId, NULL, NULL, NULL, 'LIMITED')
				WHERE  [index_id] > 0
					   AND [avg_fragmentation_in_percent] >= @vAvgFragmentationInPercent
				
        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 
  
  END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCreateDirectory]    Script Date: 05/15/2014 17:34:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCreateDirectory] @Path NVARCHAR(1024)
AS
  BEGIN
      DECLARE @chkdirectory AS NVARCHAR(4000)
      DECLARE @folder_exists AS INT
      SET @chkdirectory = @Path
      DECLARE @file_results TABLE
        (
           file_exists             INT,
           file_is_a_directory     INT,
           parent_directory_exists INT
        )
      INSERT INTO @file_results
                  (file_exists,
                   file_is_a_directory,
                   parent_directory_exists)
      EXEC master.dbo.Xp_fileexist
        @chkdirectory
      SELECT @folder_exists = file_is_a_directory
      FROM   @file_results
      --script to create directory        
      IF @folder_exists = 0
        BEGIN
            PRINT 'Directory is not exists, creating new one '
            EXECUTE master.dbo.Xp_create_subdir
              @chkdirectory
            PRINT @chkdirectory + 'created on ' + @@SERVERNAME
        END
      ELSE
        PRINT 'Directory already exists'
  END 



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceDatabaseBackups]    Script Date: 05/15/2014 17:34:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceDatabaseBackups]
@BackupType VARCHAR (10)
--[uspMaintenanceDatabaseBackups] @BackupType = 'FULL'
--[uspMaintenanceDatabaseBackups] @BackupType = 'DIFF'
--[uspMaintenanceDatabaseBackups] @BackupType = 'LOG'
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/

	DECLARE @DatabaseName   	NVARCHAR(128),
			@TableName      	NVARCHAR(128),
			@Path           	NVARCHAR(1024),
			@PathArq        	NVARCHAR(1024),
			@DateLog        	NVARCHAR(128),
			@MSGError       	NVARCHAR(4000),
			@Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vErrorProcedure	NVARCHAR(200),
			@vRoutineName   	NVARCHAR(128),
			@vErrorNumber   	INT,
			@vErrorSeverity 	INT,
			@vErrorState    	INT,
			@vErrorLine     	INT,
			@vErrorMessage  	NVARCHAR(4000),
			@vSql           	NVARCHAR(4000),
			@vErrorCount		INT,
			@vErrorCountAux		INT,			
			@vRecoveryModel		NVARCHAR(20),
			@vDateRoutineStart	DATETIME,
			@vDateRoutineFinish	DATETIME,
			@vDateBackupStart	DATETIME,
			@vDateBackupFinish	DATETIME,
			@vLogShipping		INT,
			@vRoutineTimeId		INT,
			@vBackupTimeId		INT,
			@vCountParameters	INT,
			@ErrorIdPurge		INT			

	CREATE TABLE #DirectoryInfo
	  (
		 FileExists            BIT,
		 FileIsADirectory      BIT,
		 ParentDirectoryExists BIT
	  ) 
	  
	CREATE TABLE #Tmp_MaintenanceParameters
	(
			ParameterName	NVARCHAR(128)
			,Value	NVARCHAR(1024)	
	)
		
	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	
	/*-----------INÍCIO PREENCHIMENTO DE VARIÁVEIS-----------------*/
    SELECT @vErrorProcedure = 'uspMaintenanceDatabaseBackups',
           @vRoutineName = 'BACKUP' + @BackupType;
           
    SELECT @DateLog = Replace(Replace(Replace(CONVERT(VARCHAR(19), Getdate(), 126), '-', ''), 'T', ''), ':', '')  
    
    SELECT @vErrorCount = 0, @vErrorCountAux = 0      
    
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      (@vRoutineName,
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
    
	/*----------TÉRMINO PREENCHIMENTO DE VARIÁVEIS-----------------*/

	/*-----------INÍCIO PREENCHIMENTO DE NOVO BANCOS---------------*/
	BEGIN TRY
		EXEC [dbo].[uspMaintenanceInsertDatabases]
	END TRY
	BEGIN CATCH
		SET @vErrorMessage = 'Erro durante a inserção de novos databases.'

		EXEC [dbo].[uspMaintenanceErrorControl]
		  @vRoutineName = @vRoutineName,
		  @vDatabaseName = 'dbacorp_maintenance',
		  @vTableName = '',
		  @vErrorNumber = 50000,
		  @vErrorSeverity = 1,
		  @vErrorState = 1,
		  @vErrorProcedure = 'uspMaintenanceInsertDatabases',
		  @vErrorMessage = @vErrorMessage
		
		PRINT @vErrorMessage
		SELECT @vErrorCount = 1
		RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
	END CATCH
	/*-----------TÉRMINO PREENCHIMENTO DE NOVO BANCOS---------------*/
	
	/*------INÍCIO VALIDAÇÃO DO PARÂMETRO BACKUPTYPE---------------*/
	IF @BackupType NOT IN ('FULL','DIFF','LOG') OR @BackupType IS NULL
	BEGIN
		SET @vErrorMessage = 'The value for the parameter @BackupType is not supported.'

		EXEC [dbo].[uspMaintenanceErrorControl]
		  @vRoutineName = @vRoutineName,
		  @vDatabaseName = 'dbacorp_maintenance',
		  @vTableName = '',
		  @vErrorNumber = 50000,
		  @vErrorSeverity = 1,
		  @vErrorState = 1,
		  @vErrorProcedure = @vErrorProcedure,
		  @vErrorMessage = @vErrorMessage
		
		PRINT @vErrorMessage
		SELECT @vErrorCount = 1
		RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
	END
	/*------TÉRMINO VALIDAÇÃO DO PARÂMETRO BACKUPTYPE--------------*/
	   
    DECLARE cDatabases CURSOR FAST_FORWARD FOR
      SELECT [md].[DatabaseName]
      FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [md] WITH (NOLOCK)
      WHERE  ( CASE
                 WHEN @BackupType = 'FULL' THEN [IndBackupFull]
                 WHEN @BackupType = 'DIFF' THEN [IndBackupDiff]
                 WHEN @BackupType = 'LOG' THEN [IndBackupLog]
               END ) = 'Y'
               AND DATABASEPROPERTYEX([DatabaseName],'STATUS') = 'ONLINE'
				 AND UPPER([DatabaseName]) NOT IN ('TEMPDB')
				 --AND [DatabaseName] = 'cleartrace'
			   AND 
			   (
					( CASE
						WHEN IndAlwaysOn = 'Y' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) = 'READ_WRITE'
					OR 
					( CASE
						WHEN IndAlwaysOn = 'N' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) IN ( 'READ_WRITE', 'READ_ONLY')
				)
               
    OPEN cDatabases
    FETCH NEXT FROM cDatabases INTO @DatabaseName
    WHILE @@FETCH_STATUS = 0
      BEGIN

		/*------INÍCIO PREENCHIMENTO DE VARIÁVEIS PARA CADA BANCO------*/
		SET @Path = ''
		SET @ParameterName = ''
		SET @Parameters = ''
		SET @vCount = 0
		SET @vSql = ''
		
		SELECT @Path = ( CASE
						 WHEN @BackupType = 'FULL' THEN [PathBackupFull]
						 WHEN @BackupType = 'DIFF' THEN [PathBackupDiff]
						 WHEN @BackupType = 'LOG' THEN [PathBackupLog]
					   END )
		FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [cb] WITH (NOLOCK)
		WHERE  [DatabaseName] = @DatabaseName

		SELECT @Path = @Path + UPPER(LTRIM(RTRIM(@DatabaseName))) + '\'
		/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
		SELECT @vCountParameters = 0
		
		SELECT @vCountParameters = ISNULL(COUNT(*),0)
		FROM   [MaintenanceParameters]
		WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
			   AND [DatabaseName] = @DatabaseName
	    
	    TRUNCATE TABLE #Tmp_MaintenanceParameters
	    
	    IF (@vCountParameters <> 0)
	    BEGIN
	        INSERT INTO #Tmp_MaintenanceParameters
				(
					[ParameterName]
					, [Value]
				)	    
			SELECT [ParameterName], [Value]
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
				   AND [DatabaseName] = @DatabaseName	    
	    END
	    ELSE
	    BEGIN
	        INSERT INTO #Tmp_MaintenanceParameters
				(
					[ParameterName]
					, [Value]
				)
			SELECT [ParameterName], [Value]
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
				   AND [DatabaseName] = 'ALL'	    
	    END
				   		
		DECLARE cParameters CURSOR FAST_FORWARD FOR
			SELECT [ParameterName], [Value]
			FROM   #Tmp_MaintenanceParameters with (NOLOCK)
				     
		OPEN cParameters
		FETCH NEXT FROM cParameters INTO @ParameterName, @Value
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ( @Parameters = ''
				 AND @vCount = 0
				 AND @BackupType IN ( 'FULL', 'LOG' ) )
			  BEGIN
				  SET @Parameters = ' WITH '
				  SET @Parameters = @Parameters + @ParameterName + ''
				  
					IF (@Value <> '*')
					BEGIN
						SET @Parameters = @Parameters + ' = ' + @Value + ''
					END
				  SET @vCount = 1
			  END
			ELSE
			  BEGIN
				  SET @Parameters = @Parameters + ', ' + @ParameterName + ''
				  
					IF (@Value <> '*')
					BEGIN
						SET @Parameters = @Parameters + ' = ' + @Value + ''
					END				  
			  END
			FETCH NEXT FROM cParameters INTO @ParameterName, @Value
		END
		CLOSE cParameters
		DEALLOCATE cParameters

		SELECT @PathArq = @Path + @DatabaseName + '_' + @BackupType + '_' + @DateLog + '.BKP' 
		/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/
		
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','COMPRESSION', '','cleartrace')
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','FORMAT', '','cleartrace')
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','CHECKSUM', '','cleartrace')

		/*------INÍCIO VERIFICAÇÃO DE DIRETÓRIO PARA CADA BANCO------*/ 
		TRUNCATE TABLE #DirectoryInfo

		INSERT INTO #DirectoryInfo
				  (FileExists,
				   FileIsADirectory,
				   ParentDirectoryExists)
		EXECUTE [master].dbo.Xp_fileexist @Path
		
		IF NOT EXISTS (SELECT *
					   FROM   #DirectoryInfo
					   WHERE  [FileExists] = 0
							  AND [FileIsADirectory] = 1
							  AND [ParentDirectoryExists] = 1) 
			BEGIN
				EXEC [dbo].[uspMaintenanceCreateDirectory] @Path
			END
			
		TRUNCATE TABLE #DirectoryInfo			
			
		INSERT INTO #DirectoryInfo
				  ([FileExists],
				   [FileIsADirectory],
				   [ParentDirectoryExists])
		EXEC [master].[dbo].[Xp_fileexist] @Path
		
		IF NOT EXISTS (SELECT *
					   FROM   #DirectoryInfo
					   WHERE  [FileExists] = 0
							  AND [FileIsADirectory] = 1
							  AND [ParentDirectoryExists] = 1) 
			BEGIN
                /*-----------------DIRETÓRIO NÃO ENCONTRADO------------------*/
				SELECT @vErrorMessage = 'Operating system error 3(O sistema não pode encontrar o diretório '+@path+'.)'

				EXEC [dbo].[uspMaintenanceErrorControl]
				  @vRoutineName = @vRoutineName,
				  @vDatabaseName = @DatabaseName,
				  @vTableName = '',
				  @vErrorNumber = 3201,
				  @vErrorSeverity = 1,
				  @vErrorState = 1,
				  @vErrorProcedure = @vErrorProcedure,
				  @vErrorMessage = @vErrorMessage
				  
				SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
									+ @DatabaseName + ' FALHOU as '
									+ CONVERT (VARCHAR, Getdate (), 120)
									+ ' - Erro: '+@vErrorMessage
				PRINT @MSGError
                
				SELECT @vErrorCount = 1
				/*-----------------DIRETÓRIO NÃO ENCONTRADO------------------*/                  
			END
		/*-----TÉRMINO VERIFICAÇÃO DE DIRETÓRIO PARA CADA BANCO------*/       
		ELSE
			BEGIN
			    /*-------------INÍCIO BACKUP PARA CADA BANCO-----------------*/
				BEGIN TRY
				
					PRINT 'Backup modo: ' + @BackupType + ' do banco '
						  + @DatabaseName + ' INICIADO as '
						  + CONVERT (VARCHAR, Getdate (), 120)
					
					SELECT @vErrorCountAux = 0
					
					SELECT @vDateBackupStart = GETDATE()
					
					INSERT INTO [dbo].[MaintenanceBackupTimes]
								([DatabaseName],
								 [BackupType],
								 [StartTime])
					VALUES      (@DatabaseName,
								 @BackupType,
								 @vDateBackupStart) 

					SELECT @vBackupTimeId = SCOPE_IDENTITY()
				  
					IF @BackupType = 'FULL'
					  BEGIN
						  PRINT 'Commando: ' + 'BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' ' + @Parameters
						  
						  EXEC ('BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' ' + @Parameters)
						  
						  PRINT 'Backup modo: ' + @BackupType + ' do banco '
												+ @DatabaseName + ' FINALIZADO as '
												+ CONVERT (VARCHAR, Getdate (), 120)
												
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  
					  END
					IF @BackupType = 'DIFF'
					  BEGIN
						  PRINT 'Commando: ' + 'BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' WITH DIFFERENTIAL ' + @Parameters
					  
						  EXEC ('BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' WITH DIFFERENTIAL ' + @Parameters)
						  
						  PRINT 'Backup modo: ' + @BackupType + ' do banco '
												+ @DatabaseName + ' FINALIZADO as '
												+ CONVERT (VARCHAR, Getdate (), 120)						  
												
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  												
					  END
					IF @BackupType = 'LOG'
					  BEGIN
						/*------INÍCIO VALIDAÇÃO DO PARÂMETRO BACKUPFULL---------------*/
						
						SELECT @vRecoveryModel = CONVERT(NVARCHAR(20),(DATABASEPROPERTYEX(@DatabaseName,'RECOVERY')))
						SELECT @vLogShipping = ISNULL(COUNT(*),0) FROM [msdb].[dbo].[log_shipping_primary_databases] WHERE [primary_database] = @DatabaseName
						
						IF (@vRecoveryModel = 'FULL' AND @vLogShipping = 0)
						BEGIN
						    PRINT 'Commando: ' + 'BACKUP LOG ['+@DatabaseName+'] TO DISK = '''+@PathArq+'''' + @Parameters
						    
							EXEC ('BACKUP LOG ['+@DatabaseName+'] TO DISK = '''+@PathArq+'''' + @Parameters)	
							
							PRINT 'Backup modo: ' + @BackupType + ' do banco '
													+ @DatabaseName + ' FINALIZADO as '
													+ CONVERT (VARCHAR, Getdate (), 120)	
																								
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  													
						END
						ELSE
						BEGIN
							IF (@vLogShipping > 0)
							BEGIN
								SELECT @vErrorMessage = 'O banco '+@DatabaseName+' está configurado com LOGSHIPPING.'
							END
							IF (@vRecoveryModel <> 'FULL')
							BEGIN
								SELECT @vErrorMessage = 'O banco '+@DatabaseName+' não está no modo FULL.'
							END							

							EXEC [dbo].[uspMaintenanceErrorControl]
							  @vRoutineName = @vRoutineName,
							  @vDatabaseName = @DatabaseName,
							  @vTableName = '',
							  @vErrorNumber = 3201,
							  @vErrorSeverity = 1,
							  @vErrorState = 1,
							  @vErrorProcedure = @vErrorProcedure,
							  @vErrorMessage = @vErrorMessage
							  
							SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
										
							PRINT @MSGError
							SELECT @vErrorCount = 1		
							SELECT @vErrorCountAux = 1					
						END
						/*------TÉRMINO VALIDAÇÃO DO PARÂMETRO BACKUPFULL--------------*/						  
						SELECT @vDateBackupFinish = GETDATE()
						
					  END
				END TRY
                /*-------------TÉRMINO BACKUP PARA CADA BANCO----------------*/
                
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = @vRoutineName,
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
					SELECT @vErrorCountAux = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
                
				IF (@vErrorCountAux = 0)
				BEGIN
   					SELECT @vDateBackupFinish = GETDATE()

					UPDATE [dbo].[MaintenanceBackupTimes]
					SET    [EndTime] = @vDateBackupFinish
						   ,[BackupStatus] = 'Finalizado com Sucesso'
					WHERE  [BackupId] = @vBackupTimeId

				END
				ELSE
				BEGIN
   					SELECT @vDateBackupFinish = GETDATE()
					UPDATE [dbo].[MaintenanceBackupTimes]
					SET    [EndTime] = @vDateBackupFinish
						   ,[BackupStatus] = 'Finalizado com Erro'
					WHERE  [BackupId] = @vBackupTimeId 
					
					SELECT @vErrorCountAux = 0		
				END                 
            END
          FETCH NEXT FROM cDatabases INTO @DatabaseName
      END
    CLOSE cDatabases
    DEALLOCATE cDatabases
    DROP TABLE #DirectoryInfo
    DROP TABLE #Tmp_MaintenanceParameters
	
	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de backup finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de backup finalizada com sucesso.')
	END
END



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceDefrag]    Script Date: 05/15/2014 17:34:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceDefrag]
AS  
BEGIN
SET NOCOUNT ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE @databaseid							INT,
			@databasename						NVARCHAR(128),
			@objectid							INT,
			@indexid							INT,
			@partitioncount						BIGINT,
			@schemaname							NVARCHAR(130),
			@objectname							NVARCHAR(130),
			@indexname							NVARCHAR(130),
			@partitionnum						BIGINT,
			@partitions							BIGINT,
			@frag								FLOAT,
			@command							NVARCHAR(4000),
			@vSql								NVARCHAR(4000),
			@vAvgFragmentationInPercentRebuild	FLOAT, 
			@vAvgFragmentationInPercentReorg	FLOAT, 			
			@vDateRoutineStart					DATETIME,
			@vDateRoutineFinish					DATETIME,
			@vRoutineTimeId						INT,
			@SQLString							NVARCHAR(4000),
			@vRebuildType						NVARCHAR(20),
			@vCount         					INT,
			@vErrorProcedure					NVARCHAR(200),
			@vRoutineName   					NVARCHAR(128),
			@vErrorNumber   					INT,
			@vErrorSeverity 					INT,
			@vErrorState    					INT,
			@vErrorLine     					INT,
			@vErrorMessage  					NVARCHAR(4000),
			@vErrorCount						INT,
			@vErrorCountAux						INT,
			@MSGError       					NVARCHAR(4000),
			@vLimitTime							INT;

	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
    SELECT @vErrorProcedure = 'uspMaintenanceDatabaseBackups',
           @vRoutineName = 'REBUILD'
           	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('REBUILD',
				 @vDateRoutineStart) 
				 
	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	
	SET @vLimitTime = NULL
	
	SELECT @vLimitTime = [Value]
	FROM   [MaintenanceParameters] with (NOLOCK)
	WHERE  [RoutineName] = 'REBUILD'
		   AND [ParameterName] = 'LIMITTIME'
		   AND [DatabaseName] = 'ALL'	

	/*-----------------INÍCIO DESFRAGMENTAÇÃO----------------------*/
	DECLARE partitions CURSOR FAST_FORWARD FOR
	  SELECT [CF].[DatabaseId],
			 [CF].[ObjectId],
			 [CF].[IndexId],
			 [CF].[PartitionNumer],
			 [CF].[AvgFragmentationInPercent]
	  FROM   [dbo].[MaintenanceControlFragmentation] CF WITH (NOLOCK)
	  WHERE  [CF].[StartTime] IS NULL
			 AND [CF].[RebuildStatus] = ''
			 AND (CONVERT(NVARCHAR(20),[CF].[DatabaseId])+'_'+CONVERT(NVARCHAR(20),[CF].[ObjectId])) NOT IN 
							(
								SELECT	CONVERT(NVARCHAR(20),[EL].[DatabaseId])+'_'+CONVERT(NVARCHAR(20),[EL].[ObjectId])
								FROM	[dbo].[MaintenanceExcludeListTables] [EL]
							)
	  ORDER BY [CF].[AvgFragmentationInPercent] DESC;

	OPEN partitions;

	WHILE ( 1 = 1 )
	  BEGIN;
		  FETCH NEXT FROM partitions INTO @databaseid, @objectid, @indexid, @partitionnum, @frag;

		  IF @@FETCH_STATUS < 0
			BREAK;
		  
		  SELECT @databasename = Db_name(@databaseid)

		  SET @SQLString = N'
								SELECT @objectname = QUOTENAME(o.name)
								, @schemaname = QUOTENAME(s.name)
								FROM [' + @databasename + '].sys.objects AS o
								JOIN [' + @databasename
													   + '].sys.schemas as s ON s.schema_id = o.schema_id
								WHERE o.object_id = '
													   + CONVERT(NVARCHAR(20), @objectid) + ';
								SELECT @indexname = QUOTENAME(name)
								FROM ['
													   + @databasename + '].sys.indexes
								WHERE object_id = '
													   + CONVERT(NVARCHAR(20), @objectid)
													   + ' AND index_id = '
													   + CONVERT(NVARCHAR(20), @indexid) + ';
								SELECT @partitioncount = count (*)
								FROM ['
													   + @databasename + '].sys.partitions
								WHERE object_id = '
													   + CONVERT(NVARCHAR(20), @objectid)
													   + ' AND index_id = '
													   + CONVERT(NVARCHAR(20), @indexid) + '; 
							'

		  EXECUTE Sp_executesql
			@SQLString,
			N'@objectname nvarchar(128) output, @schemaname nvarchar(128) output, @indexname nvarchar(128) output, @partitioncount int output',
			@objectname=@objectname OUTPUT,
			@schemaname=@schemaname OUTPUT,
			@indexname=@indexname OUTPUT,
			@partitioncount=@partitioncount OUTPUT;

			SELECT @vAvgFragmentationInPercentRebuild = NULL
			SELECT @vAvgFragmentationInPercentReorg = NULL			
          
			SELECT @vAvgFragmentationInPercentRebuild = [Value]
			FROM [dbo].[MaintenanceParameters]
			WHERE [RoutineName] = 'REBUILD'
				  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
				  AND [DatabaseName] = @databasename
				  
			SELECT @vAvgFragmentationInPercentRebuild = [Value]
			FROM [dbo].[MaintenanceParameters]
			WHERE [RoutineName] = 'REORG'
				  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
				  AND [DatabaseName] = @databasename				  
			
			IF (@vAvgFragmentationInPercentRebuild IS NULL)
			BEGIN
				SELECT @vAvgFragmentationInPercentRebuild = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REBUILD'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = 'ALL'				
			END
			IF (@vAvgFragmentationInPercentReorg IS NULL)
			BEGIN
				SELECT @vAvgFragmentationInPercentReorg = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REORG'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = 'ALL'				
			END			
	 
		  IF ( @frag >= @vAvgFragmentationInPercentReorg AND @frag < @vAvgFragmentationInPercentRebuild )
		  BEGIN
			SET @vRebuildType = 'REORG'
			SET @command = N'ALTER INDEX ' + @indexname + N' ON ['+@databasename+'].' + @schemaname + N'.' + @objectname + N' REORGANIZE';
		  END
		  
		  IF ( @frag >= @vAvgFragmentationInPercentRebuild )
		  BEGIN
			SET @vRebuildType = 'REBUILD'
			SET @command = N'ALTER INDEX ' + @indexname + N' ON ['
						   + @databasename + '].' + @schemaname + N'.'
						   + @objectname + N' REBUILD';
		  END

		  IF @partitioncount > 1
			SET @command = @command + N' PARTITION='
						   + Cast(@partitionnum AS NVARCHAR(10));

	/*--------------INÍCIO CONTROLE DE JANELA----------------------*/
	IF (@vLimitTime IS NOT NULL OR ISNULL(@vLimitTime,0) > 0)
		BEGIN
		  IF (GETDATE()>
				(
				  SELECT	DATEADD(MINUTE,@vLimitTime,[login_time])
				  FROM		[master].[dbo].[sysprocesses]
				  WHERE		[spid] = @@SPID				
				)
			)
		  BEGIN
			BEGIN TRY
				SET @vErrorMessage = 'Tempo Limite de Janela de Rebuild Excedido.'

				EXEC [dbo].[uspMaintenanceErrorControl]
				  @vRoutineName = @vRoutineName,
				  @vDatabaseName = 'dbacorp_maintenance',
				  @vTableName = '',
				  @vErrorNumber = 50000,
				  @vErrorSeverity = 1,
				  @vErrorState = 1,
				  @vErrorProcedure = 'uspMaintenanceDefrag',
				  @vErrorMessage = @vErrorMessage
				
				SELECT @MSGError = 'Rebuild modo: ' + @vRebuildType + ' do banco '
									+ @DatabaseName + ' FINALIZADO as '
									+ CONVERT (VARCHAR, Getdate (), 120)
									+ ' - Erro: Tempo Limite de Janela Excedido.'
                PRINT @MSGError
                
				SELECT @vErrorCount = 1

				RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
						  
				BREAK;
			END TRY
			BEGIN CATCH
				BREAK;
			END CATCH
		  END
	  END
	/*--------------TÉRMINO CONTROLE DE JANELA---------------------*/
				
		  UPDATE [dbo].[MaintenanceControlFragmentation]
		  SET    [StartTime] = Getdate()
				 , [RebuildType] = @vRebuildType
		  WHERE  [IndexId] = @indexid
				 AND [DatabaseId] = @databaseid
				 AND [ObjectId] = @objectid
				 AND [PartitionNumer] = @partitionnum

		  PRINT N'Executing: ' + @command;
		  BEGIN TRY
			EXEC (@command);
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'REBUILD',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Rebuild modo: ' + @vRebuildType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

		  UPDATE [dbo].[MaintenanceControlFragmentation]
		  SET    [EndTime] = Getdate()
				 , [RebuildStatus] = 'ok'
		  WHERE  [IndexId] = @indexid
				 AND [DatabaseId] = @databaseid
				 AND [ObjectId] = @objectid
				 AND [PartitionNumer] = @partitionnum
	  END;

	CLOSE partitions;

	DEALLOCATE partitions;	
	/*----------------TÉRMINO DESFRAGMENTAÇÃO----------------------*/

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de REBUILD finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de REBUILD finalizada com sucesso.')
	END
	
END
  



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceErrorControl]    Script Date: 05/15/2014 17:34:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceErrorControl] 
		@vRoutineName nvarchar(128)
		, @vDatabaseName nvarchar(128) = ''
		, @vTableName nvarchar = ''
		, @vErrorNumber int = 0
		, @vErrorSeverity int = 0
		, @vErrorState int = 0
		, @vErrorLine int = 0
		, @vErrorProcedure nvarchar(128) = ''
		, @vErrorMessage nvarchar(4000) = ''
AS
DECLARE @ErrorMessage    NVARCHAR(4000)
		, @vCountError INT

SELECT @vCountError = Isnull(Count(*), 0)
FROM   [dbo].[MaintenanceRoutines] with (NOLOCK)
WHERE  [RoutineName] = @vRoutineName 

IF (@vCountError = 0)
	SET @vRoutineName = 'ERRO'

INSERT [dbo].[MaintenanceErrorControl] 
            (
			[RoutineName]
			, [DatabaseName]
			, [TableName]
            , [ErrorNumber]
            , [ErrorSeverity]
            , [ErrorState]
            , [ErrorProcedure]
            , [ErrorLine]
            , [ErrorMessage]
            ) 
        VALUES 
            (
            @vRoutineName
			, @vDatabaseName
			, @vTableName
            , @vErrorNumber
            , @vErrorSeverity
            , @vErrorState
            , @vErrorProcedure
            , @vErrorLine
            , @vErrorMessage
            );



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceInsertDatabases]    Script Date: 05/15/2014 17:35:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceInsertDatabases]
AS
BEGIN
	BEGIN
	DECLARE @DatabaseName   	NVARCHAR(128),
			@Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vSql				NVARCHAR(1024)


	  DECLARE cDatabases CURSOR FAST_FORWARD FOR
		  SELECT [SD].[name]
		  FROM   [master].[dbo].[sysdatabases] SD with (NOLOCK)
		  WHERE  Lower([SD].[name]) NOT IN ( 'tempdb' )
				 AND [SD].[name] NOT IN (SELECT [MD].[DatabaseName]
										 FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [MD] with (NOLOCK)) 
										 
		OPEN cDatabases
			FETCH NEXT FROM cDatabases INTO @DatabaseName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @ParameterName = ''
				SET @Parameters = ''
				SET @vCount = 0		
				SET @vSql = ''
			
				INSERT INTO [dbacorp_maintenance].[dbo].[MaintenanceDatabases]
							([DatabaseName])
					 VALUES (@DatabaseName)
					 
				/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
				DECLARE cParameters CURSOR FAST_FORWARD FOR
					SELECT [ParameterName], [Value]
					FROM   [MaintenanceParameters] with (NOLOCK)
					WHERE  [RoutineName] = 'DATABASES'
						   AND [DatabaseName] = 'ALL'
						     
				OPEN cParameters
				FETCH NEXT FROM cParameters INTO @ParameterName, @Value
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @vSql = 'UPDATE [dbo].[MaintenanceDatabases] '
								+ ' SET ['+@ParameterName+'] = '''+@Value+''''
								+ ' WHERE [DatabaseName] = '''+@DatabaseName+''''
					PRINT @vSql
					EXEC (@vSql)		
					FETCH NEXT FROM cParameters INTO @ParameterName, @Value			  
				END
				CLOSE cParameters
				DEALLOCATE cParameters
				/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/
				
				FETCH NEXT FROM cDatabases INTO @DatabaseName			
			END
		CLOSE cDatabases
		DEALLOCATE cDatabases	  
	      									 
	END
END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenancePurgeBackups]    Script Date: 05/15/2014 17:35:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspMaintenancePurgeBackups]
@DatabaseName   	NVARCHAR(128), @BackupType NVARCHAR(10), @Path NVARCHAR(1024), @ErrorIdPurge INT OUTPUT
AS
--EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = 'permissao', @BackupType = 'FULL', @Path = 'D:\bkp_sql\FULL\'
BEGIN
	BEGIN
	DECLARE @Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vSql				NVARCHAR(1024),
			@vCountParameters	INT,
			@vOldDate			NVARCHAR(20),
			@MSGError       	NVARCHAR(4000)

			SET @ParameterName = ''
			SET @Parameters = ''
			SET @vCount = 0		
			SET @vSql = ''
			SET @vCountParameters = 0

		CREATE TABLE #Tmp_MaintenanceParametersPurge
		(
				ParameterName	NVARCHAR(128)
				,Value	NVARCHAR(1024)	
		)
		
		SELECT @vCount = ISNULL(COUNT(*),0)
		FROM [dbo].[MaintenanceDatabases] with (NOLOCK)
		WHERE [DatabaseName] = @DatabaseName
			  AND [IndBackupPurge] = 'Y'
		
		IF (@vCount > 0)
		BEGIN
			SELECT @vCountParameters = 0
			
			SELECT @vCountParameters = ISNULL(COUNT(*),0)
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
				   AND [RoutineName] = 'BACKUPPURGE'
				   AND [DatabaseName] = @DatabaseName
		    
			TRUNCATE TABLE #Tmp_MaintenanceParametersPurge
		    
			IF (@vCountParameters <> 0)
			BEGIN
				INSERT INTO #Tmp_MaintenanceParametersPurge
					(
						[ParameterName]
						, [Value]
					)	    
				SELECT [ParameterName], [Value]
				FROM   [MaintenanceParameters]
				WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
					   AND [RoutineName] = 'BACKUPPURGE'			
					   AND [DatabaseName] = @DatabaseName	    
			END
			ELSE
			BEGIN
				INSERT INTO #Tmp_MaintenanceParametersPurge
					(
						[ParameterName]
						, [Value]
					)
				SELECT [ParameterName], [Value]
				FROM   [MaintenanceParameters] with (NOLOCK)
				WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
					   AND [RoutineName] = 'BACKUPPURGE'
					   AND [DatabaseName] = 'ALL'	    
			END
				
			/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
			DECLARE cParameters CURSOR FAST_FORWARD FOR
				SELECT [ParameterName], [Value]
				FROM   #Tmp_MaintenanceParametersPurge
					     
			OPEN cParameters
			FETCH NEXT FROM cParameters INTO @ParameterName, @Value
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					SET @vOldDate = REPLACE(CONVERT(NVARCHAR(20),Dateadd(n, -CONVERT(INT,@Value), GETDATE()),102),'.','-') + ' ' + CONVERT(NVARCHAR(20),Dateadd(n, -CONVERT(INT,@Value), GETDATE()),108)
					SET @vSql = '[master].[dbo].[xp_delete_file] 0,N'''+@Path+''',N''BKP'','''+@vOldDate+''',1'
					PRINT (@vSql)
					EXEC (@vSql)		
					
					SET @ErrorIdPurge = 0
				END TRY
				BEGIN CATCH
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'BACKUPPURGE',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = 3201,
					  @vErrorSeverity = 1,
					  @vErrorState = 1,
					  @vErrorProcedure = 'uspMaintenancePurgeBackups',
					  @vErrorMessage = 'Erro no procedimento de PURGE.'
					  
					SELECT @MSGError = 'Purge modo: ' + @BackupType + ' do banco '
								+ @DatabaseName + ' FALHOU as '
								+ CONVERT (VARCHAR, Getdate (), 120)
								+ ' - Erro: ' + 'Erro no procedimento de PURGE.'

					PRINT @MSGError										
					
					SET @ErrorIdPurge = 0
					
				END CATCH
				FETCH NEXT FROM cParameters INTO @ParameterName, @Value			  
			END
			
			CLOSE cParameters
			DEALLOCATE cParameters
			/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/

		RETURN isnull(@ErrorIdPurge,0)	
		      									 
		END
		
	END
	
	DROP TABLE #Tmp_MaintenanceParametersPurge	
END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceSyncLoginsAlwaysOn]    Script Date: 05/15/2014 17:35:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspMaintenanceSyncLoginsAlwaysOn]
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #Logins
	(
		loginId int IDENTITY(1, 1) NOT NULL,
		loginName nvarchar(128) NOT NULL,
		passwordHash varbinary(256) NULL,
		default_database_name nvarchar(128) NULL,
		sid varbinary(85) NOT NULL
	)

	-- openquery is used so that loginproperty function runs on the remote server,
	-- otherwise we get back null
	INSERT INTO #Logins(loginName, passwordHash, sid, default_database_name)
	select * from #Logins
	--SELECT *
	--FROM OPENQUERY([DBACORP-NOTE28\SQL2012], '
	--SELECT name, CONVERT(varbinary(256), LOGINPROPERTY(name, ''PasswordHash'')), sid, default_database_name
	--FROM master.sys.server_principals
	--WHERE
	--	type = ''S'' AND 
	--	name NOT IN (''sa'', ''guest'',''##MS_PolicyEventProcessingLogin##'',''usr_alwayson'') AND
	--	create_date >= ''01/05/2014''
	--ORDER BY name')

	DECLARE 
		@count int, @loginId int, @loginName nvarchar(128), 
		@passwordHashOld varbinary(256), @passwordHashNew varbinary(256), 
		@SID_varbinary varbinary(85), @sql nvarchar(4000), @password varchar(514), @default_database_name nvarchar(128), @SID_string varchar (514)

	SELECT @loginId = 1, @count = COUNT(*)
	FROM #Logins

	WHILE @loginId <= @count
	BEGIN
		SELECT @loginName = loginName, @passwordHashNew = passwordHash, @SID_varbinary = sid, @default_database_name = default_database_name
		FROM #Logins
		WHERE loginId = @loginId

		-- if the account doesn't exist, then we need to create it
		IF NOT EXISTS (SELECT * FROM master.sys.server_principals WHERE name = @loginName)
		BEGIN
			EXEC master.dbo.sp_hexadecimal @passwordHashNew, @password OUTPUT
			EXEC master.dbo.sp_hexadecimal @SID_varbinary,@SID_string OUT

			SET @sql = 'CREATE LOGIN ' + @loginName + ' WITH PASSWORD = '
			SET @sql = @sql + CONVERT(nvarchar(512), COALESCE(@password, 'NULL')) 
			SET @sql = @sql + ' HASHED , SID = ' + CONVERT(nvarchar(512), @SID_string)
			SET @sql = @sql + ' , DEFAULT_DATABASE = [' + @default_database_name + ']'
			SET @sql = @sql + ' , CHECK_POLICY = OFF' 
			PRINT @sql
			EXEC (@sql)

			PRINT 'login created'
		END
		-- if the account does exist, then we need to drop/create to sync the password;
		-- can't alter as hashed isn't supported
		ELSE
		BEGIN
			SELECT @passwordHashOld = CONVERT(varbinary(256), LOGINPROPERTY(@loginName, 'PasswordHash'))

			-- only bother updating if the password has changed since the last sync
			IF @passwordHashOld <> @passwordHashNew
			BEGIN
				EXEC master.dbo.sp_hexadecimal @passwordHashNew, @password OUTPUT

				--SET @sql = 'DROP LOGIN ' + @loginName
				--PRINT @sql
				--EXEC (@sql)

				SET @sql = 'ALTER LOGIN ' + @loginName + ' WITH PASSWORD = '
				SET @sql = @sql + CONVERT(nvarchar(512), COALESCE(@password, 'NULL'))
				SET @sql = @sql + ' HASHED, CHECK_POLICY = OFF' 
				PRINT @sql
				EXEC (@sql)

				PRINT 'login "altered"'
			END
		END

		SET @loginId = @loginId + 1
	END

	DROP TABLE #Logins

END

GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceUpdateStatsFull]    Script Date: 05/15/2014 17:35:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceUpdateStatsFull]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE 
			@databasename               NVARCHAR(128),
			@vSql                       NVARCHAR(4000),
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT,
			@vCount         			INT,
			@vErrorProcedure			NVARCHAR(200),
			@vRoutineName   			NVARCHAR(128),
			@vErrorNumber   			INT,
			@vErrorSeverity 			INT,
			@vErrorState    			INT,
			@vErrorLine     			INT,
			@vErrorMessage  			NVARCHAR(4000),
			@vErrorCount				INT,
			@vErrorCountAux				INT,
			@command					NVARCHAR(4000),
			@MSGError       			NVARCHAR(4000)


	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('UpdateStatsFull',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[name]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND [MD].[IndUpdateStatsFull] = 'Y'	
			   AND Databasepropertyex ([SD].[name] , 'UPDATEABILITY' ) = 'READ_WRITE'
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @databasename
            IF @@FETCH_STATUS < 0
              BREAK;
          
		  SET @command = 'EXEC ['+@databasename+'].dbo.sp_msForEachTable ''UPDATE STATISTICS ? WITH FULLSCAN'''

		  PRINT N'Executing: ' + @command;

		  BEGIN TRY
			EXEC (@command);
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'UpdateStatsFull',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'UpdateStatsFull do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de UpdateStatsFull finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de UpdateStatsFull finalizada com sucesso.')
	END
  
  END


GO

=======
USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCheckdb]    Script Date: 05/15/2014 17:34:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCheckdb]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE 
			@databasename               NVARCHAR(128),
			@vSql                       NVARCHAR(4000),
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT,
			@vCount         			INT,
			@vErrorProcedure			NVARCHAR(200),
			@vRoutineName   			NVARCHAR(128),
			@vErrorNumber   			INT,
			@vErrorSeverity 			INT,
			@vErrorState    			INT,
			@vErrorLine     			INT,
			@vErrorMessage  			NVARCHAR(4000),
			@vErrorCount				INT,
			@vErrorCountAux				INT,
			@vDateCheckdbStart			DATETIME,
			@vDateCheckdbFinish			DATETIME,	
			@vCheckdbTimeId				INT,					
			@command					NVARCHAR(4000),
			@MSGError       			NVARCHAR(4000)


	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('CHECKDB',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[name]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND [MD].[IndCheckdb] = 'Y'	
			   AND 
			   (
					( CASE
						WHEN [IndAlwaysOn] = 'Y' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) = 'READ_ONLY'
					OR 
					( CASE
						WHEN [IndAlwaysOn] = 'N' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) IN ( 'READ_WRITE', 'READ_ONLY')
				)
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @databasename
            IF @@FETCH_STATUS < 0
              BREAK;
          
		  SET @command = 'dbcc checkdb('''+@databasename+''')'

		  PRINT N'Executing: ' + @command;

		  SELECT @vDateCheckdbStart = GETDATE()

	      INSERT INTO [dbo].[MaintenanceCheckdbTimes]
						([DatabaseName],
						 [StartTime])
		  VALUES      (@DatabaseName,
					   @vDateCheckdbStart) 

		  SELECT @vCheckdbTimeId = SCOPE_IDENTITY()

		  BEGIN TRY
			EXEC (@command);
			
			SELECT @vDateCheckdbFinish = GETDATE()
			
			UPDATE [dbo].[MaintenanceCheckdbTimes]
			SET    [EndTime] = @vDateCheckdbFinish
				   ,[CheckdbStatus] = 'Finalizado com Sucesso'
			WHERE  [CheckdbId] = @vCheckdbTimeId			
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'CHECKDB',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Checkdb do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vDateCheckdbFinish = GETDATE()
					
					UPDATE [dbo].[MaintenanceCheckdbTimes]
					SET    [EndTime] = @vDateCheckdbFinish
						   ,[CheckdbStatus] = 'Finalizado com Erro'
					WHERE  [CheckdbId] = @vCheckdbTimeId	                    
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de CHECKDB finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de CHECKDB finalizada com sucesso.')
	END
  
  END


GO


USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCollectDegraf]    Script Date: 05/15/2014 17:34:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCollectDegraf]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE @databaseid                 INT,
			@databasename               NVARCHAR(128),
			@objectid                   INT,
			@indexid                    INT,
			@partitioncount             BIGINT,
			@schemaname                 NVARCHAR(130),
			@objectname                 NVARCHAR(130),
			@indexname                  NVARCHAR(130),
			@partitionnum               BIGINT,
			@partitions                 BIGINT,
			@frag                       FLOAT,
			@command                    NVARCHAR(4000),
			@vSql                       NVARCHAR(4000),
			@vAvgFragmentationInPercent FLOAT, 
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT

	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('COLLECTDEFRAG',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vAvgFragmentationInPercent = 0.0
	
	IF (SELECT Object_id('MaintenanceControlFragmentation')) IS NULL
	BEGIN
		CREATE TABLE [dbo].[MaintenanceControlFragmentation]
		  (
			 [DatabaseId]					INT,
			 [DatabaseName]					NVARCHAR(128),
			 [ObjectId]						BIGINT,
			 [IndexId]						INT,
			 [PartitionNumer]				INT,
			 [AvgFragmentationInPercent]	FLOAT,
			 [DateCollect]					DATETIME DEFAULT Getdate(),
			 [StartTime]					DATETIME,
			 [EndTime]						DATETIME,
			 [RebuildStatus]                CHAR(3) DEFAULT '',
			 [RebuildType]					NVARCHAR(20)
		  )
	END 
	
	UPDATE [dbo].[MaintenanceControlFragmentation]
	SET    [RebuildStatus] = 'Último rebuild não finalizado.'
	WHERE  [RebuildStatus] = ''

      DECLARE @dbId INT
      SET @dbId = 1
      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[dbid]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND Databasepropertyex ([SD].[name] , 'UPDATEABILITY' ) = 'READ_WRITE'
               AND [MD].[IndRebuild] = 'Y'	
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @dbId
            IF @@FETCH_STATUS < 0
              BREAK;
              
				SELECT @vAvgFragmentationInPercent = NULL
              
				SELECT @vAvgFragmentationInPercent = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REBUILD'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = db_name(@dbId)
				
				IF (@vAvgFragmentationInPercent IS NULL)
				BEGIN
					SELECT @vAvgFragmentationInPercent = [Value]
					FROM [dbo].[MaintenanceParameters]
					WHERE [RoutineName] = 'REBUILD'
						  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
						  AND [DatabaseName] = 'ALL'				
				END
				
				INSERT INTO [dbo].[MaintenanceControlFragmentation]
							([DatabaseName],
							 [DatabaseId],
							 [ObjectId],
							 [IndexId],
							 [PartitionNumer],
							 [AvgFragmentationInPercent])
				SELECT DB_NAME([database_id]),
					   [database_id],
					   [object_id],
					   [index_id],
					   [partition_number],
					   [avg_fragmentation_in_percent]
				FROM   [sys].[Dm_db_index_physical_stats] (@dbId, NULL, NULL, NULL, 'LIMITED')
				WHERE  [index_id] > 0
					   AND [avg_fragmentation_in_percent] >= @vAvgFragmentationInPercent
				
        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 
  
  END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceCreateDirectory]    Script Date: 05/15/2014 17:34:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceCreateDirectory] @Path NVARCHAR(1024)
AS
  BEGIN
      DECLARE @chkdirectory AS NVARCHAR(4000)
      DECLARE @folder_exists AS INT
      SET @chkdirectory = @Path
      DECLARE @file_results TABLE
        (
           file_exists             INT,
           file_is_a_directory     INT,
           parent_directory_exists INT
        )
      INSERT INTO @file_results
                  (file_exists,
                   file_is_a_directory,
                   parent_directory_exists)
      EXEC master.dbo.Xp_fileexist
        @chkdirectory
      SELECT @folder_exists = file_is_a_directory
      FROM   @file_results
      --script to create directory        
      IF @folder_exists = 0
        BEGIN
            PRINT 'Directory is not exists, creating new one '
            EXECUTE master.dbo.Xp_create_subdir
              @chkdirectory
            PRINT @chkdirectory + 'created on ' + @@SERVERNAME
        END
      ELSE
        PRINT 'Directory already exists'
  END 



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceDatabaseBackups]    Script Date: 05/15/2014 17:34:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceDatabaseBackups]
@BackupType VARCHAR (10)
--[uspMaintenanceDatabaseBackups] @BackupType = 'FULL'
--[uspMaintenanceDatabaseBackups] @BackupType = 'DIFF'
--[uspMaintenanceDatabaseBackups] @BackupType = 'LOG'
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/

	DECLARE @DatabaseName   	NVARCHAR(128),
			@TableName      	NVARCHAR(128),
			@Path           	NVARCHAR(1024),
			@PathArq        	NVARCHAR(1024),
			@DateLog        	NVARCHAR(128),
			@MSGError       	NVARCHAR(4000),
			@Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vErrorProcedure	NVARCHAR(200),
			@vRoutineName   	NVARCHAR(128),
			@vErrorNumber   	INT,
			@vErrorSeverity 	INT,
			@vErrorState    	INT,
			@vErrorLine     	INT,
			@vErrorMessage  	NVARCHAR(4000),
			@vSql           	NVARCHAR(4000),
			@vErrorCount		INT,
			@vErrorCountAux		INT,			
			@vRecoveryModel		NVARCHAR(20),
			@vDateRoutineStart	DATETIME,
			@vDateRoutineFinish	DATETIME,
			@vDateBackupStart	DATETIME,
			@vDateBackupFinish	DATETIME,
			@vLogShipping		INT,
			@vRoutineTimeId		INT,
			@vBackupTimeId		INT,
			@vCountParameters	INT,
			@ErrorIdPurge		INT			

	CREATE TABLE #DirectoryInfo
	  (
		 FileExists            BIT,
		 FileIsADirectory      BIT,
		 ParentDirectoryExists BIT
	  ) 
	  
	CREATE TABLE #Tmp_MaintenanceParameters
	(
			ParameterName	NVARCHAR(128)
			,Value	NVARCHAR(1024)	
	)
		
	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	
	/*-----------INÍCIO PREENCHIMENTO DE VARIÁVEIS-----------------*/
    SELECT @vErrorProcedure = 'uspMaintenanceDatabaseBackups',
           @vRoutineName = 'BACKUP' + @BackupType;
           
    SELECT @DateLog = Replace(Replace(Replace(CONVERT(VARCHAR(19), Getdate(), 126), '-', ''), 'T', ''), ':', '')  
    
    SELECT @vErrorCount = 0, @vErrorCountAux = 0      
    
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      (@vRoutineName,
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
    
	/*----------TÉRMINO PREENCHIMENTO DE VARIÁVEIS-----------------*/

	/*-----------INÍCIO PREENCHIMENTO DE NOVO BANCOS---------------*/
	BEGIN TRY
		EXEC [dbo].[uspMaintenanceInsertDatabases]
	END TRY
	BEGIN CATCH
		SET @vErrorMessage = 'Erro durante a inserção de novos databases.'

		EXEC [dbo].[uspMaintenanceErrorControl]
		  @vRoutineName = @vRoutineName,
		  @vDatabaseName = 'dbacorp_maintenance',
		  @vTableName = '',
		  @vErrorNumber = 50000,
		  @vErrorSeverity = 1,
		  @vErrorState = 1,
		  @vErrorProcedure = 'uspMaintenanceInsertDatabases',
		  @vErrorMessage = @vErrorMessage
		
		PRINT @vErrorMessage
		SELECT @vErrorCount = 1
		RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
	END CATCH
	/*-----------TÉRMINO PREENCHIMENTO DE NOVO BANCOS---------------*/
	
	/*------INÍCIO VALIDAÇÃO DO PARÂMETRO BACKUPTYPE---------------*/
	IF @BackupType NOT IN ('FULL','DIFF','LOG') OR @BackupType IS NULL
	BEGIN
		SET @vErrorMessage = 'The value for the parameter @BackupType is not supported.'

		EXEC [dbo].[uspMaintenanceErrorControl]
		  @vRoutineName = @vRoutineName,
		  @vDatabaseName = 'dbacorp_maintenance',
		  @vTableName = '',
		  @vErrorNumber = 50000,
		  @vErrorSeverity = 1,
		  @vErrorState = 1,
		  @vErrorProcedure = @vErrorProcedure,
		  @vErrorMessage = @vErrorMessage
		
		PRINT @vErrorMessage
		SELECT @vErrorCount = 1
		RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
	END
	/*------TÉRMINO VALIDAÇÃO DO PARÂMETRO BACKUPTYPE--------------*/
	   
    DECLARE cDatabases CURSOR FAST_FORWARD FOR
      SELECT [md].[DatabaseName]
      FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [md] WITH (NOLOCK)
      WHERE  ( CASE
                 WHEN @BackupType = 'FULL' THEN [IndBackupFull]
                 WHEN @BackupType = 'DIFF' THEN [IndBackupDiff]
                 WHEN @BackupType = 'LOG' THEN [IndBackupLog]
               END ) = 'Y'
               AND DATABASEPROPERTYEX([DatabaseName],'STATUS') = 'ONLINE'
				 AND UPPER([DatabaseName]) NOT IN ('TEMPDB')
				 --AND [DatabaseName] = 'cleartrace'
			   AND 
			   (
					( CASE
						WHEN IndAlwaysOn = 'Y' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) = 'READ_WRITE'
					OR 
					( CASE
						WHEN IndAlwaysOn = 'N' THEN DATABASEPROPERTYEX([DatabaseName],'Updateability')
					  END ) IN ( 'READ_WRITE', 'READ_ONLY')
				)
               
    OPEN cDatabases
    FETCH NEXT FROM cDatabases INTO @DatabaseName
    WHILE @@FETCH_STATUS = 0
      BEGIN

		/*------INÍCIO PREENCHIMENTO DE VARIÁVEIS PARA CADA BANCO------*/
		SET @Path = ''
		SET @ParameterName = ''
		SET @Parameters = ''
		SET @vCount = 0
		SET @vSql = ''
		
		SELECT @Path = ( CASE
						 WHEN @BackupType = 'FULL' THEN [PathBackupFull]
						 WHEN @BackupType = 'DIFF' THEN [PathBackupDiff]
						 WHEN @BackupType = 'LOG' THEN [PathBackupLog]
					   END )
		FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [cb] WITH (NOLOCK)
		WHERE  [DatabaseName] = @DatabaseName

		SELECT @Path = @Path + UPPER(LTRIM(RTRIM(@DatabaseName))) + '\'
		/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
		SELECT @vCountParameters = 0
		
		SELECT @vCountParameters = ISNULL(COUNT(*),0)
		FROM   [MaintenanceParameters]
		WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
			   AND [DatabaseName] = @DatabaseName
	    
	    TRUNCATE TABLE #Tmp_MaintenanceParameters
	    
	    IF (@vCountParameters <> 0)
	    BEGIN
	        INSERT INTO #Tmp_MaintenanceParameters
				(
					[ParameterName]
					, [Value]
				)	    
			SELECT [ParameterName], [Value]
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
				   AND [DatabaseName] = @DatabaseName	    
	    END
	    ELSE
	    BEGIN
	        INSERT INTO #Tmp_MaintenanceParameters
				(
					[ParameterName]
					, [Value]
				)
			SELECT [ParameterName], [Value]
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [RoutineName] = 'BACKUP' + @BackupType + ''
				   AND [DatabaseName] = 'ALL'	    
	    END
				   		
		DECLARE cParameters CURSOR FAST_FORWARD FOR
			SELECT [ParameterName], [Value]
			FROM   #Tmp_MaintenanceParameters with (NOLOCK)
				     
		OPEN cParameters
		FETCH NEXT FROM cParameters INTO @ParameterName, @Value
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ( @Parameters = ''
				 AND @vCount = 0
				 AND @BackupType IN ( 'FULL', 'LOG' ) )
			  BEGIN
				  SET @Parameters = ' WITH '
				  SET @Parameters = @Parameters + @ParameterName + ''
				  
					IF (@Value <> '*')
					BEGIN
						SET @Parameters = @Parameters + ' = ' + @Value + ''
					END
				  SET @vCount = 1
			  END
			ELSE
			  BEGIN
				  SET @Parameters = @Parameters + ', ' + @ParameterName + ''
				  
					IF (@Value <> '*')
					BEGIN
						SET @Parameters = @Parameters + ' = ' + @Value + ''
					END				  
			  END
			FETCH NEXT FROM cParameters INTO @ParameterName, @Value
		END
		CLOSE cParameters
		DEALLOCATE cParameters

		SELECT @PathArq = @Path + @DatabaseName + '_' + @BackupType + '_' + @DateLog + '.BKP' 
		/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/
		
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','COMPRESSION', '','cleartrace')
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','FORMAT', '','cleartrace')
--		  insert into MaintenanceParameters(RoutineName,ParameterName,Value,DatabaseName) values ('BACKUPFULL','CHECKSUM', '','cleartrace')

		/*------INÍCIO VERIFICAÇÃO DE DIRETÓRIO PARA CADA BANCO------*/ 
		TRUNCATE TABLE #DirectoryInfo

		INSERT INTO #DirectoryInfo
				  (FileExists,
				   FileIsADirectory,
				   ParentDirectoryExists)
		EXECUTE [master].dbo.Xp_fileexist @Path
		
		IF NOT EXISTS (SELECT *
					   FROM   #DirectoryInfo
					   WHERE  [FileExists] = 0
							  AND [FileIsADirectory] = 1
							  AND [ParentDirectoryExists] = 1) 
			BEGIN
				EXEC [dbo].[uspMaintenanceCreateDirectory] @Path
			END
			
		TRUNCATE TABLE #DirectoryInfo			
			
		INSERT INTO #DirectoryInfo
				  ([FileExists],
				   [FileIsADirectory],
				   [ParentDirectoryExists])
		EXEC [master].[dbo].[Xp_fileexist] @Path
		
		IF NOT EXISTS (SELECT *
					   FROM   #DirectoryInfo
					   WHERE  [FileExists] = 0
							  AND [FileIsADirectory] = 1
							  AND [ParentDirectoryExists] = 1) 
			BEGIN
                /*-----------------DIRETÓRIO NÃO ENCONTRADO------------------*/
				SELECT @vErrorMessage = 'Operating system error 3(O sistema não pode encontrar o diretório '+@path+'.)'

				EXEC [dbo].[uspMaintenanceErrorControl]
				  @vRoutineName = @vRoutineName,
				  @vDatabaseName = @DatabaseName,
				  @vTableName = '',
				  @vErrorNumber = 3201,
				  @vErrorSeverity = 1,
				  @vErrorState = 1,
				  @vErrorProcedure = @vErrorProcedure,
				  @vErrorMessage = @vErrorMessage
				  
				SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
									+ @DatabaseName + ' FALHOU as '
									+ CONVERT (VARCHAR, Getdate (), 120)
									+ ' - Erro: '+@vErrorMessage
				PRINT @MSGError
                
				SELECT @vErrorCount = 1
				/*-----------------DIRETÓRIO NÃO ENCONTRADO------------------*/                  
			END
		/*-----TÉRMINO VERIFICAÇÃO DE DIRETÓRIO PARA CADA BANCO------*/       
		ELSE
			BEGIN
			    /*-------------INÍCIO BACKUP PARA CADA BANCO-----------------*/
				BEGIN TRY
				
					PRINT 'Backup modo: ' + @BackupType + ' do banco '
						  + @DatabaseName + ' INICIADO as '
						  + CONVERT (VARCHAR, Getdate (), 120)
					
					SELECT @vErrorCountAux = 0
					
					SELECT @vDateBackupStart = GETDATE()
					
					INSERT INTO [dbo].[MaintenanceBackupTimes]
								([DatabaseName],
								 [BackupType],
								 [StartTime])
					VALUES      (@DatabaseName,
								 @BackupType,
								 @vDateBackupStart) 

					SELECT @vBackupTimeId = SCOPE_IDENTITY()
				  
					IF @BackupType = 'FULL'
					  BEGIN
						  PRINT 'Commando: ' + 'BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' ' + @Parameters
						  
						  EXEC ('BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' ' + @Parameters)
						  
						  PRINT 'Backup modo: ' + @BackupType + ' do banco '
												+ @DatabaseName + ' FINALIZADO as '
												+ CONVERT (VARCHAR, Getdate (), 120)
												
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  
					  END
					IF @BackupType = 'DIFF'
					  BEGIN
						  PRINT 'Commando: ' + 'BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' WITH DIFFERENTIAL ' + @Parameters
					  
						  EXEC ('BACKUP DATABASE ['+@DatabaseName+'] TO DISK = '''+@PathArq+''' WITH DIFFERENTIAL ' + @Parameters)
						  
						  PRINT 'Backup modo: ' + @BackupType + ' do banco '
												+ @DatabaseName + ' FINALIZADO as '
												+ CONVERT (VARCHAR, Getdate (), 120)						  
												
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  												
					  END
					IF @BackupType = 'LOG'
					  BEGIN
						/*------INÍCIO VALIDAÇÃO DO PARÂMETRO BACKUPFULL---------------*/
						
						SELECT @vRecoveryModel = CONVERT(NVARCHAR(20),(DATABASEPROPERTYEX(@DatabaseName,'RECOVERY')))
						SELECT @vLogShipping = ISNULL(COUNT(*),0) FROM [msdb].[dbo].[log_shipping_primary_databases] WHERE [primary_database] = @DatabaseName
						
						IF (@vRecoveryModel = 'FULL' AND @vLogShipping = 0)
						BEGIN
						    PRINT 'Commando: ' + 'BACKUP LOG ['+@DatabaseName+'] TO DISK = '''+@PathArq+'''' + @Parameters
						    
							EXEC ('BACKUP LOG ['+@DatabaseName+'] TO DISK = '''+@PathArq+'''' + @Parameters)	
							
							PRINT 'Backup modo: ' + @BackupType + ' do banco '
													+ @DatabaseName + ' FINALIZADO as '
													+ CONVERT (VARCHAR, Getdate (), 120)	
																								
						  /*---------------INÍCIO O PURGE DO BANCO-----------------------*/
						  EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = @DatabaseName, @BackupType = @BackupType, @Path = @Path, @ErrorIdPurge = @ErrorIdPurge OUTPUT
						  IF (@ErrorIdPurge <> 0)
						  BEGIN
							SELECT @vErrorCount = 1							 
						  END
						  /*---------------TÉRMINO O PURGE DO BANCO----------------------*/						  													
						END
						ELSE
						BEGIN
							IF (@vLogShipping > 0)
							BEGIN
								SELECT @vErrorMessage = 'O banco '+@DatabaseName+' está configurado com LOGSHIPPING.'
							END
							IF (@vRecoveryModel <> 'FULL')
							BEGIN
								SELECT @vErrorMessage = 'O banco '+@DatabaseName+' não está no modo FULL.'
							END							

							EXEC [dbo].[uspMaintenanceErrorControl]
							  @vRoutineName = @vRoutineName,
							  @vDatabaseName = @DatabaseName,
							  @vTableName = '',
							  @vErrorNumber = 3201,
							  @vErrorSeverity = 1,
							  @vErrorState = 1,
							  @vErrorProcedure = @vErrorProcedure,
							  @vErrorMessage = @vErrorMessage
							  
							SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
										
							PRINT @MSGError
							SELECT @vErrorCount = 1		
							SELECT @vErrorCountAux = 1					
						END
						/*------TÉRMINO VALIDAÇÃO DO PARÂMETRO BACKUPFULL--------------*/						  
						SELECT @vDateBackupFinish = GETDATE()
						
					  END
				END TRY
                /*-------------TÉRMINO BACKUP PARA CADA BANCO----------------*/
                
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = @vRoutineName,
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Backup modo: ' + @BackupType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
					SELECT @vErrorCountAux = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
                
				IF (@vErrorCountAux = 0)
				BEGIN
   					SELECT @vDateBackupFinish = GETDATE()

					UPDATE [dbo].[MaintenanceBackupTimes]
					SET    [EndTime] = @vDateBackupFinish
						   ,[BackupStatus] = 'Finalizado com Sucesso'
					WHERE  [BackupId] = @vBackupTimeId

				END
				ELSE
				BEGIN
   					SELECT @vDateBackupFinish = GETDATE()
					UPDATE [dbo].[MaintenanceBackupTimes]
					SET    [EndTime] = @vDateBackupFinish
						   ,[BackupStatus] = 'Finalizado com Erro'
					WHERE  [BackupId] = @vBackupTimeId 
					
					SELECT @vErrorCountAux = 0		
				END                 
            END
          FETCH NEXT FROM cDatabases INTO @DatabaseName
      END
    CLOSE cDatabases
    DEALLOCATE cDatabases
    DROP TABLE #DirectoryInfo
    DROP TABLE #Tmp_MaintenanceParameters
	
	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de backup finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de backup finalizada com sucesso.')
	END
END



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceDefrag]    Script Date: 05/15/2014 17:34:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceDefrag]
AS  
BEGIN
SET NOCOUNT ON
SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE @databaseid							INT,
			@databasename						NVARCHAR(128),
			@objectid							INT,
			@indexid							INT,
			@partitioncount						BIGINT,
			@schemaname							NVARCHAR(130),
			@objectname							NVARCHAR(130),
			@indexname							NVARCHAR(130),
			@partitionnum						BIGINT,
			@partitions							BIGINT,
			@frag								FLOAT,
			@command							NVARCHAR(4000),
			@vSql								NVARCHAR(4000),
			@vAvgFragmentationInPercentRebuild	FLOAT, 
			@vAvgFragmentationInPercentReorg	FLOAT, 			
			@vDateRoutineStart					DATETIME,
			@vDateRoutineFinish					DATETIME,
			@vRoutineTimeId						INT,
			@SQLString							NVARCHAR(4000),
			@vRebuildType						NVARCHAR(20),
			@vCount         					INT,
			@vErrorProcedure					NVARCHAR(200),
			@vRoutineName   					NVARCHAR(128),
			@vErrorNumber   					INT,
			@vErrorSeverity 					INT,
			@vErrorState    					INT,
			@vErrorLine     					INT,
			@vErrorMessage  					NVARCHAR(4000),
			@vErrorCount						INT,
			@vErrorCountAux						INT,
			@MSGError       					NVARCHAR(4000),
			@vLimitTime							INT;

	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
    SELECT @vErrorProcedure = 'uspMaintenanceDatabaseBackups',
           @vRoutineName = 'REBUILD'
           	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('REBUILD',
				 @vDateRoutineStart) 
				 
	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	
	SET @vLimitTime = NULL
	
	SELECT @vLimitTime = [Value]
	FROM   [MaintenanceParameters] with (NOLOCK)
	WHERE  [RoutineName] = 'REBUILD'
		   AND [ParameterName] = 'LIMITTIME'
		   AND [DatabaseName] = 'ALL'	

	/*-----------------INÍCIO DESFRAGMENTAÇÃO----------------------*/
	DECLARE partitions CURSOR FAST_FORWARD FOR
	  SELECT [CF].[DatabaseId],
			 [CF].[ObjectId],
			 [CF].[IndexId],
			 [CF].[PartitionNumer],
			 [CF].[AvgFragmentationInPercent]
	  FROM   [dbo].[MaintenanceControlFragmentation] CF WITH (NOLOCK)
	  WHERE  [CF].[StartTime] IS NULL
			 AND [CF].[RebuildStatus] = ''
			 AND (CONVERT(NVARCHAR(20),[CF].[DatabaseId])+'_'+CONVERT(NVARCHAR(20),[CF].[ObjectId])) NOT IN 
							(
								SELECT	CONVERT(NVARCHAR(20),[EL].[DatabaseId])+'_'+CONVERT(NVARCHAR(20),[EL].[ObjectId])
								FROM	[dbo].[MaintenanceExcludeListTables] [EL]
							)
	  ORDER BY [CF].[AvgFragmentationInPercent] DESC;

	OPEN partitions;

	WHILE ( 1 = 1 )
	  BEGIN;
		  FETCH NEXT FROM partitions INTO @databaseid, @objectid, @indexid, @partitionnum, @frag;

		  IF @@FETCH_STATUS < 0
			BREAK;
		  
		  SELECT @databasename = Db_name(@databaseid)

		  SET @SQLString = N'
								SELECT @objectname = QUOTENAME(o.name)
								, @schemaname = QUOTENAME(s.name)
								FROM [' + @databasename + '].sys.objects AS o
								JOIN [' + @databasename
													   + '].sys.schemas as s ON s.schema_id = o.schema_id
								WHERE o.object_id = '
													   + CONVERT(NVARCHAR(20), @objectid) + ';
								SELECT @indexname = QUOTENAME(name)
								FROM ['
													   + @databasename + '].sys.indexes
								WHERE object_id = '
													   + CONVERT(NVARCHAR(20), @objectid)
													   + ' AND index_id = '
													   + CONVERT(NVARCHAR(20), @indexid) + ';
								SELECT @partitioncount = count (*)
								FROM ['
													   + @databasename + '].sys.partitions
								WHERE object_id = '
													   + CONVERT(NVARCHAR(20), @objectid)
													   + ' AND index_id = '
													   + CONVERT(NVARCHAR(20), @indexid) + '; 
							'

		  EXECUTE Sp_executesql
			@SQLString,
			N'@objectname nvarchar(128) output, @schemaname nvarchar(128) output, @indexname nvarchar(128) output, @partitioncount int output',
			@objectname=@objectname OUTPUT,
			@schemaname=@schemaname OUTPUT,
			@indexname=@indexname OUTPUT,
			@partitioncount=@partitioncount OUTPUT;

			SELECT @vAvgFragmentationInPercentRebuild = NULL
			SELECT @vAvgFragmentationInPercentReorg = NULL			
          
			SELECT @vAvgFragmentationInPercentRebuild = [Value]
			FROM [dbo].[MaintenanceParameters]
			WHERE [RoutineName] = 'REBUILD'
				  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
				  AND [DatabaseName] = @databasename
				  
			SELECT @vAvgFragmentationInPercentRebuild = [Value]
			FROM [dbo].[MaintenanceParameters]
			WHERE [RoutineName] = 'REORG'
				  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
				  AND [DatabaseName] = @databasename				  
			
			IF (@vAvgFragmentationInPercentRebuild IS NULL)
			BEGIN
				SELECT @vAvgFragmentationInPercentRebuild = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REBUILD'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = 'ALL'				
			END
			IF (@vAvgFragmentationInPercentReorg IS NULL)
			BEGIN
				SELECT @vAvgFragmentationInPercentReorg = [Value]
				FROM [dbo].[MaintenanceParameters]
				WHERE [RoutineName] = 'REORG'
					  AND [ParameterName] =	'AVGFRAGMENTATIONINPERCENT'
					  AND [DatabaseName] = 'ALL'				
			END			
	 
		  IF ( @frag >= @vAvgFragmentationInPercentReorg AND @frag < @vAvgFragmentationInPercentRebuild )
		  BEGIN
			SET @vRebuildType = 'REORG'
			SET @command = N'ALTER INDEX ' + @indexname + N' ON ['+@databasename+'].' + @schemaname + N'.' + @objectname + N' REORGANIZE';
		  END
		  
		  IF ( @frag >= @vAvgFragmentationInPercentRebuild )
		  BEGIN
			SET @vRebuildType = 'REBUILD'
			SET @command = N'ALTER INDEX ' + @indexname + N' ON ['
						   + @databasename + '].' + @schemaname + N'.'
						   + @objectname + N' REBUILD';
		  END

		  IF @partitioncount > 1
			SET @command = @command + N' PARTITION='
						   + Cast(@partitionnum AS NVARCHAR(10));

	/*--------------INÍCIO CONTROLE DE JANELA----------------------*/
	IF (@vLimitTime IS NOT NULL OR ISNULL(@vLimitTime,0) > 0)
		BEGIN
		  IF (GETDATE()>
				(
				  SELECT	DATEADD(MINUTE,@vLimitTime,[login_time])
				  FROM		[master].[dbo].[sysprocesses]
				  WHERE		[spid] = @@SPID				
				)
			)
		  BEGIN
			BEGIN TRY
				SET @vErrorMessage = 'Tempo Limite de Janela de Rebuild Excedido.'

				EXEC [dbo].[uspMaintenanceErrorControl]
				  @vRoutineName = @vRoutineName,
				  @vDatabaseName = 'dbacorp_maintenance',
				  @vTableName = '',
				  @vErrorNumber = 50000,
				  @vErrorSeverity = 1,
				  @vErrorState = 1,
				  @vErrorProcedure = 'uspMaintenanceDefrag',
				  @vErrorMessage = @vErrorMessage
				
				SELECT @MSGError = 'Rebuild modo: ' + @vRebuildType + ' do banco '
									+ @DatabaseName + ' FINALIZADO as '
									+ CONVERT (VARCHAR, Getdate (), 120)
									+ ' - Erro: Tempo Limite de Janela Excedido.'
                PRINT @MSGError
                
				SELECT @vErrorCount = 1

				RAISERROR(@vErrorMessage,16,1) WITH NOWAIT 	
						  
				BREAK;
			END TRY
			BEGIN CATCH
				BREAK;
			END CATCH
		  END
	  END
	/*--------------TÉRMINO CONTROLE DE JANELA---------------------*/
				
		  UPDATE [dbo].[MaintenanceControlFragmentation]
		  SET    [StartTime] = Getdate()
				 , [RebuildType] = @vRebuildType
		  WHERE  [IndexId] = @indexid
				 AND [DatabaseId] = @databaseid
				 AND [ObjectId] = @objectid
				 AND [PartitionNumer] = @partitionnum

		  PRINT N'Executing: ' + @command;
		  BEGIN TRY
			EXEC (@command);
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'REBUILD',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'Rebuild modo: ' + @vRebuildType + ' do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

		  UPDATE [dbo].[MaintenanceControlFragmentation]
		  SET    [EndTime] = Getdate()
				 , [RebuildStatus] = 'ok'
		  WHERE  [IndexId] = @indexid
				 AND [DatabaseId] = @databaseid
				 AND [ObjectId] = @objectid
				 AND [PartitionNumer] = @partitionnum
	  END;

	CLOSE partitions;

	DEALLOCATE partitions;	
	/*----------------TÉRMINO DESFRAGMENTAÇÃO----------------------*/

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de REBUILD finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de REBUILD finalizada com sucesso.')
	END
	
END
  



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceErrorControl]    Script Date: 05/15/2014 17:34:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceErrorControl] 
		@vRoutineName nvarchar(128)
		, @vDatabaseName nvarchar(128) = ''
		, @vTableName nvarchar = ''
		, @vErrorNumber int = 0
		, @vErrorSeverity int = 0
		, @vErrorState int = 0
		, @vErrorLine int = 0
		, @vErrorProcedure nvarchar(128) = ''
		, @vErrorMessage nvarchar(4000) = ''
AS
DECLARE @ErrorMessage    NVARCHAR(4000)
		, @vCountError INT

SELECT @vCountError = Isnull(Count(*), 0)
FROM   [dbo].[MaintenanceRoutines] with (NOLOCK)
WHERE  [RoutineName] = @vRoutineName 

IF (@vCountError = 0)
	SET @vRoutineName = 'ERRO'

INSERT [dbo].[MaintenanceErrorControl] 
            (
			[RoutineName]
			, [DatabaseName]
			, [TableName]
            , [ErrorNumber]
            , [ErrorSeverity]
            , [ErrorState]
            , [ErrorProcedure]
            , [ErrorLine]
            , [ErrorMessage]
            ) 
        VALUES 
            (
            @vRoutineName
			, @vDatabaseName
			, @vTableName
            , @vErrorNumber
            , @vErrorSeverity
            , @vErrorState
            , @vErrorProcedure
            , @vErrorLine
            , @vErrorMessage
            );



GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceInsertDatabases]    Script Date: 05/15/2014 17:35:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceInsertDatabases]
AS
BEGIN
	BEGIN
	DECLARE @DatabaseName   	NVARCHAR(128),
			@Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vSql				NVARCHAR(1024)


	  DECLARE cDatabases CURSOR FAST_FORWARD FOR
		  SELECT [SD].[name]
		  FROM   [master].[dbo].[sysdatabases] SD with (NOLOCK)
		  WHERE  Lower([SD].[name]) NOT IN ( 'tempdb' )
				 AND [SD].[name] NOT IN (SELECT [MD].[DatabaseName]
										 FROM   [dbacorp_maintenance].[dbo].[MaintenanceDatabases] [MD] with (NOLOCK)) 
										 
		OPEN cDatabases
			FETCH NEXT FROM cDatabases INTO @DatabaseName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @ParameterName = ''
				SET @Parameters = ''
				SET @vCount = 0		
				SET @vSql = ''
			
				INSERT INTO [dbacorp_maintenance].[dbo].[MaintenanceDatabases]
							([DatabaseName])
					 VALUES (@DatabaseName)
					 
				/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
				DECLARE cParameters CURSOR FAST_FORWARD FOR
					SELECT [ParameterName], [Value]
					FROM   [MaintenanceParameters] with (NOLOCK)
					WHERE  [RoutineName] = 'DATABASES'
						   AND [DatabaseName] = 'ALL'
						     
				OPEN cParameters
				FETCH NEXT FROM cParameters INTO @ParameterName, @Value
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @vSql = 'UPDATE [dbo].[MaintenanceDatabases] '
								+ ' SET ['+@ParameterName+'] = '''+@Value+''''
								+ ' WHERE [DatabaseName] = '''+@DatabaseName+''''
					PRINT @vSql
					EXEC (@vSql)		
					FETCH NEXT FROM cParameters INTO @ParameterName, @Value			  
				END
				CLOSE cParameters
				DEALLOCATE cParameters
				/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/
				
				FETCH NEXT FROM cDatabases INTO @DatabaseName			
			END
		CLOSE cDatabases
		DEALLOCATE cDatabases	  
	      									 
	END
END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenancePurgeBackups]    Script Date: 05/15/2014 17:35:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspMaintenancePurgeBackups]
@DatabaseName   	NVARCHAR(128), @BackupType NVARCHAR(10), @Path NVARCHAR(1024), @ErrorIdPurge INT OUTPUT
AS
--EXEC [dbo].[uspMaintenancePurgeBackups] @DatabaseName = 'permissao', @BackupType = 'FULL', @Path = 'D:\bkp_sql\FULL\'
BEGIN
	BEGIN
	DECLARE @Parameters     	NVARCHAR(1024),
			@ParameterName  	NVARCHAR(128),
			@Value				NVARCHAR(1024),
			@vCount         	INT,
			@vSql				NVARCHAR(1024),
			@vCountParameters	INT,
			@vOldDate			NVARCHAR(20),
			@MSGError       	NVARCHAR(4000)

			SET @ParameterName = ''
			SET @Parameters = ''
			SET @vCount = 0		
			SET @vSql = ''
			SET @vCountParameters = 0

		CREATE TABLE #Tmp_MaintenanceParametersPurge
		(
				ParameterName	NVARCHAR(128)
				,Value	NVARCHAR(1024)	
		)
		
		SELECT @vCount = ISNULL(COUNT(*),0)
		FROM [dbo].[MaintenanceDatabases] with (NOLOCK)
		WHERE [DatabaseName] = @DatabaseName
			  AND [IndBackupPurge] = 'Y'
		
		IF (@vCount > 0)
		BEGIN
			SELECT @vCountParameters = 0
			
			SELECT @vCountParameters = ISNULL(COUNT(*),0)
			FROM   [MaintenanceParameters] with (NOLOCK)
			WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
				   AND [RoutineName] = 'BACKUPPURGE'
				   AND [DatabaseName] = @DatabaseName
		    
			TRUNCATE TABLE #Tmp_MaintenanceParametersPurge
		    
			IF (@vCountParameters <> 0)
			BEGIN
				INSERT INTO #Tmp_MaintenanceParametersPurge
					(
						[ParameterName]
						, [Value]
					)	    
				SELECT [ParameterName], [Value]
				FROM   [MaintenanceParameters]
				WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
					   AND [RoutineName] = 'BACKUPPURGE'			
					   AND [DatabaseName] = @DatabaseName	    
			END
			ELSE
			BEGIN
				INSERT INTO #Tmp_MaintenanceParametersPurge
					(
						[ParameterName]
						, [Value]
					)
				SELECT [ParameterName], [Value]
				FROM   [MaintenanceParameters] with (NOLOCK)
				WHERE  [ParameterName] = 'BACKUP' + @BackupType + ''
					   AND [RoutineName] = 'BACKUPPURGE'
					   AND [DatabaseName] = 'ALL'	    
			END
				
			/*-----INÍCIO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO-----*/
			DECLARE cParameters CURSOR FAST_FORWARD FOR
				SELECT [ParameterName], [Value]
				FROM   #Tmp_MaintenanceParametersPurge
					     
			OPEN cParameters
			FETCH NEXT FROM cParameters INTO @ParameterName, @Value
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					SET @vOldDate = REPLACE(CONVERT(NVARCHAR(20),Dateadd(n, -CONVERT(INT,@Value), GETDATE()),102),'.','-') + ' ' + CONVERT(NVARCHAR(20),Dateadd(n, -CONVERT(INT,@Value), GETDATE()),108)
					SET @vSql = '[master].[dbo].[xp_delete_file] 0,N'''+@Path+''',N''BKP'','''+@vOldDate+''',1'
					PRINT (@vSql)
					EXEC (@vSql)		
					
					SET @ErrorIdPurge = 0
				END TRY
				BEGIN CATCH
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'BACKUPPURGE',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = 3201,
					  @vErrorSeverity = 1,
					  @vErrorState = 1,
					  @vErrorProcedure = 'uspMaintenancePurgeBackups',
					  @vErrorMessage = 'Erro no procedimento de PURGE.'
					  
					SELECT @MSGError = 'Purge modo: ' + @BackupType + ' do banco '
								+ @DatabaseName + ' FALHOU as '
								+ CONVERT (VARCHAR, Getdate (), 120)
								+ ' - Erro: ' + 'Erro no procedimento de PURGE.'

					PRINT @MSGError										
					
					SET @ErrorIdPurge = 0
					
				END CATCH
				FETCH NEXT FROM cParameters INTO @ParameterName, @Value			  
			END
			
			CLOSE cParameters
			DEALLOCATE cParameters
			/*----TÉRMINO PREENCHIMENTO DE PARÂMETROS PARA CADA BANCO----*/

		RETURN isnull(@ErrorIdPurge,0)	
		      									 
		END
		
	END
	
	DROP TABLE #Tmp_MaintenanceParametersPurge	
END


GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceSyncLoginsAlwaysOn]    Script Date: 05/15/2014 17:35:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspMaintenanceSyncLoginsAlwaysOn]
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #Logins
	(
		loginId int IDENTITY(1, 1) NOT NULL,
		loginName nvarchar(128) NOT NULL,
		passwordHash varbinary(256) NULL,
		default_database_name nvarchar(128) NULL,
		sid varbinary(85) NOT NULL
	)

	-- openquery is used so that loginproperty function runs on the remote server,
	-- otherwise we get back null
	INSERT INTO #Logins(loginName, passwordHash, sid, default_database_name)
	select * from #Logins
	--SELECT *
	--FROM OPENQUERY([DBACORP-NOTE28\SQL2012], '
	--SELECT name, CONVERT(varbinary(256), LOGINPROPERTY(name, ''PasswordHash'')), sid, default_database_name
	--FROM master.sys.server_principals
	--WHERE
	--	type = ''S'' AND 
	--	name NOT IN (''sa'', ''guest'',''##MS_PolicyEventProcessingLogin##'',''usr_alwayson'') AND
	--	create_date >= ''01/05/2014''
	--ORDER BY name')

	DECLARE 
		@count int, @loginId int, @loginName nvarchar(128), 
		@passwordHashOld varbinary(256), @passwordHashNew varbinary(256), 
		@SID_varbinary varbinary(85), @sql nvarchar(4000), @password varchar(514), @default_database_name nvarchar(128), @SID_string varchar (514)

	SELECT @loginId = 1, @count = COUNT(*)
	FROM #Logins

	WHILE @loginId <= @count
	BEGIN
		SELECT @loginName = loginName, @passwordHashNew = passwordHash, @SID_varbinary = sid, @default_database_name = default_database_name
		FROM #Logins
		WHERE loginId = @loginId

		-- if the account doesn't exist, then we need to create it
		IF NOT EXISTS (SELECT * FROM master.sys.server_principals WHERE name = @loginName)
		BEGIN
			EXEC master.dbo.sp_hexadecimal @passwordHashNew, @password OUTPUT
			EXEC master.dbo.sp_hexadecimal @SID_varbinary,@SID_string OUT

			SET @sql = 'CREATE LOGIN ' + @loginName + ' WITH PASSWORD = '
			SET @sql = @sql + CONVERT(nvarchar(512), COALESCE(@password, 'NULL')) 
			SET @sql = @sql + ' HASHED , SID = ' + CONVERT(nvarchar(512), @SID_string)
			SET @sql = @sql + ' , DEFAULT_DATABASE = [' + @default_database_name + ']'
			SET @sql = @sql + ' , CHECK_POLICY = OFF' 
			PRINT @sql
			EXEC (@sql)

			PRINT 'login created'
		END
		-- if the account does exist, then we need to drop/create to sync the password;
		-- can't alter as hashed isn't supported
		ELSE
		BEGIN
			SELECT @passwordHashOld = CONVERT(varbinary(256), LOGINPROPERTY(@loginName, 'PasswordHash'))

			-- only bother updating if the password has changed since the last sync
			IF @passwordHashOld <> @passwordHashNew
			BEGIN
				EXEC master.dbo.sp_hexadecimal @passwordHashNew, @password OUTPUT

				--SET @sql = 'DROP LOGIN ' + @loginName
				--PRINT @sql
				--EXEC (@sql)

				SET @sql = 'ALTER LOGIN ' + @loginName + ' WITH PASSWORD = '
				SET @sql = @sql + CONVERT(nvarchar(512), COALESCE(@password, 'NULL'))
				SET @sql = @sql + ' HASHED, CHECK_POLICY = OFF' 
				PRINT @sql
				EXEC (@sql)

				PRINT 'login "altered"'
			END
		END

		SET @loginId = @loginId + 1
	END

	DROP TABLE #Logins

END

GO

USE [dbacorp_maintenance]
GO

/****** Object:  StoredProcedure [dbo].[uspMaintenanceUpdateStatsFull]    Script Date: 05/15/2014 17:35:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspMaintenanceUpdateStatsFull]
AS  
BEGIN
SET NOCOUNT ON
/***************************************************************/

/***************************************************************/

	/*--------------INÍCIO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	DECLARE 
			@databasename               NVARCHAR(128),
			@vSql                       NVARCHAR(4000),
			@vDateRoutineStart			DATETIME,
			@vDateRoutineFinish			DATETIME,
			@vRoutineTimeId				INT,
			@vCount         			INT,
			@vErrorProcedure			NVARCHAR(200),
			@vRoutineName   			NVARCHAR(128),
			@vErrorNumber   			INT,
			@vErrorSeverity 			INT,
			@vErrorState    			INT,
			@vErrorLine     			INT,
			@vErrorMessage  			NVARCHAR(4000),
			@vErrorCount				INT,
			@vErrorCountAux				INT,
			@command					NVARCHAR(4000),
			@MSGError       			NVARCHAR(4000)


	/*-------------TÉRMINO DECLARAÇÃO DE VARIÁVEIS-----------------*/
	SELECT @vDateRoutineStart = GETDATE()
	
	INSERT INTO [dbo].[MaintenanceRoutineTimes]
				([RoutineName],
				 [StartTime])
	VALUES      ('UpdateStatsFull',
				 @vDateRoutineStart) 

	SELECT @vRoutineTimeId = SCOPE_IDENTITY()
	SELECT @vErrorCount = 0
	      
      DECLARE v_databases CURSOR FAST_FORWARD FOR
        SELECT [SD].[name]
        FROM   [master].[dbo].[sysdatabases]  SD WITH (nolock)
			   INNER JOIN [dbo].[MaintenanceDatabases] MD
				ON [SD].[dbid] = DB_ID([MD].[DatabaseName])
        WHERE  [SD].[dbid] > 4
               AND Databasepropertyex ([SD].[name] , 'STATUS' ) = 'ONLINE'
               AND [MD].[IndUpdateStatsFull] = 'Y'	
			   AND Databasepropertyex ([SD].[name] , 'UPDATEABILITY' ) = 'READ_WRITE'
               
      OPEN v_databases;
      WHILE ( 1 = 1 )
        BEGIN;
            FETCH NEXT FROM v_databases INTO @databasename
            IF @@FETCH_STATUS < 0
              BREAK;
          
		  SET @command = 'EXEC ['+@databasename+'].dbo.sp_msForEachTable ''UPDATE STATISTICS ? WITH FULLSCAN'''

		  PRINT N'Executing: ' + @command;

		  BEGIN TRY
			EXEC (@command);
		  END TRY
                BEGIN CATCH
                    /*---------------INÍCIO TRATAMENTO DE ERRORS-----------------*/
                    SELECT @vErrorNumber = Error_number()
                           ,@vErrorSeverity = Error_severity()
                           ,@vErrorState = Error_state()
                           ,@vErrorLine = Error_line()
                           ,@vErrorMessage = Error_message()
                           
					EXEC [dbo].[uspMaintenanceErrorControl]
					  @vRoutineName = 'UpdateStatsFull',
					  @vDatabaseName = @DatabaseName,
					  @vTableName = '',
					  @vErrorNumber = @vErrorNumber,
					  @vErrorSeverity = @vErrorSeverity,
					  @vErrorState = @vErrorState,
					  @vErrorLine = @vErrorLine,                  
					  @vErrorProcedure = @vErrorProcedure,
					  @vErrorMessage = @vErrorMessage
					
					SELECT @MSGError = 'UpdateStatsFull do banco '
										+ @DatabaseName + ' FALHOU as '
										+ CONVERT (VARCHAR, Getdate (), 120)
										+ ' - Erro: '+@vErrorMessage
                    PRINT @MSGError
                    
					SELECT @vErrorCount = 1
                    /*---------------TÉRMINO TRATAMENTO DE ERRORS----------------*/
                END CATCH
		  PRINT N'Executed: ' + @command;

        END
      CLOSE v_databases
      DEALLOCATE v_databases

	SELECT @vDateRoutineFinish = GETDATE()

	UPDATE [dbo].[MaintenanceRoutineTimes]
	SET    [EndTime] = @vDateRoutineFinish
	WHERE  [RoutineId] = @vRoutineTimeId 

	IF (@vErrorCount <> 0)
	BEGIN
		RAISERROR ('Rotina de UpdateStatsFull finalizada com falhas.',16,1) WITH LOG
	END
	ELSE
	BEGIN
		PRINT ('Rotina de UpdateStatsFull finalizada com sucesso.')
	END
  
  END


GO

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
