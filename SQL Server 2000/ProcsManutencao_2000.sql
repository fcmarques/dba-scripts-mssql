/* ProceduresManutencao (Stefano Takamatsu Gioia)

	Executa manutenções de sistema
	Versão SQLServer 7 / 2000
	
	CreateDate: 10/02/2011 
	UpdateDate: 16/07/2012

	Exemplos:
	-----------------------------------------------------------
	EXEC [dbo].[sp_Manutencao]			
		Verifica se há disparidade entre o catálogo de sistema e o repositório e faz a atualização	

	EXEC [dbo].[sp_ManutencaoBackup]	@Tip_Backup = 'FULL'
		Executa Backup 'FULL'', Backup 'DIFF' ou Backup 'LOG'

	EXEC [dbo].[sp_ManutencaoReindex]
		Executa Reindex
		
	EXEC [dbo].[sp_ManutencaoExpurgo]	@Tempo_Exp = 24, @Tip_Expurgo = 'DIFF'
		Executa deleção de todos arquivos do tipo 'FULL', 'DIFF' ou 'LOG' na respectiva pasta de backups
		Obs: @Tempo_Exp deleta todos backups com recência de 24 horas OU MAIS (default)

	EXEC [sp_ManutencaoUpdStats] @Tip_UpdStats = 'FULL'
		Executa Update Statistics nos bancos assinalados pelo repositório. 'FULL' para FULLSCAN ou vazio para default
		
	EXEC [sp_ManutencaoCheckDB]
		Executa CheckDB nos bancos assinalados pelo repositório
		
*/  

IF NOT EXISTS (SELECT TOP 1 1 FROM master..sysdatabases WHERE name = 'dbdba')
CREATE DATABASE dbdba
GO

USE dbdba
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'DBA_ManutBancos')
BEGIN
	CREATE TABLE [dbo].[DBA_ManutBancos]	(
		[Banco]					[varchar](100)		   NOT NULL ,
		[Ind_BackupFull]		[char]	 (001)		NOT NULL ,
		[Ind_BackupDiff]		[char]	 (001)		NOT NULL ,
		[Ind_BackupLog]		[char]	 (001)		NOT NULL ,
		[Ind_Rebuild]			[char]	 (001)		NOT NULL ,
		[Ind_UpdStats]			[char]	 (001)		NOT NULL ,
		[Ind_CheckDB]			[char]	 (001)		NOT NULL
		CONSTRAINT [PK_DBA_ManutBancos] PRIMARY KEY CLUSTERED (Banco) 
												)
	INSERT INTO [dbo].[DBA_ManutBancos]  
			SELECT name, 'S',	CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END, 
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE (CASE WHEN DATABASEPROPERTYEX (name, 'Recovery') = 'FULL' THEN 'S'
													    ELSE 'N'	END)	END, 
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END,
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END, 'S'    
		FROM master..sysdatabases   
			WITH (NOLOCK)  
		WHERE  DATABASEPROPERTYEX (name, 'Status') = 'ONLINE'   
			AND DATABASEPROPERTYEX (name, 'Updateability') = 'READ_WRITE'   
	      AND name NOT IN ('TempDB', 'AdventureWorks', 'Northwind')   
END	
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'DBA_CaminhoBKP')
BEGIN
	CREATE TABLE [dbo].[DBA_CaminhoBKP]	(
		[Caminho_BKPFull]			[varchar](100)		NOT NULL,
		[Caminho_BKPDiff]			[varchar](100)		NOT NULL,
		[Caminho_BKPLogs]			[varchar](100)		NOT NULL	
		CONSTRAINT [PK_DBA_CaminhoBKP] PRIMARY KEY CLUSTERED (Caminho_BKPFull, Caminho_BKPDiff, Caminho_BKPLogs) 
												     )
	PRINT 'ATENÇÃO: FAZER UPDATE NA TABELA [DBA_CaminhoBKP] COM O CAMINHO DO BACKUP' 
