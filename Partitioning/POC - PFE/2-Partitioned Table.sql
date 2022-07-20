
--=========================================================
-- PARTITION FUNCTION - PARTITION TABLE DEMO
--=========================================================
CREATE PARTITION FUNCTION SalesPerYearPFN (datetime)
AS
	RANGE RIGHT FOR VALUES ('20150101','20160101','20170101')
GO

--=========================================================
-- PARTITION SCHEME - PARTITION TABLE DEMO
--=========================================================
CREATE PARTITION SCHEME [SalesPerYearPS]
AS
PARTITION [SalesPerYearPFN] TO
( [PARTDB_Group1], [PARTDB_Group2], [PARTDB_Group3], [PARTDB_Group4])
GO

--=========================================================
-- TABLE CREATION - PARTITION TABLE DEMO
--=========================================================
IF OBJECT_ID('dbo.SALES_Part', 'U') IS NOT NULL 
  DROP TABLE PARTDB.dbo.SALES_Part; 
GO
CREATE TABLE [PARTDB].[DBO].[Sales_Part](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL ) ON [PARTDB_Group1]
GO
--=========================================================
-- DATA LOAD SALES_PART
--=========================================================
INSERT INTO PARTDB.dbo.Sales_Part
SELECT * FROM PARTDB.dbo.Sales;

SELECT * FROM PARTDB.dbo.Sales_Part;
--=========================================================
-- Partition Elimination - Table (SHOW EXECUTION PLAN)
--=========================================================
--DBCC DROPCLEANBUFFERS()
--DBCC FREEPROCCACHE()

SELECT * FROM PARTDB.dbo.Sales_Part WHERE OrderDate >= '2017-01-01' AND OrderDate < '2017-01-02'
GO 
SELECT * FROM PARTDB.dbo.SALES_V WHERE OrderDate >= '2017-01-01' AND OrderDate < '2017-01-02'
GO 
SELECT * FROM PARTDB.dbo.Sales_Part WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-02'
GO 
SELECT * FROM PARTDB.dbo.SALES_V WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-02'
GO 

--=========================================================
-- DETAILS OF PARTITION DISTRIBUTION
--=========================================================
USE PARTDB
GO
SELECT DS.name AS DataSpaceName,OBJ.name AS ObjectName,IDX.type_desc AS IndexType
      ,AU.total_pages / 128 AS TotalSizeMB ,AU.used_pages / 128 AS UsedSizeMB 
      ,AU.data_pages / 128 AS DataSizeMB
      ,IDX.name AS IndexName
	  ,Total_pages ,used_pages ,data_pages 
FROM sys.data_spaces AS DS 
     INNER JOIN sys.allocation_units AS AU ON DS.data_space_id = AU.data_space_id 
     INNER JOIN sys.partitions AS PA ON (AU.type IN (1, 3)  AND AU.container_id = PA.hobt_id) OR (AU.type = 2 AND AU.container_id = PA.partition_id) 
     INNER JOIN sys.objects AS OBJ ON PA.object_id = OBJ.object_id 
     INNER JOIN sys.schemas AS SCH ON OBJ.schema_id = SCH.schema_id 
     LEFT JOIN sys.indexes AS IDX ON PA.object_id = IDX.object_id AND PA.index_id = IDX.index_id 
WHERE OBJ.type_desc = 'USER_TABLE' 
ORDER BY DS.name ,SCH.name ,OBJ.name ,IDX.name

--=========================================================
-- INDEX CREATION - PARTITION TABLE
--=========================================================
ALTER TABLE SALES_PART
ADD CONSTRAINT PK_SALES_PART 
	PRIMARY KEY CLUSTERED ([OrderDate],[SalesOrderID]) 
ON SalesPerYearPS ([OrderDate])
GO

--=========================================================
-- DETAILS OF PARTITION DISTRIBUTION
--=========================================================
USE PARTDB
GO
SELECT DS.name AS DataSpaceName,OBJ.name AS ObjectName,IDX.type_desc AS IndexType
      ,AU.total_pages / 128 AS TotalSizeMB ,AU.used_pages / 128 AS UsedSizeMB 
      ,AU.data_pages / 128 AS DataSizeMB
      ,IDX.name AS IndexNamer
	  ,Total_pages ,used_pages ,data_pages 
FROM sys.data_spaces AS DS 
     INNER JOIN sys.allocation_units AS AU ON DS.data_space_id = AU.data_space_id 
     INNER JOIN sys.partitions AS PA ON (AU.type IN (1, 3)  AND AU.container_id = PA.hobt_id) OR (AU.type = 2 AND AU.container_id = PA.partition_id) 
     INNER JOIN sys.objects AS OBJ ON PA.object_id = OBJ.object_id 
     INNER JOIN sys.schemas AS SCH ON OBJ.schema_id = SCH.schema_id 
     LEFT JOIN sys.indexes AS IDX ON PA.object_id = IDX.object_id AND PA.index_id = IDX.index_id 
WHERE OBJ.type_desc = 'USER_TABLE' 
ORDER BY OBJ.name ,IDX.name

--=========================================================
-- CHECK PARTITION DISTRIBUTION 
--=========================================================
SELECT $PARTITION.SalesPerYearPFN([OrderDate]) AS Partition, 
MIN ([OrderDate]) AS [Min_Order_Date],
MAX ([OrderDate]) AS [Max_Order_Date],
COUNT(*) AS [COUNT] 
FROM PARTDB.DBO.Sales_PART 
GROUP BY $PARTITION.SalesPerYearPFN([OrderDate])
ORDER BY Partition ;
GO
--=========================================================
-- BACKUP
--=========================================================

BACKUP DATABASE PARTDB TO DISK = 'C:\DB\PARTDB.bak' WITH INIT, STATS = 10
