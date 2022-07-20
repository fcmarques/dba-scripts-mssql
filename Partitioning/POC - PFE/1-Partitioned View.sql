--=========================================================
-- DATA DISTRIBUTION
--=========================================================
SELECT * FROM [PARTDB].[DBO].[Sales]

Select Year([OrderDate])   AS [YEAR], COUNT(*) [Total]
From [PARTDB].[DBO].[Sales]
Group by YEAR([OrderDate]) ORDER BY YEAR([OrderDate]) DESC

--=========================================================
--  Adding new filegroups
--=========================================================
USE MASTER;
GO

--Create and add a FILEGROUP to the PARTDB Database
ALTER DATABASE PARTDB
ADD FILEGROUP PARTDB_Staging 
GO

ALTER DATABASE PARTDB
ADD FILE
(NAME = N'PARTDB_Staging', FILENAME = N'C:\DB\PARTDB\PARTDB_Staging.ndf',SIZE = 25MB, FILEGROWTH = 25MB)
TO FILEGROUP PARTDB_Staging
GO

--=========================================================
-- CREATE TABLE SALES_15 - PARTITION VIEW DEMO
--=========================================================
USE PARTDB
GO

IF OBJECT_ID('dbo.SALES_15', 'U') IS NOT NULL 
  DROP TABLE dbo.SALES_15; 
GO

CREATE TABLE [PARTDB].[DBO].[Sales_15](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT SALES2015DtChk CHECK(OrderDate >='2015-01-01' AND OrderDate < '2016-01-01'),
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL )
 ON PARTDB_Staging
GO

-- DATA LOAD 15
INSERT INTO PARTDB.dbo.Sales_15 
SELECT * FROM PARTDB.dbo.Sales WHERE OrderDate >='2015-01-01' AND OrderDate < '2016-01-01'

SELECT * FROM  PARTDB.dbo.Sales_15 
GO
SP_HELP [SALES_15]
-- INDEX CREATION 15
ALTER TABLE  PARTDB.dbo.Sales_15  ADD CONSTRAINT PK_SALES_15 PRIMARY KEY CLUSTERED ([OrderDate], [SalesOrderID]) ON PARTDB_Group2;
GO
SP_HELP [SALES_15]

--=========================================================
-- CREATE TABLE SALES_16 - PARTITION VIEW DEMO
--=========================================================
IF OBJECT_ID('dbo.SALES_16', 'U') IS NOT NULL 
  DROP TABLE dbo.SALES_16; 
GO
CREATE TABLE [PARTDB].[DBO].[Sales_16](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT SALES2016DtChk CHECK(OrderDate >='2016-01-01' AND OrderDate < '2017-01-01'),
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL )
 ON PARTDB_Staging
GO

-- DATA LOAD 16
INSERT INTO PARTDB.dbo.Sales_16 
SELECT * FROM PARTDB.dbo.Sales WHERE OrderDate >='2016-01-01' AND OrderDate < '2017-01-01'

SELECT * FROM  PARTDB.dbo.Sales_16 
GO
SP_HELP [SALES_16]
-- INDEX CREATION 16
ALTER TABLE  PARTDB.dbo.Sales_16  ADD CONSTRAINT PK_SALES_16 PRIMARY KEY CLUSTERED ([OrderDate], [SalesOrderID]) ON PARTDB_Group3;
GO
SP_HELP [SALES_16]

--=========================================================
-- CREATE TABLE SALES_17 - PARTITION VIEW DEMO
--=========================================================
IF OBJECT_ID('dbo.SALES_17', 'U') IS NOT NULL 
  DROP TABLE dbo.SALES_17; 
GO
CREATE TABLE [PARTDB].[DBO].[Sales_17](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT SALES2017DtChk CHECK(OrderDate >='2017-01-01' AND OrderDate < '2017-08-10'),
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL )
 ON PARTDB_Staging
GO

-- DATA LOAD 17
INSERT INTO PARTDB.dbo.Sales_17 
SELECT * FROM PARTDB.dbo.Sales WHERE OrderDate >='2017-01-01' AND OrderDate < '2017-08-10'

SELECT * FROM  PARTDB.dbo.Sales_17 
GO
SP_HELP [SALES_17]
-- INDEX CREATION 17
ALTER TABLE  PARTDB.dbo.Sales_17  ADD CONSTRAINT PK_SALES_17 PRIMARY KEY CLUSTERED ([OrderDate], [SalesOrderID]) ON PARTDB_Group4;
GO
SP_HELP [SALES_17]


--=========================================================
-- CREATE VIEW - PARTITION VIEW DEMO
--=========================================================
IF OBJECT_ID('dbo.SALES_V', 'V') IS NOT NULL 
  DROP VIEW dbo.SALES_V; 
GO
CREATE VIEW DBO.SALES_V
AS
	SELECT * FROM Sales_15
	UNION ALL
	SELECT * FROM Sales_16
	UNION ALL
	SELECT * FROM Sales_17
GO

-- SHOW EXECUTION PLAN DIFFERENCES (TIME)
SELECT * FROM PARTDB.dbo.SALES_V ORDER BY SalesOrderID

SELECT * FROM PARTDB.dbo.SALES


--=========================================================
-- BACKUP
--=========================================================

BACKUP DATABASE PARTDB TO DISK = 'C:\DB\PARTDB.bak' WITH INIT, STATS = 10

--=========================================================
-- Partition Elimination -- SHOW EXECUTION PLAN
--=========================================================
SET STATISTICS IO ON
GO  
SELECT * FROM PARTDB.dbo.SALES_V WHERE OrderDate >= '2017-01-01' AND OrderDate < '2017-01-02'
GO  
SET STATISTICS IO OFF
GO
--=========================================================
-- UPDATE VIEW - PARTITION VIEW DEMO
--=========================================================
UPDATE PARTDB.dbo.SALES_V
	SET  OrderQty = 10
	WHERE
		OrderDate > '2017-04-10'