END	
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_Manutencao' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_Manutencao]
GO

CREATE PROCEDURE [dbo].[sp_Manutencao]  
	AS  
	BEGIN   
		
		SET NOCOUNT ON		
		-- Verifica se o repositorio de bancos está atualizado
		IF NOT EXISTS (SELECT count (1)
						FROM   (SELECT Banco 
									FROM [dbdba].[dbo].[DBA_ManutBancos] 
										UNION ALL   
								  SELECT name 
									FROM master..sysdatabases
									WHERE  DATABASEPROPERTYEX (name, 'Status') = 'ONLINE'   
										AND DATABASEPROPERTYEX (name, 'Updateability') = 'READ_WRITE'   
										AND name NOT IN ('TempDB', 'AdventureWorks', 'Northwind')) a
						GROUP BY Banco HAVING count(*)!=2)
		BEGIN  
			PRINT 'Repositório de bancos atualizado. ' + convert (varchar, getdate (), 120)  
			PRINT '========================================================================'  
		END  
		ELSE  
		BEGIN   
			PRINT 'Repositório de bancos DESATUALIZADO.' + convert (varchar, getdate (), 120)  
			PRINT '========================================================================'  

			SELECT tm.*  
				INTO #tm1  
				FROM [dbdba].[dbo].[DBA_ManutBancos] tm  
					WITH (NOLOCK)  

			TRUNCATE TABLE [dbdba].[dbo].[DBA_ManutBancos]	  

			INSERT INTO [dbdba].[dbo].[DBA_ManutBancos]  
			SELECT name, 'S',	CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END, 
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE (CASE WHEN DATABASEPROPERTYEX (name, 'Recovery') = 'FULL' THEN 'S'
													    ELSE 'N'	END)	END, 
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END,
									CASE WHEN name IN ('master', 'model', 'msdb', 'dbdba') THEN 'N'
										  ELSE 'S'	END, 'S'    
				FROM master..sysdatabases 
					WITH (NOLOCK)  
				WHERE DATABASEPROPERTYEX (name, 'Status') = 'ONLINE'   
				AND name NOT IN ('TempDB', 'AdventureWorks', 'Northwind')   

			UPDATE mb  
			SET mb.Banco			= tm.Banco,  
				mb.Ind_BackupFull	= tm.Ind_BackupFull,  
				mb.Ind_BackupDiff	= tm.Ind_BackupDiff,  
				mb.Ind_BackupLog	= tm.Ind_BackupLog,  
				mb.Ind_Rebuild		= tm.Ind_Rebuild,  
				mb.Ind_UpdStats	= tm.Ind_UpdStats,
				mb.Ind_CheckDB		= tm.Ind_CheckDB
			FROM [dbdba].[dbo].[DBA_ManutBancos] mb  
			INNER JOIN #tm1 tm  
					WITH (NOLOCK)  
				ON mb.Banco = tm.Banco  

		IF @@ERROR = 0 
		BEGIN
			PRINT 'Repositório ATUALIZADO.'  
			PRINT '========================================================================'  
			PRINT 'Caso novos bancos tenham sido adicionados recentemente ao servidor,'  
			PRINT 'favor verificar se estes devem ter os parâmetros customizados'
			PRINT 'na tabela [dbdba].[dbo].[DBA_ManutBancos]'
			PRINT '========================================================================'
		END
		ELSE
		BEGIN
			PRINT 'Atualização do repositório de bancos falhou as ' +  convert (varchar, getdate (), 120) 
			PRINT '========================================================================'  			
			RAISERROR ('Atualização do repositório de bancos falhou', 16, 1) WITH LOG
		END  
		END
  
	END  
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_ManutencaoBackup' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_ManutencaoBackup]
GO

