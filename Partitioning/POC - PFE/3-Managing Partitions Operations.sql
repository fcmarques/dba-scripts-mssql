--=========================================================
-- POPULATING 2017 DATA
--=========================================================
USE PARTDB
GO
DECLARE @LOOP INT = 0;
DECLARE @SalesOrderID INT;
DECLARE @OrderQty INT;
DECLARE @Upper INT;
DECLARE @Lower INT;
DECLARE @date_from AS DATETIME
DECLARE @date_to AS DATETIME
DECLARE @days_diff AS INT 

SELECT @SalesOrderID = ISNULL(MAX(SalesOrderID),0) FROM [PARTDB].[DBO].[Sales_Part];

WHILE @LOOP < 100000
BEGIN
	SET @LOOP = @LOOP+1;
	SET @SalesOrderID = @SalesOrderID +1
	SET @Upper = 20;
	SET @Lower = 1;
	SET @date_from  = '2017-01-01';
	SET @date_to = '2017-08-10';
	SET @days_diff = cast(@date_to - @date_from AS INT);

	SET @date_from = @date_from +
		DATEADD(second, ABS(CHECKSUM(newid()) % 60), 0) + -- random seconds
		DATEADD(minute, ABS(CHECKSUM(newid()) % 60), 0) + -- random minutes
		DATEADD(hour, ABS(CHECKSUM(newid()) % 24), 0) + -- random hours
		DATEADD(day, ABS(CHECKSUM(newid()) % @days_diff), 0) -- random days

	SET @OrderQty = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

	INSERT INTO [PARTDB].[DBO].[Sales_Part] VALUES (@SalesOrderID, @date_from,@OrderQty,	@OrderQty*15)
END

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

SELECT  Closing_Date = DATEADD(MONTH, DATEDIFF(MONTH, 0, [OrderDate]), 0),      
        COUNT(SalesOrderID) TotalCount 
FROM    PARTDB.DBO.Sales_PART 
WHERE   [OrderDate] >= '2017-01-01' AND [OrderDate] <= '2017-12-31'
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, [OrderDate]), 0) ORDER BY 1 ;

--=========================================================
--  Adding new filegroups
--=========================================================
USE MASTER;
GO

--Create and add a FILEGROUP to the PARTDB Database
ALTER DATABASE PARTDB
ADD FILEGROUP PARTDB_Group5 
GO

ALTER DATABASE PARTDB
ADD FILE
(NAME = N'PARTDB_Group5', FILENAME = N'C:\DB\PARTDB\PARTDB_Group5.ndf',SIZE = 25MB, FILEGROWTH = 25MB)
TO FILEGROUP PARTDB_Group5
GO

--=========================================================
-- SPLIT PARTITION
--=========================================================
-- Set the next used partition
USE PARTDB
GO
ALTER PARTITION SCHEME SalesPerYearPS NEXT USED PARTDB_Group5

-- Add a new partition (which will use the filegroup identified as "next used")
ALTER PARTITION FUNCTION SalesPerYearPFN()
SPLIT RANGE ('2017-04-01');

--=========================================================
-- CHECK PARTITION DISTRIBUTION 
--=========================================================
USE PARTDB
GO
SELECT $PARTITION.SalesPerYearPFN([OrderDate]) AS Partition, 
MIN ([OrderDate]) AS [Min_Order_Date],
MAX ([OrderDate]) AS [Max_Order_Date],
COUNT(*) AS [COUNT] 
FROM PARTDB.DBO.Sales_PART 
GROUP BY $PARTITION.SalesPerYearPFN([OrderDate])
ORDER BY Partition ;
GO

--=========================================================
-- MERGE PARTITION
--=========================================================
ALTER PARTITION FUNCTION SalesPerYearPFN()
MERGE RANGE ('2017-04-01');

--=========================================================
-- CHECK PARTITION DISTRIBUTION 
--=========================================================
USE PARTDB
GO
SELECT $PARTITION.SalesPerYearPFN([OrderDate]) AS Partition, 
MIN ([OrderDate]) AS [Min_Order_Date],
MAX ([OrderDate]) AS [Max_Order_Date],
COUNT(*) AS [COUNT] 
FROM PARTDB.DBO.Sales_PART 
GROUP BY $PARTITION.SalesPerYearPFN([OrderDate])
ORDER BY Partition ;
GO

--=========================================================
-- DELETE FILEGROUP
--=========================================================
USE master
GO
ALTER DATABASE PARTDB REMOVE FILE PARTDB_Group5;  
GO
ALTER DATABASE PARTDB REMOVE FILEGROUP PARTDB_Group5;

--=========================================================
-- SET FILEGROUP TO READ_ONLY
--=========================================================
ALTER DATABASE PARTDB MODIFY FILEGROUP PARTDB_Group2 READ_ONLY;
GO
ALTER DATABASE PARTDB MODIFY FILEGROUP PARTDB_Group3 READ_ONLY;
GO

--=========================================================
-- SET FILEGROUP TO READ_WRITE
--=========================================================
ALTER DATABASE PARTDB MODIFY FILEGROUP PARTDB_Group2 READ_WRITE;
GO
ALTER DATABASE PARTDB MODIFY FILEGROUP PARTDB_Group3 READ_WRITE;
GO

--=========================================================
-- PARTITION SWITCH
--=========================================================
USE PARTDB;
GO

IF OBJECT_ID('dbo.SALES_17_SWITCH', 'U') IS NOT NULL 
  DROP TABLE dbo.SALES_17_SWITCH; 
GO
CREATE TABLE [PARTDB].[DBO].[SALES_17_SWITCH](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT SALES2017DtChk_SWITCH CHECK(OrderDate >='2017-01-01'),
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL ) ON [PARTDB_Group4]
GO
ALTER TABLE SALES_17_SWITCH
ADD CONSTRAINT PK_SALES_17_SWITCH 
	PRIMARY KEY CLUSTERED ([OrderDate],[SalesOrderID]) 
ON [PARTDB_Group4]
GO

--=========================================================
-- CHECK PARTITION DISTRIBUTION 
--=========================================================
USE PARTDB
GO
SELECT $PARTITION.SalesPerYearPFN([OrderDate]) AS Partition, 
MIN ([OrderDate]) AS [Min_Order_Date],
MAX ([OrderDate]) AS [Max_Order_Date],
COUNT(*) AS [COUNT] 
FROM PARTDB.DBO.Sales_PART 
GROUP BY $PARTITION.SalesPerYearPFN([OrderDate])
ORDER BY Partition ;
GO

-- SWITCH
ALTER TABLE [PARTDB].[DBO].[SALES_PART]
SWITCH PARTITION 4 TO [SALES_17_SWITCH]


SELECT * FROM SALES_17_SWITCH


-- SWITCH BACK 
ALTER TABLE [PARTDB].[DBO].[SALES_17_SWITCH]
SWITCH TO [SALES_PART] PARTITION 4

SELECT * FROM SALES_17_SWITCH;

SELECT * FROM Sales_Part;