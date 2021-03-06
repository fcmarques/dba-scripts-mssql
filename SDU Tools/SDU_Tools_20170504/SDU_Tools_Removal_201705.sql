--==================================================================================
-- Remove the SDU_Tools Schema
-- Copyright Dr Greg Low
-- Version 3.8 May 2017
--==================================================================================
--
-- What are the SDU Tools? 
--
-- This script removes an existing installation of SDU_Tools

USE tempdb; -- set to tempdb first in case the database hasn't been correctly set
GO          -- in the next step

USE Development; -- set the database here
GO

--==================================================================================
-- Disclaimer and License
--==================================================================================
--
-- We try our hardest to make these tools as useful and bug free as possible, but like
-- any software, we can never guarantee that there won't be any issues. We hope you'll
-- decide to use the tools but all liability for using them is with you, not us.
--
-- You are free to use the tools in this collection as long as you keep them in 
-- the SDU_Tools schema as a single set of tools, and as long as this notice is kept
-- in any script file copies of the tools. They can be used privately or commercially.
-- You may not repurpose them, redistribute, or resell them. We hope you'll find them
-- really useful.
--

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SQL nvarchar(max);
DECLARE @SchemaID int = SCHEMA_ID('SDU_Tools');

IF @SchemaID IS NOT NULL
BEGIN
    DECLARE @ObjectCounter as int = 1;
    DECLARE @ObjectName sysname;
    DECLARE @TableName sysname;
    DECLARE @ObjectTypeCode varchar(10);
    DECLARE @ObjectsToRemove TABLE
    ( 
        ObjectRemovalOrder int IDENTITY(1,1) NOT NULL,
        ObjectTypeCode varchar(10) NOT NULL,
        ObjectName sysname NOT NULL,
        TableName sysname NULL
    );
    
    INSERT @ObjectsToRemove (ObjectTypeCode, ObjectName, TableName)
    SELECT o.[type], o.[name], t.[name]
    FROM sys.objects AS o 
    LEFT OUTER JOIN sys.objects AS t
        ON o.parent_object_id = t.[object_id]
    WHERE o.[schema_id] = @SchemaID
    ORDER BY CASE o.[type] WHEN 'V' THEN 1    -- view
                           WHEN 'P' THEN 2    -- stored procedure
                           WHEN 'PC' THEN 3   -- clr stored procedure
                           WHEN 'FN' THEN 4   -- scalar function
                           WHEN 'FS' THEN 5   -- clr scalar function
                           WHEN 'AF' THEN 6   -- clr aggregate
                           WHEN 'FT' THEN 7   -- clr table-valued function
                           WHEN 'TF' THEN 8   -- table-valued function
                           WHEN 'IF' THEN 9   -- inline table-valued function
                           WHEN 'TR' THEN 10  -- trigger
                           WHEN 'TA' THEN 11  -- clr trigger
                           WHEN 'D' THEN 12   -- default
                           WHEN 'F' THEN 13   -- foreign key constraint
                           WHEN 'C' THEN 14   -- check constraint
                           WHEN 'UQ' THEN 15  -- unique constraint
                           WHEN 'PK' THEN 16  -- primary key constraint
                           WHEN 'U' THEN 17   -- table
                           WHEN 'TT' THEN 18  -- table type
                           WHEN 'SO' THEN 19  -- sequence
             END;
    
    WHILE @ObjectCounter <= (SELECT MAX(ObjectRemovalOrder) FROM @ObjectsToRemove)
    BEGIN
        SELECT @ObjectTypeCode = otr.ObjectTypeCode,
               @ObjectName = otr.ObjectName,
               @TableName = otr.TableName 
        FROM @ObjectsToRemove AS otr 
        WHERE otr.ObjectRemovalOrder = @ObjectCounter;

        SET @SQL = CASE WHEN @ObjectTypeCode = 'V' 
                        THEN N'DROP VIEW SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('P' , 'PC')
                        THEN N'DROP PROCEDURE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('FN', 'FS', 'FT', 'TF', 'IF')
                        THEN N'DROP FUNCTION SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('TR', 'TA')
                        THEN N'DROP TRIGGER SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('C', 'D', 'F', 'PK', 'UQ')
                        THEN N'ALTER TABLE SDU_Tools.' + QUOTENAME(@TableName) 
                             + N' DROP CONSTRAINT ' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'U'
                        THEN N'DROP TABLE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'AF'
                        THEN N'DROP AGGREGATE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'TT'
                        THEN N'DROP TYPE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'SO'
                        THEN N'DROP SEQUENCE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                   END;

            IF @SQL IS NOT NULL
            BEGIN
                EXECUTE(@SQL);
            END;

        SET @ObjectCounter += 1;
    END;
    DROP SCHEMA SDU_Tools;
END; -- of if the schema already exists
GO