CREATE PROCEDURE [dbo].[sp_ManutencaoBackup]
	@Tip_Backup		varchar (010)
	AS  
	BEGIN 		

		SET NOCOUNT ON

		DECLARE  @Banco			varchar (100),   
					@Tabela			varchar (100),  
					@Caminho			varchar (100),  
					@CaminhoArq		varchar (100),   
					@Data				varchar (100),
					@MSGErro			varchar (1000)

		SELECT @Caminho = cb.Caminho_BKPFull   
			FROM [dbdba].[dbo].[DBA_CaminhoBKP] cb   
				WITH (NOLOCK)  

		SELECT @Data	  = convert (varchar, getdate (), 112)

		DECLARE cBancos CURSOR FOR    
		SELECT mb.Banco   
			FROM [dbdba].[dbo].[DBA_ManutBancos] mb  
				WITH (NOLOCK)
			WHERE (CASE WHEN @Tip_Backup = 'FULL' THEN Ind_BackupFull  
						WHEN @Tip_Backup = 'DIFF' THEN Ind_BackupDiff
						WHEN @Tip_Backup = 'LOG'  THEN Ind_BackupLog
					END) = 'S'

		OPEN cBancos     
		FETCH NEXT FROM cBancos INTO @Banco    

		WHILE @@FETCH_STATUS = 0     
		BEGIN     
			PRINT 'Backup modo: ' + @Tip_Backup + ' do banco ' + @Banco + ' iniciou as ' +  convert (varchar, getdate (), 120)			

			SELECT @CaminhoArq = @Caminho + @Banco + '_' + @Tip_Backup + '_' + @Data + '.BKP'    

			IF @Tip_Backup = 'FULL'
			BEGIN
				BACKUP DATABASE @Banco TO DISK = @CaminhoArq   
			END

			IF @Tip_Backup = 'DIFF'
			BEGIN
				BACKUP DATABASE @Banco TO DISK = @CaminhoArq WITH DIFFERENTIAL   
			END

			IF @Tip_Backup = 'LOG'
			BEGIN
				BACKUP LOG @Banco TO DISK = @CaminhoArq   
			END
	
			IF @@ERROR = 0 
			BEGIN
			PRINT 'Backup modo: ' + @Tip_Backup + ' do banco ' + @Banco + ' FINALIZADO as ' +  convert (varchar, getdate (), 120)			
			END
			ELSE
			BEGIN
			SELECT @MSGErro = 'Backup modo: ' + @Tip_Backup + ' do banco ' + @Banco + ' FALHOU as ' +  convert (varchar, getdate (), 120)
			PRINT 'Backup modo: ' + @Tip_Backup + ' do banco ' + @Banco + ' FALHOU as ' +  convert (varchar, getdate (), 120)
			RAISERROR (@MSGErro, 16, 1) WITH LOG
			END

			FETCH NEXT FROM cBancos INTO @Banco 
		END     

		CLOSE cBancos     
		DEALLOCATE cBancos   

	END  
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_ManutencaoReindex' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_ManutencaoReindex]
GO

CREATE  PROCEDURE [dbo].[sp_ManutencaoReindex]
	AS  
	BEGIN
		SET NOCOUNT ON
		
		DECLARE @SQL nvarchar(4000)
		SET @SQL = ''

		SELECT @SQL = @SQL + 'EXEC ' + '[' + mb.Banco + ']' + '..sp_MSforeachtable @command1=''DBCC DBREINDEX (''''*'''')'', @replacechar=''*''' + char (13)
		FROM [dbdba].[dbo].[DBA_ManutBancos] mb  
			WITH (NOLOCK)
		WHERE Ind_Rebuild = 'S'

		EXEC (@SQL)
	END  
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_ManutencaoExpurgo' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_ManutencaoExpurgo]
GO

