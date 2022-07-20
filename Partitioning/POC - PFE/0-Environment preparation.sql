--=========================================================
-- Database Creation
--=========================================================
USE MASTER
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'PARTDB')
         DROP DATABASE  PARTDB
GO
 CREATE DATABASE PARTDB ON PRIMARY
( NAME = N'PARTDB_Principal', FILENAME = N'C:\DB\PARTDB\PARTDB_Principal.mdf',SIZE = 25MB, FILEGROWTH = 25MB)
,FILEGROUP [PARTDB_Group1]
( NAME = N'PARTDB_Group1', FILENAME = N'C:\DB\PARTDB\PARTDB_Group1.ndf',SIZE = 25MB, FILEGROWTH = 25MB )
,FILEGROUP [PARTDB_Group2]
( NAME = N'PARTDB_Group2', FILENAME = N'C:\DB\PARTDB\PARTDB_Group2.ndf',SIZE = 25MB, FILEGROWTH = 25MB )
,FILEGROUP [PARTDB_Group3]
( NAME = N'PARTDB_Group3', FILENAME = N'C:\DB\PARTDB\PARTDB_Group3.ndf',SIZE = 25MB, FILEGROWTH = 25MB )
,FILEGROUP [PARTDB_Group4]
( NAME = N'PARTDB_Group4', FILENAME = N'C:\DB\PARTDB\PARTDB_Group4.ndf',SIZE = 25MB, FILEGROWTH = 25MB )
 LOG ON
( NAME = N'PARTDB_log', FILENAME = N'C:\DB\PARTDB\PARTDB_log.ldf',SIZE = 25MB, FILEGROWTH = 25MB)
GO

--=========================================================
-- TABLE [SALES] CREATION
--=========================================================
USE PARTDB
GO

IF OBJECT_ID('dbo.SALES', 'U') IS NOT NULL 
  DROP TABLE dbo.SALES; 
GO

CREATE TABLE [PARTDB].[DBO].[Sales](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL ) ON [PARTDB_Group1]
GO
--=========================================================
-- SALES TABLE DATA LOAD
--=========================================================
DECLARE @LOOP INT = 0;
DECLARE @SalesOrderID INT;
DECLARE @OrderQty INT;
DECLARE @Upper INT;
DECLARE @Lower INT;
DECLARE @date_from AS DATETIME
DECLARE @date_to AS DATETIME
DECLARE @days_diff AS INT 

SELECT @SalesOrderID = ISNULL(MAX(SalesOrderID),0) FROM [PARTDB].[DBO].[Sales];

WHILE @LOOP < 100000
BEGIN
	SET @LOOP = @LOOP+1;
	SET @SalesOrderID = @SalesOrderID +1
	SET @Upper = 20;
	SET @Lower = 1;
	SET @date_from  = '2015-01-01';
	SET @date_to = '2018-04-17';
	SET @days_diff = cast(@date_to - @date_from AS INT);

	SET @date_from = @date_from +
		DATEADD(second, ABS(CHECKSUM(newid()) % 60), 0) + -- random seconds
		DATEADD(minute, ABS(CHECKSUM(newid()) % 60), 0) + -- random minutes
		DATEADD(hour, ABS(CHECKSUM(newid()) % 24), 0) + -- random hours
		DATEADD(day, ABS(CHECKSUM(newid()) % @days_diff), 0) -- random days

	SET @OrderQty = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

	INSERT INTO [PARTDB].[DBO].[Sales] VALUES (@SalesOrderID, @date_from,@OrderQty,	@OrderQty*15)
END

ALTER TABLE  PARTDB.dbo.Sales  ADD CONSTRAINT PK_SALES PRIMARY KEY CLUSTERED ([OrderDate], [SalesOrderID]) ON PARTDB_Group1;
GO