CREATE PROCEDURE [dbo].[sp_ManutencaoExpurgo]
	@Tempo_Exp		int				= 24,
	@Tip_Expurgo	varchar (010)
	AS  
	BEGIN 		

		SET NOCOUNT ON
		DECLARE @Counter          	int           ,
				@CurrentName      	varchar (256) ,
				@DirTreeCount     	int           ,
				@IsFile           	bit           ,
				@ObjFile          	int           ,
				@ObjFileSystem    	int           ,
				@Attributes       	int           ,
				@DateCreated      	datetime      ,
				@DateLastAccessed 	datetime      ,
				@DateLastModified 	datetime      ,
				@Name             	varchar	(0128),
				@Path             	varchar	(0128),
				@ShortName        	varchar	(0012),
				@ShortPath        	varchar	(0100),
				@Size             	int           ,
				@Type             	varchar	(0100),
				@Cmd1						varchar (4000),
				@CaminhoBKP				varchar (4000),
				@Arquivo					varchar (0100),				  
				@MSGErro					varchar (1000)
				

		SELECT @CaminhoBKP = (CASE WHEN @Tip_Expurgo = 'FULL' THEN Caminho_BKPFull  
											WHEN @Tip_Expurgo = 'DIFF' THEN Caminho_BKPDiff
											WHEN @Tip_Expurgo = 'LOG'  THEN Caminho_BKPLogs
										END)
			FROM [dbdba].[dbo].[DBA_CaminhoBKP]
				WITH (NOLOCK)


		IF OBJECT_ID('TempDB..#DirTree','U') IS NOT NULL
			DROP TABLE #DirTree

		CREATE TABLE #DirTree (
			RowNum INT IDENTITY (1,1),
			Name   VARCHAR (256) PRIMARY KEY CLUSTERED, 
			Depth  BIT, 
			IsFile BIT			)

		IF OBJECT_ID('TempDB..#FileDetails','U') IS NOT NULL
			DROP TABLE #FileDetails

		CREATE TABLE #FileDetails (
			RowNum           INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
			Name             VARCHAR(128), 
			Path             VARCHAR(128), 
			ShortName        VARCHAR(12),  
			ShortPath        VARCHAR(100), 
			DateCreated      DATETIME,     
			DateLastAccessed DATETIME,     
			DateLastModified DATETIME,     
			Attributes       INT,          
			ArchiveBit       AS CASE WHEN Attributes&  32=32   THEN 1 ELSE 0 END,
			CompressedBit    AS CASE WHEN Attributes&2048=2048 THEN 1 ELSE 0 END,
			ReadOnlyBit      AS CASE WHEN Attributes&   1=1    THEN 1 ELSE 0 END,
			Size             INT,          
			Type             VARCHAR(100)  )

		SELECT @CaminhoBKP = @CaminhoBKP+'\'
			WHERE RIGHT(@CaminhoBKP,1)<>'\'

		INSERT INTO #DirTree (Name, Depth, IsFile)
			EXEC master..xp_DirTree @CaminhoBKP,1,1 -- Current diretory only, list file names

		SET @DirTreeCount = @@ROWCOUNT

		UPDATE #DirTree
			SET Name = @CaminhoBKP + Name

		EXEC dbo.sp_OACreate 'Scripting.FileSystemObject', @ObjFileSystem OUT

		SET @Counter = 1
		WHILE @Counter <= @DirTreeCount
		BEGIN
			 SELECT @CurrentName = Name,
					@IsFile = IsFile
			   FROM #DirTree 
			  WHERE RowNum = @Counter
		    
		 IF @IsFile = 1 AND @CurrentName LIKE '%%'
			BEGIN
				EXEC dbo.sp_OAMethod @ObjFileSystem,'GetFile', @ObjFile OUT, @CurrentName
				EXEC dbo.sp_OAGetProperty @ObjFile, 'Path',             @Path             OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'ShortPath',        @ShortPath        OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'Name',             @Name             OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'ShortName',        @ShortName        OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'DateCreated',      @DateCreated      OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastAccessed', @DateLastAccessed OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastModified', @DateLastModified OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'Attributes',       @Attributes       OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'Size',             @Size             OUT
				EXEC dbo.sp_OAGetProperty @ObjFile, 'Type',             @Type             OUT

				INSERT INTO #FileDetails
					(Path, ShortPath, Name, ShortName, DateCreated, 
					 DateLastAccessed, DateLastModified, Attributes, Size, Type)
				SELECT  @Path,@ShortPath,@Name,@ShortName,@DateCreated, 
						@DateLastAccessed,@DateLastModified,@Attributes,@Size,@Type
			END
	        
			 SELECT @Counter = @Counter + 1
		END

		EXEC sp_OADestroy @ObjFileSystem
		EXEC sp_OADestroy @ObjFile
		
		PRINT 'Arquivos à serem apagados:'

		SELECT convert (varchar (50), Name) 'Arquivo', 
			    DateCreated							'Data de criação', 
			    Size / 1024 / 1024				'Tamanho (MB)' 
			FROM #FileDetails
			WHERE datediff (hour, DateCreated, getdate ()) >= @Tempo_Exp
			GROUP BY  convert (varchar (50), Name), 
						 DateCreated, 
						 Size / 1024 / 1024

		DECLARE cDeletes CURSOR FOR    
		SELECT DISTINCT Name
			FROM #FileDetails
			WHERE datediff (hour, DateCreated, getdate ()) >= @Tempo_Exp

		OPEN cDeletes     
		FETCH NEXT FROM cDeletes INTO @Arquivo     

		WHILE @@FETCH_STATUS = 0     
		BEGIN     
			SELECT  @Cmd1 = 'master..xp_cmdshell ''DEL ' + @CaminhoBKP + @Arquivo + ''''
			EXEC   (@Cmd1)

			FETCH NEXT FROM cDeletes INTO @Arquivo    
		END     

		CLOSE cDeletes     
		DEALLOCATE cDeletes    

		PRINT 'Expurgo de backups ' + @Tip_Expurgo + ' FINALIZOU as: ' + convert (varchar, getdate (), 120)

	END
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_ManutencaoUpdStats' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_ManutencaoUpdStats]
GO

CREATE  PROCEDURE [dbo].[sp_ManutencaoUpdStats]
	@Tip_UpdStats		varchar (010)
	AS  
	BEGIN
		SET NOCOUNT ON

		DECLARE @SQL nvarchar(4000)
		SET	  @SQL = ''

		SELECT 'EXEC ' + '[' + mb.Banco + ']' +  '..sp_MSforeachtable @command1=''UPDATE STATISTICS * ' + 
				 coalesce ((CASE WHEN @Tip_UpdStats = 'FULL' THEN 'WITH FULLSCAN' END), '') + ''', @replacechar=''*''' + char (13)
				FROM [dbdba].[dbo].[DBA_ManutBancos] mb  
					WITH (NOLOCK)
				WHERE Ind_UpdStats = 'S'
				
		EXEC (@SQL)	
	END  
GO

IF EXISTS (SELECT TOP 1 1 FROM dbdba..sysobjects WHERE name = 'sp_ManutencaoCheckDB' AND xtype = 'P')
DROP PROCEDURE [dbo].[sp_ManutencaoCheckDB]
GO

CREATE  PROCEDURE [dbo].[sp_ManutencaoCheckDB]
	AS  
	BEGIN
		SET NOCOUNT ON
		
		DECLARE @SQL nvarchar(4000)

		SET @SQL = ''

		SELECT @SQL = @SQL + 'DBCC CHECKDB ([' + mb.Banco  + ']) WITH ALL_ERRORMSGS, NO_INFOMSGS' + char (13)
					FROM [dbdba].[dbo].[DBA_ManutBancos] mb  
						WITH (NOLOCK)
					WHERE Ind_CheckDB = 'S'
		EXEC (@SQL)
	END  
GO
