--==================================================================================
-- Recreate the SDU_Tools Schema
-- Copyright Dr Greg Low
-- Version 3.8b May 2017
--==================================================================================
--
-- What are the SDU Tools? 
--
-- This script contains a number of utility functions and procedures. These are 
-- created in a schema called SDU_Tools in the current database. Ensure that you have
-- set the current database first before running this script. (If you want to keep
-- them quite separate, create a separate database first).

USE tempdb; -- set to tempdb first in case the database hasn't been correctly set
GO          -- in the next step

USE TARGET_DATABASE_NAME_HERE; -- set the database here
GO

-- When this script is executed, it first removes any existing objects from the 
-- SDU_Tools schema, then recreates all the tools with the latest versions. It 
-- can be re-run without issue. (Yes it's idempotent for the geeks).
-- Many of the functions are useful when performing troubleshooting but others 
-- are just general purpose functions. 
--
-- For a general overview of SDU Tools, refer to this video: https://youtu.be/o0im4sE5lsA
-- For information on installing the tools, refer to this video: https://youtu.be/zRPvryGYYXU
--
-- Note that string manipulation in T-SQL and scalar functions are very slow. Many of 
-- these functions would be much faster as SQLCLR based implementations but not all 
-- system have SQLCLR integration enabled. To make them work wherever possible, all
-- these functions are written in pure T-SQL. We also don't assume that you're 
-- using the latest version of SQL Server, so the functions are written to work
-- on all currently-supported versions.
-- 
-- This toolset is updated regularly. Find the latest version or sign up to be
-- notified of updates at http://www.sqldownunder.com and for suggestions or 
-- bug reports, please email sdutoolsATsqldownunder.com 
--
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
--==================================================================================
-- Fixes by version
--==================================================================================
--
-- May 2017               Nil
--
-- April 2017             Fixed some filtering options for list related stored procedures.
--                        Removed "CREATE OR ALTER" in a function header
--                        
-- March 2017             Fixed some collation issues for databases with different
--                        collations to the server
--
--==================================================================================
-- General String Functions
--==================================================================================
--
-- ProperCase                      Converts a string to Proper Case
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- TitleCase                       Converts a string to Title Case (Like a Book Title)
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- CamelCase                       Converts a string to camelCase
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- PascalCase                      Converts a string to PascalCase
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- SnakeCase                       Converts a string to snake_case
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- KebabCase                       Converts a string to Kebab-Case
--                                 Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- PercentEncode                   Encodes reserved characters that are used in 
--                                 HTML or URL encoding
--                                 Refer to this video: https://youtu.be/pNjaasXYvEQ
--
-- QuoteString                     Quotes a string 
--                                 Refer to this video: https://youtu.be/uIj-hTIhIZo
--
-- SplitDelimitedString            Splits a delimited string (usually either a CSV or TSV)
--                                 Refer to this video: https://youtu.be/Ubt4HSKE2QI
--
-- TrimWhitespace                  Removes any leading or trailing space, tab, 
--                                 carriage return, and linefeed characters
--                                 Refer to this video: https://youtu.be/cYaUC053Elo
--
-- LeftPad                         Left pad a string to a target length with a given
--                                 padding character
--                                 Refer to this video: https://youtu.be/P-r1zmX1MpY
--
-- RightPad                        Right pad a string to a target length with a given
--                                 padding character
--                                 Refer to this video: https://youtu.be/P-r1zmX1MpY
--
-- SeparateByCase                  Insert a separator between Pascal cased or Camel cased words
--                                 Refer to this video: https://youtu.be/kyr8C2hY5HY
--
-- AsciiOnly                       Removes (and optionally replaces) any non-ASCII characters
--                                 Refer to this video: https://youtu.be/0YFYPN0Bivo
--
-- PreviousNonWhitespaceCharacter  Finds the previous non-whitespace character working
--                                 backwards from the current position
--                                 Refer to this video: https://youtu.be/rY5-eLlzuKU
--
--==================================================================================
-- Data Conversion Functions
--==================================================================================
--
-- Base64ToVarbinary               Converts a base 64 value to varbinary
--                                 Refer to this video: https://youtu.be/k6yHYdHn7NA
--
-- VarbinaryToBase64               Converts a varbinary value to base 64 encoding
--                                 Refer to this video: https://youtu.be/k6yHYdHn7NA
--
-- CharToHexadecimal               Converts a character to a hexadecimal string
--                                 Refer to this video: https://youtu.be/aT4viskU7fE
--
-- SQLVariantInfo                  Returns information about a SQL_variant value
--                                 Refer to this video: https://youtu.be/em62I-GBCEY
--
-- SecondsToDuration               Converts a number of seconds to a duration string
--                                 Refer to this video: https://youtu.be/beANzSe1-jE
--
--==================================================================================
-- Database and Table Comparison Tools
--==================================================================================
--
-- GetDBSchemaCoreComparison       Checks the schema of two databases, looking for 
--                                 basic differences  
--                                 Refer to this video: https://youtu.be/8Q8dsxBU6XQ
--

--
-- GetTableSchemaComparison        Checks the schema of two tables, looking for basic 
--                                 differences
--                                 Refer to this video: https://youtu.be/8Q8dsxBU6XQ
--
--==================================================================================
-- Date and Financial Functions
--==================================================================================
--
-- StartOfFinancialYear            Calculates the date for the beginning of a 
--                                 financial year
--                                 Refer to this video: https://youtu.be/wc8ZS_XPKZs
--
-- EndOfFinancialYear              Calculates the date for the end of a 
--                                 financial year
--                                 Refer to this video: https://youtu.be/wc8ZS_XPKZs
--
-- CalculateAge                    Calculates the age of anything based on 
--                                 starting date (such as date of birth) and 
--                                 ending date (such as today)
--                                 Refer to this video: https://youtu.be/4XTubsQKPlw
--
--==================================================================================
-- Database Utilities
--==================================================================================
--
-- AnalyzeTableColumns             Provide metadata for a table's columns and list
--                                 the distinct values held in the column (up to 
--                                 a maximum number of values)
--                                 Refer to this video: https://youtu.be/V-jCAT-TCXM
--
-- FindStringWithinADatabase       Finds a string anywhere within a database. Can be 
--                                 useful for testing masking of sensitive data. Checks 
--                                 all string type columns and XML columns
--                                 Refer to this video: https://youtu.be/OpTdjMMjy8w
-- 
-- ListSubsetIndexes               Lists indexes that appear to be subsets of other 
--                                 indexes in all databases or selected databases
--                                 Refer to this video: https://youtu.be/aICj46bmKJs
--
-- ListAllDataTypesInUse           A distinct list of each data type (and size) used 
--                                 with the selected database
--                                 Refer to this video: https://youtu.be/1MzqnkLeoNM
--
-- ListColumnsAndDataTypes         Lists all columns and their data types for a database
--                                 Refer to this video: https://youtu.be/FlkRho_Hngk
--
-- ListMismatchedDataTypes         List columns with the same name that are defined with 
--                                 different data types
--                                 Refer to this video: https://youtu.be/i6mmzhu4T9g
--
-- ListUnusedIndexes               Lists unused indexes for a database
--                                 Refer to this video: https://youtu.be/SNVSBWPsBnw
--
-- ListUseOfDeprecatedDataTypes    Lists all columns and their data types for a database
--                                 where the data type is deprecated
--                                 Refer to this video: https://youtu.be/kVVxIMMwdRI
--
-- ListUserTableSizes              Lists the size and number of rows for all or selected 
--                                 user tables
--                                 Refer to this video: https://youtu.be/mwOpnit0zqg
--
-- ListUserTableAndIndexSizes      Lists the size and number of rows for all or selected 
--                                 user tables and indexes
--                                 Refer to this video: https://youtu.be/mwOpnit0zqg
-- 
-- EmptySchema                     Empties a schema (removes all user objects) in the schema
--                                 WARNING: obviously destructive
--                                 Refer to this video: https://youtu.be/ygQNeirGdlM
--
-- PrintMessage                    Prints an output message immediately (not waiting for PRINT)
--                                 Refer to this video: https://youtu.be/Coabe1oY8Vg
--
-- IsXActAbortON                   Determines if XACT_ABORT is currently on
--                                 Refer to this video: https://youtu.be/Bx81-MTqr1k
--
-- ShowBackupCompletionEstimates   Show the status of currently-executing backups and 
--                                 estimate the completion time
--                                 Refer to this video: https://youtu.be/M-Gh4CfQkIg
--
-- ShowCurrentBlocking             Lists sessions (and their last queries) for all sessions
--                                 holding locks, then lists blocked sessions, with 
--                                 the queries they are trying to execute, and which
--                                 sessions are blocking them
--                                 Refer to this video: https://youtu.be/utIPkuqfTu0
--
-- ExecuteJobAndWaitForCompletion  Executes a SQL Server Agent job and waits for it
--                                 to complete
--                                 Refer to this video: https://youtu.be/zTNMgez6ubo
--
--==================================================================================
-- Scripting Functions
--==================================================================================
--
-- ScriptSQLLogins                 Scripts (all or selected) SQL Logins along with security ID
--                                 default database, password hash, default language, and policy
--                                 Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- ScriptWindowsLogins             Scripts (all or selected) Windows Logins along with 
--                                 default database and default language
--                                 Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- ScriptServerRoleMembers         Scripts all server role membership for all or selected logins
--                                 Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- ScriptServerPermissions         Scripts all server permissions (apart from CONNECT SQL)
--                                 for all or selected logins
--                                 Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- ScriptDatabaseUsers             Scripts all users associated with a login for 
--                                 a particular database
--                                 Refer to this video: https://youtu.be/IbsUyfLh2Po
--
-- FormatDataTypeName              Converts data type, maximum length, precision, and scale
--                                 into the standard format used in scripts
--                                 Refer to this video: https://youtu.be/Cn3jK3roWLg
--
-- ExecuteOrPrint                  Either prints the generated code or executes it 
--                                 batch by batch. (Unless specified, it assumes that GO 
--                                 is the batch separator. One limitation is that it
--                                 doesn't accept inline comments on the batch separator
--                                 line).
--                                 Refer to this video: https://youtu.be/cABGotl_yHY
--
-- PGObjectName                    Converts a Pascal-cased or camel-cased SQL Server object
--                                 name to a suitable snake-cased object name for use
--                                 with database engines like PostgreSQL
--                                 Refer to this video: https://youtu.be/2ZPa1dgOZew
--
--==================================================================================
-- Performance Tuning Related Functions and Procedures
--==================================================================================
--
-- CapturePerformanceTuningTrace   Captures a trace needed when carrying out 
--                                 performance tuning. (Based on SQLTrace)
--                                 Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- LoadPerformanceTuningTrace      Loads a trace file (based on SQLTrace) into a table
--                                 Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- AnalyzePerformanceTuningTrace   Analyzes the queries that are found in a loaded
--                                 trace file (based on the previous two tools)
--                                 Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- ExtractSQLTemplate              Used to normalize a SQL Server command, mostly for 
--                                 helping with performance tuning work. Extracts the 
--                                 underlying template of the command. If the command 
--                                 includes an exec sp_executeSQL statement, tries to 
--                                 undo that statement as well. (Cannot do so if that 
--                                 isn't the last statement in the batch being processed)
--                                 Refer to this video: https://youtu.be/yX5q00m_uCA
--
-- DeExecuteSQLString              Used internally by ExtractSQLTemplate
--                                 Assists with debugging and performance troubleshooting 
--                                 of sp_executeSQL commands, particularly those captured
--                                 in Profiler or Extended Events traces. Takes a valid 
--                                 exec sp_executeSQL string and extracts the embedded 
--                                 command from within it. Optionally, can extract 
--                                 the parameters and either embed them directly back 
--                                 into the code, or create them as variable declarations
--
-- LastParameterStartPosition      Used internally by ExtractSQLTemplate
--                                 Starting at the end of the string, finds the last 
--                                 location where a parameter is defined, based 
--                                 on a @ prefix
--
--============================================================================================
-- Start by recreating the schema
--

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SQL nvarchar(max);
DECLARE @SchemaID int = SCHEMA_ID('SDU_Tools');

IF @SchemaID IS NULL
BEGIN
    SET @SQL = N'CREATE SCHEMA SDU_Tools AUTHORIZATION dbo;';
    EXECUTE (@SQL);
END
ELSE 
BEGIN -- drop all existing objects in the SDU_Tools schema
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
END; -- of if we need to empty the schema first
GO

--==================================================================================
-- String Functions and Procedures
--==================================================================================

CREATE FUNCTION SDU_Tools.PascalCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Pascal Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Pascal Casing to a string (similar to programming identifiers)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.CamelCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.CamelCase(N'janet mcdermott');
SELECT SDU_Tools.CamelCase(N'the case of sherlock holmes and the curly-Haired  company');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', N'-', NCHAR(9)) -- whitespace or hyphens
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    UPDATE @Words SET Word = UPPER(SUBSTRING(Word, 1, 1)) + SUBSTRING(Word, 2, LEN(Word) - 1);

    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);
        SET @Response += @CurrentWord;
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.KebabCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Kebab Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Kebab Casing to a string (similar to programming identifiers)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.KebabCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.KebabCase(N'janet mcdermott');
SELECT SDU_Tools.KebabCase(N'the case of sherlock holmes and the curly-Haired  company');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', N'-', NCHAR(9)) -- whitespace or hyphens
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    UPDATE @Words SET Word = UPPER(SUBSTRING(Word, 1, 1)) + SUBSTRING(Word, 2, LEN(Word) - 1);

    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);
        SET @Response += CASE WHEN @WordCounter > 1 THEN N'-' ELSE N'' END + @CurrentWord;
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.CamelCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Pascal Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Pascal Casing to a string (similar to programming identifiers)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.CamelCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.CamelCase(N'janet mcdermott');
SELECT SDU_Tools.CamelCase(N'the case of sherlock holmes and the curly-Haired  company');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', N'-', NCHAR(9)) -- whitespace or hyphens
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    UPDATE @Words SET Word = CASE WHEN WordNumber > 1 THEN UPPER(SUBSTRING(Word, 1, 1)) + SUBSTRING(Word, 2, LEN(Word) - 1)
                                  ELSE Word 
                             END;

    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);
        SET @Response += @CurrentWord;
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.PercentEncode(@StringToEncode varchar(max))
RETURNS varchar(max)
AS
BEGIN;

-- Function:      Apply percent encoding to a string (could be used for URL Encoding)
-- Parameters:    @StringToEncode varchar(max)
-- Action:        Encodes reserved characters that might be used in HTML or URL encoding
--                Encoding is based on PercentEncoding article https://en.wikipedia.org/wiki/Percent-encoding
--                Only characters allowed unencoded are A-Z,a-z,0-9,-,_,.,~     (note: not the comma)
-- Return:        varchar(max)
-- Refer to this video: https://youtu.be/pNjaasXYvEQ
--
-- Test examples: 
/*

SELECT SDU_Tools.PercentEncode('www.SQLdownunder.com/podcasts');
SELECT SDU_Tools.PercentEncode('this should be a URL but it contains {}234');

*/
    DECLARE @ReservedCharacterPattern varchar(max) = '%[^A-Za-z0-9\-\_\.\~]%';
    DECLARE @NextReservedCharacterLocation int;
    DECLARE @CharacterToEncode char(1);
    DECLARE @StringToReturn varchar(max) = '';
    DECLARE @RemainingString varchar(max) = @StringToEncode;
    
    SET @NextReservedCharacterLocation = PATINDEX(@ReservedCharacterPattern, @RemainingString);
    WHILE @NextReservedCharacterLocation > 0 
    BEGIN
        SET @StringToReturn += LEFT(@RemainingString, @NextReservedCharacterLocation - 1)
                            + '%' 
                            + SDU_Tools.CharToHexadecimal(SUBSTRING(@RemainingString, @NextReservedCharacterLocation, 1));
        SET @RemainingString = SUBSTRING(@RemainingString, @NextReservedCharacterLocation + 1, LEN(@RemainingString));

        SET @NextReservedCharacterLocation = PATINDEX(@ReservedCharacterPattern, @RemainingString);
    END;

    SET @StringToReturn += @RemainingString;

    RETURN (@StringToReturn);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.PreviousNonWhitespaceCharacter
( 
    @StringToTest nvarchar(max), 
    @CurrentPosition int
)
RETURNS nvarchar(1)
AS
BEGIN

-- Function:      Locates the previous non-whitespace character in a string
-- Parameters:    @StringToTest nvarchar(max)
--                @CurrentPosition int
-- Action:        Finds the previous non-whitespace character backwards from the 
--                current position.
-- Return:        nvarchar(1)
-- Refer to this video: https://youtu.be/rY5-eLlzuKU
--
-- Test examples: 
/*

DECLARE @TestString nvarchar(max) = N'Hello there ' + CHAR(9) + ' fred ' + CHAR(13) + CHAR(10) + 'again';
--                                    123456789112         3     456789         2          1      23456

SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,11); -- should be r
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,15); -- should be e
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,22); -- should be d
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,1);  -- should be blank
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,0);  -- should be blank

*/
    DECLARE @NonWhitespaceCharacterPattern nvarchar(9) = N'%[^ ' + NCHAR(9) + NCHAR(13) + NCHAR(10) + N']%';
    DECLARE @ReverseStringSegment nvarchar(max) = CASE WHEN @CurrentPosition <= 0 THEN ''
                                                       ELSE REVERSE(SUBSTRING(@StringToTest, 1, @CurrentPosition - 1))
                                                  END;
    DECLARE @LastCharacter int = PATINDEX(@NonWhitespaceCharacterPattern, @ReverseStringSegment);

    RETURN CASE WHEN @LastCharacter = 0 THEN N''
                ELSE SUBSTRING(@ReverseStringSegment, @LastCharacter, 1)
           END;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ProperCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Proper Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Proper Casing to a string
-- Return:        varchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.ProperCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.ProperCase(N'janet mcdermott');
SELECT SDU_Tools.ProperCase(N'the curly-Haired  company');
SELECT SDU_Tools.ProperCase(N'po Box 1086');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @ModifiedWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', NCHAR(9)) -- whitespace
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);

        IF @CurrentWord IN ('PO', 'DC', 'NY')
        BEGIN
            SET @ModifiedWord = UPPER(@CurrentWord);
        END ELSE BEGIN
            SET @ModifiedWord = UPPER(SUBSTRING(@CurrentWord, 1, 1)) + SUBSTRING(@CurrentWord, 2, LEN(@CurrentWord) - 1);
        END;
        IF LEFT(@CurrentWord, 2) = N'mc' AND LEN(@CurrentWord) >= 3
        BEGIN
            SET @ModifiedWord = N'Mc' + UPPER(SUBSTRING(@CurrentWord, 3, 1)) + SUBSTRING(@CurrentWord, 4, LEN(@CurrentWord) - 3);
        END;
        IF LEFT(@CurrentWord, 3) = N'mac' AND LEN(@CurrentWord) >= 4
        BEGIN
            SET @ModifiedWord = N'Mac' + UPPER(SUBSTRING(@CurrentWord, 4, 1)) + SUBSTRING(@CurrentWord, 5, LEN(@CurrentWord) - 4);
        END;
        
        SET @CharacterCounter = 0;
        WHILE @CharacterCounter <= LEN(@ModifiedWord)
        BEGIN
            SET @CharacterCounter += 1;
            SET @Character = SUBSTRING(@ModifiedWord, @CharacterCounter, 1);
            IF @Character IN (N'.', N'-', N';', N':', N'&', N'$', N'#', N'@', N'!', N'*', N'%', N'(', N')', N'''')
            BEGIN
                IF LEN(@ModifiedWord) > @CharacterCounter 
                BEGIN
                    SET @ModifiedWord = SUBSTRING(@ModifiedWord, 1, @CharacterCounter)
                                      + UPPER(SUBSTRING(@ModifiedWord, @CharacterCounter + 1, 1))
                                      + SUBSTRING(@ModifiedWord, @CharacterCounter + 2, LEN(@ModifiedWord) - @CharacterCounter - 1);
                END;
            END;
        END;
        
        SET @Response += @ModifiedWord;
        IF @WordCounter < @NumberOfWords SET @Response += N' ';
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.SnakeCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Snake Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Snake Casing to a string (similar to programming identifiers)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.SnakeCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.SnakeCase(N'janet mcdermott');
SELECT SDU_Tools.SnakeCase(N'the case of sherlock holmes and the curly-Haired  company');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', N'-', NCHAR(9)) -- whitespace or hyphens
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);
        SET @Response += CASE WHEN @WordCounter > 1 THEN N'_' ELSE N'' END + @CurrentWord;
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.QuoteString
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Quotes a string
-- Parameters:    @InputString varchar(max)
-- Action:        Quotes a string (also doubles embedded quotes)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/uIj-hTIhIZo
--
-- Test examples: 
/*

DECLARE @Him nvarchar(max) = N'his name';
DECLARE @Them nvarchar(max) = N'they''re here';

SELECT @Him AS Him, SDU_Tools.QuoteString(@Him) AS QuotedHim
     , @Them AS Them, SDU_Tools.QuoteString(@Them) AS QuotedThem;

*/
    RETURN N'''' + REPLACE(@InputString, N'''', N'''''') + N'''';
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.SplitDelimitedString
(
    @StringToSplit nvarchar(max),
    @Delimiter nvarchar(10),
    @TrimOutput bit
)
RETURNS @StringTable TABLE 
(
    RowNumber int IDENTITY(1,1),
    StringValue nvarchar(max)
)
AS
BEGIN

-- Function:      Splits a delimited string (usually either a CSV or TSV)
-- Parameters:    @StringToSplit nvarchar(max)       -> string that will be split
--                @Delimiter nvarchar(10)            -> delimited used (usually either N',' or NCHAR(9) for tab)
--                @TrimOutput bit                    -> if 1 then trim strings before returning them
-- Action:        Splits delimited strings - usually comma-delimited strings CSVs or tab-delimited strings (TSVs)
--                Delimiter can be specified
--                Optionally, the output strings can be trimmed
-- Return:        Table containing a column called StringValue nvarchar(max)
-- Refer to this video: https://youtu.be/Ubt4HSKE2QI
-- Test examples: 
/*

SELECT * FROM SDU_Tools.SplitDelimitedString(N'hello, there, greg', N',', 0);
SELECT * FROM SDU_Tools.SplitDelimitedString(N'hello' + NCHAR(9) + N'there' + NCHAR(9) + N'greg', NCHAR(9), 1);

*/

    DECLARE @XmlString xml = CAST(('<X>' + REPLACE(@StringToSplit, @Delimiter ,N'</X><X>') + N'</X>') AS XML);

    INSERT @StringTable (StringValue)
    SELECT CASE WHEN @TrimOutput <> 0 THEN LTRIM(RTRIM(xmlcol.value(N'.', 'varchar(max)')))
                ELSE xmlcol.value(N'.', 'varchar(max)')
           END AS StringValue
    FROM @XmlString.nodes('X') AS X(xmlcol);

    RETURN;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.TitleCase
(
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Apply Title Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Title Casing to a string (similar to book titles)
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/OZ-ozo7R9eU
--
-- Test examples: 
/*

SELECT SDU_Tools.TitleCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.TitleCase(N'janet mcdermott');
SELECT SDU_Tools.TitleCase(N'the case of sherlock holmes and the curly-Haired  company');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @StringToProcess nvarchar(max);
    DECLARE @CharacterCounter int = 0;
    DECLARE @WordCounter int = 0;
    DECLARE @Character nchar(1);
    DECLARE @InAWord bit;
    DECLARE @CurrentWord nvarchar(max);
    DECLARE @ModifiedWord nvarchar(max);
    DECLARE @NumberOfWords int;
    
    DECLARE @Words TABLE
    (
        WordNumber int IDENTITY(1,1),
        Word nvarchar(max)
    );
    
    SET @StringToProcess = LOWER(LTRIM(RTRIM(@InputString)));
    SET @InAWord = 0;
    SET @CurrentWord = N'';
    
    WHILE @CharacterCounter < LEN(@StringToProcess)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@StringToProcess, @CharacterCounter, 1);
        IF @Character IN (N' ', NCHAR(9)) -- whitespace
        BEGIN
            IF @InAWord <> 0
            BEGIN
                SET @InAWord = 0;
                INSERT @Words VALUES (@CurrentWord);
                SET @CurrentWord = N'';
            END;
        END ELSE BEGIN -- not whitespace
            IF @InAWord = 0 -- start of a word
            BEGIN
                SET @InAWord = 1;
                SET @CurrentWord = @Character;
            END ELSE BEGIN -- part of a word
                SET @CurrentWord += @Character;
            END;
        END;
    END;
    IF @InAWord <> 0 
    BEGIN
        INSERT @Words VALUES (@CurrentWord);
    END;
    
    SET @NumberOfWords = (SELECT COUNT(*) FROM @Words);
    SET @WordCounter = 0;
    
    WHILE @WordCounter < @NumberOfWords
    BEGIN
        SET @WordCounter += 1;
        SET @CurrentWord = (SELECT Word FROM @Words WHERE WordNumber = @WordCounter);
        IF @WordCounter = 1
        BEGIN
            SET @ModifiedWord = UPPER(SUBSTRING(@CurrentWord, 1, 1)) + SUBSTRING(@CurrentWord, 2, LEN(@CurrentWord) - 1);
        END ELSE BEGIN
            IF @CurrentWord IN (N'a', N'an', N'and', N'at', N'for', N'if', N'of', N'on', N'the', N'to')
            BEGIN
                SET @ModifiedWord = @CurrentWord;
            END ELSE BEGIN
                IF LEFT(@CurrentWord, 2) = N'mc' AND LEN(@CurrentWord) >= 3
                BEGIN
                    SET @ModifiedWord = N'Mc' + UPPER(SUBSTRING(@CurrentWord, 3, 1)) + SUBSTRING(@CurrentWord, 4, LEN(@CurrentWord) - 3);
                END ELSE BEGIN
                    IF LEFT(@CurrentWord, 3) = N'mac' AND LEN(@CurrentWord) >= 4
                    BEGIN
                        SET @ModifiedWord = N'Mac' + UPPER(SUBSTRING(@CurrentWord, 4, 1)) + SUBSTRING(@CurrentWord, 5, LEN(@CurrentWord) - 4);
                    END ELSE BEGIN
                        SET @ModifiedWord = UPPER(SUBSTRING(@CurrentWord, 1, 1)) + SUBSTRING(@CurrentWord, 2, LEN(@CurrentWord) - 1);
                    END;
                END;
            END;
        END;
        
        SET @CharacterCounter = 0;
        WHILE @CharacterCounter <= LEN(@ModifiedWord)
        BEGIN
            SET @CharacterCounter += 1;
            SET @Character = SUBSTRING(@ModifiedWord, @CharacterCounter, 1);
            IF @Character IN (N'.', N'-', N';', N':', N'&', N'$', N'#', N'@', N'!', N'*', N'%', N'(', N')', N'''')
            BEGIN
                IF LEN(@ModifiedWord) > @CharacterCounter 
                BEGIN
                    SET @ModifiedWord = SUBSTRING(@ModifiedWord, 1, @CharacterCounter)
                                      + UPPER(SUBSTRING(@ModifiedWord, @CharacterCounter + 1, 1))
                                      + SUBSTRING(@ModifiedWord, @CharacterCounter + 2, LEN(@ModifiedWord) - @CharacterCounter - 1);
                END;
            END;
        END;
        
        SET @Response += @ModifiedWord;
        IF @WordCounter < @NumberOfWords SET @Response += N' ';
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.TrimWhitespace
( 
    @InputString nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Trims all whitespace around a string
-- Parameters:    @InputString nvarchar(max)
-- Action:        Removes any leading or trailing space, tab, carriage return, 
--                linefeed characters.
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/cYaUC053Elo
--
-- Test examples: 
/*

SELECT '-->' + SDU_Tools.TrimWhitespace('Test String') + '<--';
SELECT '-->' + SDU_Tools.TrimWhitespace('  Test String     ') + '<--';
SELECT '-->' + SDU_Tools.TrimWhitespace('  Test String  ' + char(13) + char(10) + ' ' + char(9) + '   ') + '<--';

*/

    DECLARE @NonWhitespaceCharacterPattern nvarchar(9) = N'%[^ ' + NCHAR(9) + NCHAR(13) + NCHAR(10) + N']%';

    DECLARE @StartCharacter int = PATINDEX(@NonWhitespaceCharacterPattern, @InputString);
    DECLARE @LastCharacter int = PATINDEX(@NonWhitespaceCharacterPattern, REVERSE(@InputString));

    RETURN CASE WHEN @StartCharacter = 0 THEN N''
                ELSE SUBSTRING(@InputString, @StartCharacter, DATALENGTH(@InputString) / 2 + 2 - @StartCharacter - @LastCharacter)
           END;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.LeftPad
(
    @InputString nvarchar(max),
    @TargetLength int,
    @PaddingCharacter nvarchar(1)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Left pads a string
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Left pads a string to a target length with a given padding character.
--                Truncates the data if it is too large. With implicitly cast numeric
--                and other data types if not passed as strings.
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/P-r1zmX1MpY
--
-- Test examples: 
/*

SELECT SDU_Tools.LeftPad(N'Hello', 14, N'o');
SELECT SDU_Tools.LeftPad(18, 10, N'0');

*/
    RETURN RIGHT(REPLICATE(@PaddingCharacter, @TargetLength) + @InputString, @TargetLength);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.RightPad
(
    @InputString nvarchar(max),
    @TargetLength int,
    @PaddingCharacter nvarchar(1)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Right pads a string
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Right pads a string to a target length with a given padding character.
--                Truncates the data if it is too large. With implicitly cast numeric
--                and other data types if not passed as strings.
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/P-r1zmX1MpY
--
-- Test examples: 
/*

SELECT SDU_Tools.RightPad(N'Hello', 14, N'o');
SELECT SDU_Tools.RightPad(18, 10, N'.');

*/
    RETURN LEFT(@InputString + REPLICATE(@PaddingCharacter, @TargetLength), @TargetLength);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION [SDU_Tools].[SeparateByCase]
(
    @InputString nvarchar(max),
    @Separator nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Insert a separator between Pascal cased or Camel cased words
-- Parameters:    @InputString varchar(max)
-- Action:        Insert a separator between Pascal cased or Camel cased words
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/kyr8C2hY5HY
--
-- Test examples: 
/*

SELECT SDU_Tools.SeparateByCase(N'APascalCasedSentence', N' ');
SELECT SDU_Tools.SeparateByCase(N'someCamelCasedWords', N' ');

*/
    DECLARE @Response nvarchar(max) = N'';
    DECLARE @CharacterCounter int = 0;
    DECLARE @Character nchar(1);
    
    WHILE @CharacterCounter < LEN(@InputString)
    BEGIN
        SET @CharacterCounter += 1;
        SET @Character = SUBSTRING(@InputString, @CharacterCounter, 1);
        IF @CharacterCounter > 1
        BEGIN
            IF ASCII(UPPER(@Character)) = ASCII(@Character) 
            BEGIN
                SET @Response += @Separator;
            END;
        END;
        SET @Response += @Character;
    END;
    
    RETURN @Response;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION [SDU_Tools].[AsciiOnly]
(
    @InputString nvarchar(max),
    @ReplacementCharacters varchar(10),
    @AreControlCharactersRemoved bit
)
RETURNS varchar(max)
AS
BEGIN

-- Function:      Removes or replaces all non-ASCII characters in a string
-- Parameters:    @InputString nvarchar(max) - String to be processed (unicode or single byte)
--                @ReplacementCharacters varchar(10) - Up to 10 characters to replace non-ASCII 
--                                                     characters with - can be blank
--                @AreControlCharactersRemoved bit - Should all control characters also be replaced
-- Action:        Finds all non-ASCII characters in a string and either removes or replaces them
-- Return:        varchar(max)
-- Refer to this video: https://youtu.be/0YFYPN0Bivo
--
-- Test examples: 
/*

SELECT SDU_Tools.AsciiOnly('Hello° There', '', 0);
SELECT SDU_Tools.AsciiOnly('Hello° There', '?', 0);
SELECT SDU_Tools.AsciiOnly('Hello° There' + CHAR(13) + CHAR(10) + ' John', '', 1);

*/

    DECLARE @Counter int = 1;
    DECLARE @ReturnValue varchar(max) = '';
    DECLARE @CharacterCode int;
    DECLARE @StringToProcess varchar(max) = @InputString; -- cast all unicode to single byte

    WHILE @Counter <= LEN(@StringToProcess)
    BEGIN
        SET @ReturnValue = @ReturnValue
                         + CASE WHEN ASCII(SUBSTRING(@StringToProcess, @Counter, 1)) BETWEEN 32 AND 127
                                THEN SUBSTRING(@StringToProcess, @Counter, 1)
                                WHEN ASCII(SUBSTRING(@StringToProcess, @Counter, 1)) < 127
                                AND @AreControlCharactersRemoved = 0
                                THEN SUBSTRING(@StringToProcess, @Counter, 1)
                                ELSE @ReplacementCharacters
                           END;
        SET @Counter = @Counter + 1;
    END;

    RETURN @ReturnValue;
END;
GO

--==================================================================================
-- Data Conversion Functions and Procedures
--==================================================================================

CREATE FUNCTION SDU_Tools.Base64ToVarbinary
(
    @Base64ValueToConvert varchar(max)
)
RETURNS varbinary(max)
AS
BEGIN
-- Function:      Converts a base 64 value to varbinary
-- Parameters:    @Base64ValueToConvert varchar(max)
-- Action:        Converts a base 64 value to varbinary
-- Return:        varbinary(max)
-- Refer to this video: https://youtu.be/k6yHYdHn7NA
--
-- Test examples: 
/*

SELECT SDU_Tools.Base64ToVarbinary('qrvM3e7/');

*/
    RETURN CAST('' as xml).value('xs:base64Binary(sql:variable("@Base64ValueToConvert"))', 'varbinary(max)');
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.CharToHexadecimal(@CharacterToConvert char(1))
RETURNS char(2)
AS
BEGIN

-- Function:      Converts a single character to a hexadecimal string
-- Parameters:    CharacterToConvert char(1)
-- Action:        Converts a single character to a hexadecimal string
-- Return:        char(2)
-- Refer to this video: https://youtu.be/aT4viskU7fE
--
-- Test examples: 
/*

SELECT SDU_Tools.CharToHexadecimal('A');
SELECT SDU_Tools.CharToHexadecimal('K');
SELECT SDU_Tools.CharToHexadecimal('1');

*/
    DECLARE @HexadecimalCharacters char(16) = '0123456789ABCDEF';
    DECLARE @AsciiCharacter int = ASCII(@CharacterToConvert);

    RETURN (SUBSTRING(@HexadecimalCharacters, (@AsciiCharacter / 16) + 1, 1)
           + SUBSTRING(@HexadecimalCharacters, (@AsciiCharacter % 16) + 1, 1));
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.SQLVariantInfo
(
    @SQLVariantValue SQL_variant 
)
RETURNS TABLE
AS
-- Function:      Returns information about a SQL_variant value
-- Parameters:    @SQLVariantValue SQL_variant
-- Action:        Returns information about a SQL_variant value
-- Return:        Rowset with BaseType, MaximumLength
-- Refer to this video: https://youtu.be/em62I-GBCEY
--
-- Test examples: 
/*

DECLARE @Value SQL_variant;
SET @Value = 'hello';
SELECT * FROM SDU_Tools.SQLVariantInfo(@Value);

*/
    RETURN (SELECT CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'BaseType') AS sysname) AS BaseType,
                   CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'Precision') AS int) AS Precision,
                   CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'Scale') AS int) AS Scale,
                   CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'TotalBytes') AS bigint) AS TotalBytes,
                   CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'Collation') AS sysname) AS Collation,
                   CAST(SQL_VARIANT_PROPERTY(@SQLVariantValue, 'MaxLength') AS int) AS MaximumLength);
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.VarbinaryToBase64
(
    @VarbinaryValueToConvert varbinary(max)
)
RETURNS varchar(max)
AS
BEGIN
-- Function:      Converts a varbinary value to base 64 encoding
-- Parameters:    @VarbinaryValueToConvert varbinary(max)
-- Action:        Converts a varbinary value to base 64 encoding
-- Return:        varchar(max)
-- Refer to this video: https://youtu.be/k6yHYdHn7NA
--
-- Test examples: 
/*

SELECT SDU_Tools.VarbinaryToBase64(0xAABBCCDDEEFF);

*/
    RETURN LTRIM(RTRIM(CAST('' as xml).value('xs:base64Binary(xs:hexBinary(sql:variable("@VarbinaryValueToConvert")))', 'varchar(max)')));
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.SecondsToDuration
(
    @NumberOfSeconds int
)
RETURNS varchar(8)
AS
BEGIN

-- Function:      Convert a number of seconds to a SQL Server duration string
-- Parameters:    @NumberOfSeconds int 
-- Action:        Converts a number of seconds to a SQL Server duration string (similar to programming identifiers)
--                The value must be less than 24 hours (between 0 and 86399) otherwise the return value is NULL
-- Return:        varchar(8)
-- Refer to this video: https://youtu.be/beANzSe1-jE
--
-- Test examples: 
/*

SELECT SDU_Tools.SecondsToDuration(910);   -- 15 minutes 10 seconds
SELECT SDU_Tools.SecondsToDuration(88000);   -- should return NULL

*/
    RETURN CASE WHEN @NumberOfSeconds BETWEEN 0 AND 86399 
                   THEN LEFT(CONVERT(varchar(20), DATEADD(second, @NumberOfSeconds, CAST(CAST(SYSDATETIME() AS date) AS datetime)), 14), 8)
                 END;
END;
GO

--==================================================================================
-- Scripting Utiltiies
--==================================================================================

CREATE FUNCTION SDU_Tools.FormatDataTypeName
( 
       @DataTypeName sysname,
       @Precision int,
       @Scale int,
       @MaximumLength int
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Converts data type components into an output string
-- Parameters:    @DataTypeName sysname - the name of the data type
--                @Precision int - the decimal or numeric precision
--                @Scale int - the scale for the value
--                @MaximumLength - the maximum length of string values
-- Action:        Converts data type, precision, scale, and maximum length
--                into the standard format used in scripts
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/Cn3jK3roWLg
-- Test examples: 
/*

SELECT SDU_Tools.FormatDataTypeName(N'decimal', 18, 2, NULL);
SELECT SDU_Tools.FormatDataTypeName(N'nvarchar', NULL, NULL, 12);
SELECT SDU_Tools.FormatDataTypeName(N'bigint', NULL, NULL, NULL);

*/
       RETURN LOWER(@DataTypeName) 
              + CASE WHEN LOWER(@DataTypeName) IN (N'decimal', N'numeric')
                  THEN N'(' + CAST(@Precision AS nvarchar(20)) + N', ' + CAST(@Scale AS nvarchar(20)) + N')'
                  WHEN LOWER(@DataTypeName) IN (N'varchar', N'nvarchar', N'char', N'nchar')
                  THEN N'(' + CASE WHEN @MaximumLength < 0 
                                   THEN N'max' 
                                   ELSE CAST(@MaximumLength AS nvarchar(20)) 
                              END + N')'
                  WHEN LOWER(@DataTypeName) IN (N'time', N'datetime2', N'datetimeoffset')
                  THEN N'(' + CAST(@Scale AS nvarchar(20)) + N')'
                  ELSE N''
             END;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ScriptDatabaseUsers
(
    @DatabaseName sysname,
    @ScriptOutput nvarchar(max) OUTPUT
)
AS
BEGIN

-- Function:      Scripts all database users (procedure)
-- Parameters:    @Database to script
-- Action:        Scripts all database users related to logins
-- Return:        Single column called ScriptOutput nvarchar(max)
-- Refer to this video: https://youtu.be/IbsUyfLh2Po
-- Test examples: 
/*

SET NOCOUNT ON;
DECLARE @SQL nvarchar(max);

EXEC SDU_Tools.ScriptDatabaseUsers N'WideWorldImporters', @SQL OUTPUT;

PRINT @SQL;

*/
    DECLARE @DatabaseUsers TABLE
    (
        DatabaseUserID int IDENTITY(1,1) PRIMARY KEY,
        LoginName sysname NULL,
        UserName sysname
    );
    
    DECLARE @SQL nvarchar(max) = N'
USE ' + QUOTENAME(@DatabaseName) + N'; 
SELECT sp.[name] AS LoginName, dp.[name] AS UserName
FROM sys.database_principals AS dp
LEFT OUTER JOIN sys.server_principals AS sp
    ON dp.sid = sp.sid                        
WHERE dp.[type_desc] IN (N''SQL_USER'', N''WINDOWS_USER'', N''WINDOWS_GROUP'')
AND dp.[name] <> N''dbo''
ORDER BY dp.[name];';

    INSERT @DatabaseUsers (LoginName, UserName)
    EXECUTE (@SQL);

    DECLARE @Counter int = 1;
    SET @SQL = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @LoginName sysname;
    DECLARE @UserName sysname;

    WHILE @Counter <= (SELECT MAX(DatabaseUserID) FROM @DatabaseUsers)
    BEGIN
        SELECT @LoginName = du.LoginName,
               @UserName = du.UserName 
        FROM @DatabaseUsers AS du 
        WHERE du.DatabaseUserID = @Counter;

        SET @SQL += N'CREATE USER ' + QUOTENAME(@UserName)
                  + N' FOR LOGIN ' + QUOTENAME(COALESCE(@LoginName, @UserName))
                  + N';' 
                  + @CrLf;

        SET @Counter += 1;
    END;

    SET @ScriptOutput = @SQL;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ExecuteOrPrint
@StringToExecuteOrPrint nvarchar(max),
@PrintOnly bit = 1,
@NumberOfCrLfBeforeGO int = 0,
@IncludeGO bit = 0,
@NumberOfCrLfAfterGO int = 0,
@BatchSeparator nvarchar(20) = N'GO'
AS BEGIN

-- Function:      Execute or Print One or More SQL Commands in a String
-- Parameters:    @StringToExecuteOrPrint nvarchar(max) -> String containing SQL commands
--                @PrintOnly bit = 1                    -> If set to 1 commands are printed only not executed
--                @NumberOfCrLfBeforeGO int = 0         -> Number of carriage return linefeeds added before the
--                                                         batch separator (normally GO)
--                @IncludeGO bit = 0                    -> If 1 the batch separator (normally GO) will be added
--                @NumberOfCrLfAfterGO int = 0          -> Number of carriage return linefeeds added after the
--                                                         batch separator (normally GO)
--                @BatchSeparator nvarchar(20) = N'GO'  -> Batch separator to use (defaults to GO)
-- Action:        Either prints the SQL code or executes it batch by batch.
-- Return:        int 0 on success
-- Refer to this video: https://youtu.be/cABGotl_yHY
--
-- Test examples: 
/*

DECLARE @SQL nvarchar(max) = N'SELECT ''Hello Greg'';';

EXEC SDU_Tools.ExecuteOrPrint @StringToExecuteOrPrint = @SQL,
                              @IncludeGO = 1,
                              @NumberOfCrLfAfterGO = 1;
SET @SQL = N'SELECT ''Another statement'';';

EXEC SDU_Tools.ExecuteOrPrint @StringToExecuteOrPrint = @SQL,
                              @IncludeGO = 1,
                              @NumberOfCrLfAfterGO = 1;

*/
    SET NOCOUNT ON;

    DECLARE @LineFeed nchar(1) = NCHAR(10);
    DECLARE @CarriageReturn nchar(1) = NCHAR(13);
    DECLARE @CrLf nchar(2) = @CarriageReturn + @LineFeed;
    
    DECLARE @RemainingString nvarchar(max) = REPLACE(SDU_Tools.TrimWhitespace(@StringToExecuteOrPrint), @LineFeed, N'');
    DECLARE @FullLine nvarchar(max);
    DECLARE @TrimmedLine nvarchar(max);
    DECLARE @StringToExecute nvarchar(max) = N'';
    DECLARE @NextLineEnd int;
    DECLARE @Counter int;

    WHILE LEN(@RemainingString) > 0
    BEGIN
        SET @NextLineEnd = CHARINDEX(@CarriageReturn, @RemainingString, 1);
        IF @NextLineEnd <> 0 -- more than one line left
        BEGIN
            SET @FullLine = RTRIM(SUBSTRING(@RemainingString, 1, @NextLineEnd - 1));
            PRINT @FullLine;
            SET @TrimmedLine = SDU_Tools.TrimWhitespace(@FullLine);
            IF @TrimmedLine = @BatchSeparator -- line just contains GO
            BEGIN
                SET @StringToExecute = SDU_Tools.TrimWhitespace(@StringToExecute);
                IF @StringToExecute <> N'' AND @PrintOnly = 0
                BEGIN
                    EXECUTE (@StringToExecute); -- Execute if non-blank
                END;
                SET @StringToExecute = N'';
            END ELSE BEGIN
                SET @StringToExecute += @CrLf + @FullLine;
            END;
            SET @RemainingString = RTRIM(SUBSTRING(@RemainingString, @NextLineEnd + 1, LEN(@RemainingString)));
        END ELSE BEGIN -- on the last line
            SET @FullLine = RTRIM(@RemainingString);
            PRINT @FullLine;
            SET @TrimmedLine = SDU_Tools.TrimWhitespace(@FullLine);
            IF @TrimmedLine <> @BatchSeparator -- not just a line with GO
            BEGIN
                SET @StringToExecute += @CrLf + @FullLine;
                SET @StringToExecute = SDU_Tools.TrimWhitespace(@StringToExecute);
                IF @StringToExecute <> N'' AND @PrintOnly = 0
                BEGIN
                    EXECUTE (@StringToExecute); -- Execute if non-blank
                END;
                SET @StringToExecute = N'';
            END;

            SET @RemainingString = N'';
        END;
    END;

    SET @Counter = 0;
    WHILE @Counter < @NumberOfCrLfBeforeGO
    BEGIN
        PRINT N' ';
        SET @Counter += 1;
    END;
    IF @IncludeGO <> 0 PRINT @BatchSeparator;

    SET @Counter = 0;
    WHILE @Counter < @NumberOfCrLfAfterGO
    BEGIN
        PRINT N' ';
        SET @Counter += 1;
    END;

END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ScriptServerPermissions
(
    @LoginsToScript nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Scripts all Server Permissions
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all server permissions for the selected logins
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- Test examples: 
/*

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerPermissions(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerPermissions(N'GregInternal,sa');
PRINT @SQL;
GO

*/
    DECLARE @ServerPermissions TABLE
    (
        ServerPermissionID int IDENTITY(1,1) PRIMARY KEY,
        LoginName sysname,
        PermissionName sysname
    );

    INSERT @ServerPermissions (LoginName, PermissionName)
    SELECT l.[name] AS LoginName,
           p.permission_name AS PermissionName 
    FROM sys.server_principals AS l
    INNER JOIN sys.server_permissions AS p
        ON l.principal_id = p.grantee_principal_id
    WHERE (@LoginsToScript = N'ALL' 
           OR l.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@LoginsToScript, N',', 1)))
    AND l.[type] IN ('G', 'S', 'U')
    AND p.[type] <> 'COSQ' -- don't want connect to SQL
    ORDER BY p.permission_name, l.[name];
    
    DECLARE @Counter int = 1;
    DECLARE @SQL nvarchar(max) = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @LoginName sysname;
    DECLARE @PermissionName sysname;

    WHILE @Counter <= (SELECT MAX(ServerPermissionID) FROM @ServerPermissions)
    BEGIN
        SELECT @LoginName = sp.LoginName,
               @PermissionName = sp.PermissionName 
        FROM @ServerPermissions AS sp 
        WHERE sp.ServerPermissionID = @Counter;

        SET @SQL += N'GRANT ' + @PermissionName
                  + N' TO ' + QUOTENAME(@LoginName)
                  + N';' 
                  + @CrLf;

        SET @Counter += 1;
    END;

    RETURN @SQL;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ScriptServerRoleMembers
(
    @LoginsToScript nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Scripts all Server Role Members
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all server role members for the selected logins
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- Test examples: 
/*

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerRoleMembers(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerRoleMembers(N'GregInternal,sa');
PRINT @SQL;
GO

*/
    DECLARE @RoleMembers TABLE
    (
        RoleMemberID int IDENTITY(1,1) PRIMARY KEY,
        LoginName sysname,
        RoleName sysname
    );

    INSERT @RoleMembers (LoginName, RoleName)
    SELECT l.[name] AS LoginName,
           r.[name] AS RoleName 
    FROM sys.server_principals AS l
    INNER JOIN sys.server_role_members AS srm
        ON l.principal_id = srm.member_principal_id
    INNER JOIN sys.server_principals AS r
        ON srm.role_principal_id = r.principal_id
    WHERE @LoginsToScript = N'ALL' 
    OR l.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@LoginsToScript, N',', 1))
    ORDER BY l.[name], r.[name];
    
    DECLARE @Counter int = 1;
    DECLARE @SQL nvarchar(max) = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @LoginName sysname;
    DECLARE @RoleName sysname;

    WHILE @Counter <= (SELECT MAX(RoleMemberID) FROM @RoleMembers)
    BEGIN
        SELECT @LoginName = rm.LoginName,
               @RoleName = rm.RoleName 
        FROM @RoleMembers AS rm 
        WHERE rm.RoleMemberID = @Counter;

        SET @SQL += N'ALTER SERVER ROLE ' + QUOTENAME(@RoleName)
                  + N' ADD MEMBER ' + QUOTENAME(@LoginName)
                  + N';' 
                  + @CrLf;

        SET @Counter += 1;
    END;

    RETURN @SQL;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ScriptSQLLogins
(
    @LoginsToScript nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Scripts all SQL Logins
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all specified SQL logins, with password hashes, security IDs, default 
--                databases and languages
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- Test examples: 
/*

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptSQLLogins(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptSQLLogins(N'GregInternal,sa');
PRINT @SQL;
GO

*/
    DECLARE @Logins TABLE
    (
        LoginID int IDENTITY(1,1) PRIMARY KEY,
        LoginName sysname,
        PasswordHash varbinary(256),
        SID varbinary(85),
        DefaultDatabaseName sysname,
        DefaultLanguageName sysname,
        IsPolicyChecked bit
    );

    INSERT @Logins (LoginName, PasswordHash, SID, DefaultDatabaseName, DefaultLanguageName, IsPolicyChecked)
    SELECT l.[name], l.password_hash, l.sid, l.default_database_name, l.default_language_name, l.is_policy_checked
    FROM master.sys.SQL_logins AS l
    WHERE @LoginsToScript = N'ALL' 
    OR l.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@LoginsToScript, N',', 1))
    ORDER BY l.[name];

    DECLARE @Counter int = 1;
    DECLARE @SQL nvarchar(max) = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @LoginName sysname;
    DECLARE @PasswordHash varbinary(256);
    DECLARE @SID varbinary(85);
    DECLARE @DefaultDatabaseName sysname;
    DECLARE @DefaultLanguageName sysname;
    DECLARE @IsPolicyChecked bit;

    WHILE @Counter <= (SELECT MAX(LoginID) FROM @Logins)
    BEGIN
        SELECT @LoginName = l.LoginName,
               @PasswordHash = l.PasswordHash,
               @SID = l.SID,
               @DefaultDatabaseName = l.DefaultDatabaseName,
               @DefaultLanguageName = l.DefaultLanguageName,
               @IsPolicyChecked = l.IsPolicyChecked
        FROM @Logins AS l 
        WHERE l.LoginID = @Counter;

        SET @SQL += N'CREATE LOGIN ' + QUOTENAME(@LoginName)
                  + N' WITH PASSWORD = ' + sys.fn_varbintohexstr(@PasswordHash)
                  + N' HASHED, SID = ' + sys.fn_varbintohexstr(@SID)
                  + N', DEFAULT_DATABASE = ' + QUOTENAME(@DefaultDatabaseName)
                  + N', DEFAULT_LANGUAGE = ' + QUOTENAME(@DefaultLanguageName) 
                  + N', CHECK_POLICY = ' + CASE WHEN @IsPolicyChecked <> 0 THEN N'ON' ELSE N'OFF' END
                  + N';' 
                  + @CrLf;

        SET @Counter += 1;
    END;

    RETURN @SQL;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ScriptWindowsLogins
(
    @LoginsToScript nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Scripts all Windows Logins
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all specified Windows logins, with default databases and languages
-- Return:        nvarchar(max)
-- Refer to this video: https://youtu.be/pszTHe2PhVQ
--
-- Test examples: 
/*

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptWindowsLogins(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptWindowsLogins(N'NT AUTHORITY\SYSTEM,NT SERVICE\SQLWriter');
PRINT @SQL;
GO

*/
    DECLARE @Logins TABLE
    (
        LoginID int IDENTITY(1,1) PRIMARY KEY,
        LoginName sysname,
        DefaultDatabaseName sysname,
        DefaultLanguageName sysname
    );

    INSERT @Logins (LoginName, DefaultDatabaseName, DefaultLanguageName)
    SELECT sp.[name], sp.default_database_name, sp.default_language_name
    FROM master.sys.server_principals AS sp
    WHERE sp.[type] IN ('U', 'G') 
    AND (@LoginsToScript = N'ALL' 
         OR sp.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@LoginsToScript, N',', 1)))
    ORDER BY sp.[name];
    
    DECLARE @Counter int = 1;
    DECLARE @SQL nvarchar(max) = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @LoginName sysname;
    DECLARE @DefaultDatabaseName sysname;
    DECLARE @DefaultLanguageName sysname;

    WHILE @Counter <= (SELECT MAX(LoginID) FROM @Logins)
    BEGIN
        SELECT @LoginName = l.LoginName,
               @DefaultDatabaseName = l.DefaultDatabaseName,
               @DefaultLanguageName = l.DefaultLanguageName
        FROM @Logins AS l 
        WHERE l.LoginID = @Counter;

        SET @SQL += N'CREATE LOGIN ' + QUOTENAME(@LoginName)
                  + N' FROM WINDOWS WITH DEFAULT_DATABASE = ' + QUOTENAME(@DefaultDatabaseName)
                  + N', DEFAULT_LANGUAGE = ' + QUOTENAME(@DefaultLanguageName) 
                  + N';' 
                  + @CrLf;

        SET @Counter += 1;
    END;

    RETURN @SQL;
END;
GO

--==================================================================================
-- PerformanceTuning Utiltiies
--==================================================================================

CREATE FUNCTION SDU_Tools.DeExecuteSQLString
( 
    @InputSQL nvarchar(max),
    @EmbedParameters bit,
    @IncludeVariableDeclarations bit 
)
RETURNS nvarchar(max)
AS
BEGIN

-- Function:      Locates the command and reorganizes parameters from within an sp_executeSQL string
-- Parameters:    @InputSQL nvarchar(max)          -> Captured sp_executeSQL string
--                @EmbedParameters bit             -> If 1, parameters are re-embedded into the SQL
--                                                    (this is usually best for performance tuning)
--                @IncludeVariableDeclarations bit -> If not embedding parameters, should they be
--                                                    converted to variables (easier to work with 
--                                                    but not as good for performance tuning)
-- Action:        Assist with debugging and performance troubleshooting of sp_executeSQL commands. 
--                Takes a valid exec sp_executeSQL string (like captured in Profiler or Extended
--                Events) and extracts the embedded command from within it. Optionally, can 
--                extract the parameters and either embed them directly back into the code, or 
--                create them as variable declarations
-- Return:        nvarchar(max) output SQL
-- Test examples: 
/*

SELECT SDU_Tools.DeExecuteSQLString('blah', 0, 0); -- should return invalid input query
SELECT SDU_Tools.DeExecuteSQLString('exec sp_executeSQL N''some query goes here''', 0, 1);
SELECT SDU_Tools.DeExecuteSQLString('exec sp_executeSQL N''some query goes here with a parameter @range'',N''@range varchar(10)'',@range = N''hello''', 0, 1);

*/
    DECLARE @MaximumParametersPerQuery int = 1000;
    DECLARE @SQL nvarchar(max) = SDU_Tools.TrimWhitespace(@InputSQL);
    DECLARE @ReturnValue nvarchar(max) = N'';
    DECLARE @ErrorHasOccurred bit = 0;
    DECLARE @ParameterStart int;
    DECLARE @EqualsLocation int;
    DECLARE @SpaceLocation int;
    DECLARE @QuoteLocation int;
    DECLARE @FoundAllParameters bit = 0;
    DECLARE @ParameterDeclaration nvarchar(max);
    DECLARE @NumberOfParameters int = 0;
    DECLARE @NumberOfParameterDataTypesFound int = 0;
    DECLARE @LocatedParameterName nvarchar(max);
    DECLARE @LocatedParameterDataType nvarchar(max);
    DECLARE @MaximumParameterNameLength int;
    DECLARE @DebugErrorReason nvarchar(max) = N'';
    DECLARE @Counter int;
    DECLARE @LengthCounter int;
    DECLARE @Parameters TABLE ( ParameterNumber int,
                                ParameterName nvarchar(max),
                                ParameterValue nvarchar(max),
                                ParameterDatatype nvarchar(max)
                              );

    -- Extract the trailing parameter list

    WHILE (@FoundAllParameters = 0) AND (@NumberOfParameters < @MaximumParametersPerQuery) AND (@ErrorHasOccurred = 0)
    BEGIN
        IF RIGHT(@SQL, 1) = N','
        BEGIN
            SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);
        END;
        SET @ParameterStart = SDU_Tools.LastParameterStartPosition(@SQL);
        IF @ParameterStart < 0
        BEGIN
            SET @FoundAllParameters = 1;
        END ELSE BEGIN
            SET @ParameterDeclaration = SDU_Tools.TrimWhitespace(SUBSTRING(@SQL, @ParameterStart, LEN(@SQL) - @ParameterStart + 1));
            SET @EqualsLocation = CHARINDEX(N'=', @ParameterDeclaration);
            IF @EqualsLocation < 1
            BEGIN
                SET @ErrorHasOccurred = 1;
                SET @DebugErrorReason += N'Equals not located in trailing parameter list processing, ';
            END ELSE BEGIN
                SET @NumberOfParameters += 1;
                INSERT @Parameters ( ParameterNumber, ParameterName, ParameterValue )
                VALUES ( @NumberOfParameters, 
                         SDU_Tools.TrimWhitespace(SUBSTRING(@ParameterDeclaration, 1, @EqualsLocation - 1)),
                         SDU_Tools.TrimWhitespace(SUBSTRING(@ParameterDeclaration, @EqualsLocation + 1, 
                                                      LEN(@ParameterDeclaration) - @EqualsLocation)));
                SET @SQL = LEFT(@SQL, @ParameterStart - 1);                                      
            END;
        END;
    END;

    -- Remove trailing quote which should be present

    IF @ErrorHasOccurred = 0 
    BEGIN
        IF RIGHT(@SQL, 1) <> N''''
        BEGIN
            SET @ErrorHasOccurred = 1;
            SET @DebugErrorReason += N'Trailing quote not located, ';
        END ELSE BEGIN
            SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);
        END;
    END;

    -- Next locate the data types

    IF @ErrorHasOccurred = 0
    BEGIN
        SET @FoundAllParameters = 0;
        WHILE @FoundAllParameters = 0 AND @ErrorHasOccurred = 0 AND @NumberOfParameterDataTypesFound < @NumberOfParameters 
        BEGIN
            IF RIGHT(@SQL, 1) = N','
                BEGIN
                SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);
            END;
            SET @ParameterStart = SDU_Tools.LastParameterStartPosition(@SQL);
            IF @ParameterStart < 0
            BEGIN
                SET @FoundAllParameters = 1;
            END ELSE BEGIN
                SET @ParameterDeclaration = SDU_Tools.TrimWhitespace(SUBSTRING(@SQL, @ParameterStart, LEN(@SQL) - @ParameterStart + 1));
                SET @ParameterDeclaration = REPLACE(REPLACE(@ParameterDeclaration, N',', N''), N'''', N'');
                SET @SpaceLocation = CHARINDEX(N' ', @ParameterDeclaration);
                IF @SpaceLocation <= 0
                BEGIN
                    SET @ErrorHasOccurred = 1;
                    SET @DebugErrorReason += N'Space not located in data type search, ';
                END ELSE BEGIN
                    SET @LocatedParameterName = SDU_Tools.TrimWhitespace(LEFT(@ParameterDeclaration, @SpaceLocation - 1));
                    SET @LocatedParameterDataType = SDU_Tools.TrimWhitespace(SUBSTRING(@ParameterDeclaration, 
                                                                                 @SpaceLocation + 1, 
                                                                                 LEN(@ParameterDeclaration) - @SpaceLocation + 1));
                    UPDATE @Parameters 
                        SET ParameterDatatype = @LocatedParameterDataType 
                        WHERE ParameterName = @LocatedParameterName;
                    SET @SQL = SDU_Tools.TrimWhitespace(LEFT(@SQL, @ParameterStart - 1));
                    SET @NumberOfParameterDataTypesFound += 1;
                END;
            END;
        END;

        IF EXISTS(SELECT 1 FROM @Parameters WHERE ParameterDatatype IS NULL)
        BEGIN
            SET @ErrorHasOccurred = 1;
            SET @DebugErrorReason += N'Not all parameter data types located, ';
        END;
    END;

    -- Remove beginning of query, then tidy up the tail end 
    -- then replace double quotes in queries with single

    IF @ErrorHasOccurred = 0
    BEGIN
        SET @QuoteLocation = CHARINDEX(N'''', @SQL);
        IF @QuoteLocation <= 0
        BEGIN
            SET @ErrorHasOccurred = 1;
            SET @DebugErrorReason += N'No leading quote found, ';
        END ELSE BEGIN
            SET @SQL = SUBSTRING(@SQL, @QuoteLocation + 1, LEN(@SQL) - @QuoteLocation);
            IF RIGHT(@SQL, 2) = N'N'''
            BEGIN
                SET @SQL = SDU_Tools.TrimWhitespace(LEFT(@SQL, LEN(@SQL) - 2));
            END;
            IF RIGHT(@SQL, 1) = ','
            BEGIN
                SET @SQL = SDU_Tools.TrimWhitespace(LEFT(@SQL, LEN(@SQL) - 1));
            END;
            IF RIGHT(@SQL, 1) = ''''
            BEGIN
                SET @SQL = SDU_Tools.TrimWhitespace(LEFT(@SQL, LEN(@SQL) - 1));
            END;
        END
        SET @SQL = SDU_Tools.TrimWhitespace(REPLACE(@SQL, '''''',''''));
    END;

    IF @ErrorHasOccurred = 0
    BEGIN
        IF @EmbedParameters = 0
        BEGIN
            IF @IncludeVariableDeclarations = 1
            BEGIN
                SET @Counter = 1;
                WHILE @Counter <= @NumberOfParameters 
                BEGIN
                    SET @ReturnValue = @ReturnValue 
                                     + N'DECLARE '
                                     + (SELECT ParameterName FROM @Parameters WHERE ParameterNumber = @Counter)
                                     + N' '
                                     + (SELECT ParameterDataType FROM @Parameters WHERE ParameterNumber = @Counter)
                                     + N' = '
                                     + (SELECT ParameterValue FROM @Parameters WHERE ParameterNumber = @Counter)
                                     + N';'
                                     + NCHAR(13) + NCHAR(10);
                    SET @Counter += 1;
                END;
                SET @ReturnValue = SDU_Tools.TrimWhitespace(@ReturnValue 
                                                                + ' ' 
                                                                + NCHAR(13) + NCHAR(10)
                                                                + @SQL);
            END ELSE BEGIN
                SET @ReturnValue = SDU_Tools.TrimWhitespace(@SQL);
            END;
        END ELSE BEGIN
            -- Need to substitute parameter names but must do this in descending length order
            SET @MaximumParameterNameLength = (SELECT MAX(LEN(ParameterName)) FROM @Parameters);
            SET @LengthCounter = @MaximumParameterNameLength;
            WHILE @LengthCounter > 0
            BEGIN
                SET @Counter = @NumberOfParameters;
                WHILE @Counter >= 0
                BEGIN
                    IF EXISTS(SELECT 1 FROM @Parameters WHERE ParameterNumber = @Counter 
                                                        AND LEN(ParameterName) = @LengthCounter)
                    BEGIN
                        SET @SQL = REPLACE(@SQL,
                                           (SELECT ParameterName FROM @Parameters WHERE ParameterNumber = @Counter),
                                           (SELECt ParameterValue FROM @Parameters WHERE ParameterNumber = @Counter));
                    END;
                    SET @Counter -= 1;
                END;
                SET @LengthCounter -= 1;
            END;
            SET @ReturnValue = SDU_Tools.TrimWhitespace(@SQL);
        END;
    END ELSE BEGIN
        SET @ReturnValue = N'Invalid input query';
    END;

    RETURN @ReturnValue;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.ExtractSQLTemplate
(
    @InputCommand nvarchar(max),
    @MaximumReturnLength int
)
RETURNS nvarchar(max)
AS 
BEGIN

-- Function:      Extracts a query template from a SQL command string
-- Parameters:    @InputCommand nvarchar(max)      -> SQL Command (likely captured from Profiler 
--                                                    or Extended Events)
--                @MaximumReturnLength int         -> Limits the number of characters returned
-- Action:        Normalizes a SQL Server command, mostly for helping with performance tuning 
--                work. It extracts the underlying template of the command. If the command 
--                includes an exec sp_executeSQL statement, it tries to undo that statement 
--                as well. It will not be able to do so if that isn't the last statement 
--                in the batch being processed. Works even on invalid SQL syntax
-- Return:        nvarchar(max) output templated SQL
-- Refer to this video: https://youtu.be/yX5q00m_uCA
--
-- Test examples: 
/*

SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where customerid = 12 and customername = ''fred'' order by customerid;', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where customerid = 12', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select (2+2);', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where sid = 0x12AEBCDEF2342AE2', 4000);

*/
    DECLARE @ReturnValue nvarchar(max) = N'';
    DECLARE @DecimalSeparator nvarchar(1) = N'.';
    DECLARE @StringToken nvarchar(1) = N'$';
    DECLARE @NumberToken nvarchar(1) = N'#';
    DECLARE @BinaryToken nvarchar(1) = N'B';

    DECLARE @CurrentPosition int = 1;
    DECLARE @CurrentCharacter nvarchar(1) = N'';
    DECLARE @PreviousCharacter nvarchar(1) = N'';
    DECLARE @LastTwoCharacters nvarchar(2) = N'';
    DECLARE @NextCharacter nvarchar(1) = N'';
    DECLARE @InAString bit = 0;
    DECLARE @InANumber bit = 0;
    DECLARE @InABinaryNumber bit = 0;

    DECLARE @InputSQL varchar(max) = SDU_Tools.TrimWhitespace(@InputCommand);
    DECLARE @InputLength int = LEN(@InputSQL);
    DECLARE @SPExecuteSQLLocation int = 0;
    DECLARE @SPExecuteSQL varchar(max) = N'';
    DECLARE @IsValidSPExecuteSQL bit = 0;

    SET @SPExecuteSQLLocation = CHARINDEX('sp_executeSQL', @InputSQL);

    IF @SPExecuteSQLLocation > 0 
    BEGIN
        SET @SPExecuteSQL = SUBSTRING(@InputSQL, @SPExecuteSQLLocation, @InputLength - @SPExecuteSQLLocation + 1);
        SET @SPExecuteSQL = SDU_Tools.DeExecuteSQLString(@SPExecuteSQL, 0, 0);
        IF @SPExecuteSQL <> N'Invalid input query'
        BEGIN
           SET @IsValidSPExecuteSQL = 1;
           SET @ReturnValue = @SPExecuteSQL;
        END;
    END;

    IF @IsValidSPExecuteSQL = 0
    BEGIN -- if not an sp_executeSQL command that could be processed
        WHILE @CurrentPosition <= @InputLength 
        BEGIN
            SET @CurrentCharacter = SUBSTRING(@InputCommand, @CurrentPosition, 1);
            IF @CurrentPosition > 1 SET @PreviousCharacter = SUBSTRING(@InputCommand, @CurrentPosition - 1, 1);
            IF @CurrentPosition > 2 SET @LastTwoCharacters = SUBSTRING(@InputCommand, @CurrentPosition - 2, 2);
            IF @CurrentPosition < @InputLength SET @NextCharacter = SUBSTRING(@InputCommand, @CurrentPosition + 1, 1) ELSE SET @NextCharacter = N'';

            IF @InAString = 1
            BEGIN
                IF @CurrentCharacter = N'''' 
                BEGIN -- processing a single quote = end of string or double quote
                    IF @CurrentPosition < @InputLength AND @NextCharacter = N'''' 
                    BEGIN -- double quote so skip both chars
                        SET @CurrentPosition += 1;
                    END ELSE BEGIN -- end of a string
                        SET @ReturnValue = @ReturnValue + @StringToken;
                        SET @InAString = 0;
                    END;
                END;
             END ELSE BEGIN -- of if not in a string
                IF @CurrentCharacter = N'''' 
                BEGIN
                    SET @InAString = 1;
                END ELSE BEGIN
                    IF @InANumber = 1
                    BEGIN -- we are in a number
                        IF @CurrentCharacter NOT BETWEEN N'0' AND N'9' AND @CurrentCharacter <> @DecimalSeparator 
                        BEGIN -- no longer in a number
                            SET @InANumber = 0;
                            SET @ReturnValue = @ReturnValue + @NumberToken + @CurrentCharacter;
                        END;
                    END ELSE BEGIN -- of if not in a number
                        IF @InABinaryNumber = 1
                        BEGIN
                            IF @CurrentCharacter NOT BETWEEN N'0' AND N'9' AND @CurrentCharacter NOT BETWEEN N'A' AND N'F'
                            BEGIN -- no longer in a binary number
                                SET @InABinaryNumber = 0;
                                  SET @ReturnValue = @ReturnValue + @BinaryToken + @CurrentCharacter;
                            END;
                        END ELSE BEGIN -- of if not in a number or a binary number
                            IF @LastTwoCharacters = N'0x' AND (@CurrentCharacter BETWEEN N'0' AND N'9'
                                                               OR @CurrentCharacter BETWEEN N'A' AND N'F')
                            BEGIN
                                SET @InABinaryNumber = 1;
                            END ELSE BEGIN -- not the start of a binary number
                                IF @CurrentCharacter BETWEEN N'0' AND N'9' OR @CurrentCharacter = @DecimalSeparator
                                BEGIN -- start of a number if previous character is space, minus, plus, bracket, separator or equals
                                    IF @PreviousCharacter IN (N' ', N'-', N'+', N'(', N'=', @DecimalSeparator)
                                        AND NOT (@CurrentCharacter = N'0' AND @NextCharacter = N'x')
                                    BEGIN
                                        SET @InANumber = 1;
                                    END ELSE BEGIN -- possibly just another part of an identifier
                                        SET @ReturnValue = @ReturnValue + @CurrentCharacter;
                                    END;
                                END ELSE BEGIN -- any old character
                                       SET @ReturnValue = @ReturnValue + @CurrentCharacter;
                                END;
                            END;
                        END;
                    END;
                END;
            END;
            SET @CurrentPosition += 1;
        END;
    END;

    IF @InANumber = 1 
    BEGIN -- might be still in the middle of a number
        SET @ReturnValue = @ReturnValue + @NumberToken;
    END;

    IF @InABinaryNumber = 1
    BEGIN -- might be still in the middle of a binary number
        SET @ReturnValue = @ReturnValue + @BinaryToken;
    END;

    RETURN LEFT(@ReturnValue, @MaximumReturnLength);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.LastParameterStartPosition
( 
    @StringToTest nvarchar(max) 
)
RETURNS int
AS
BEGIN

-- Function:      Locates the starting position of the last parameter in an sp_executeSQL string
-- Parameters:    @StringToTest nvarchar(max)
-- Action:        Starts at the end of the string and finds the last location where
--                a parameter is defined, based on @ characters.
-- Return:        int location of where the last parameter in the command starts
-- Test examples: 
/*

DECLARE @TestString nvarchar(max) 
    = 'exec sp_executeSQL N''SELECT something FROM somewhere
                             WHERE somethingelse = @range
                                AND somedate = @date 
                             AND someteam = @team'''
                             + ',N''@range nvarchar(5),@date datetime,@team nvarchar(27)'''
                             + ',@range=N''month'',@date=''2014-10-01 00:00:00'',@team=N''Test team''';

SELECT SDU_Tools.LastParameterStartPosition(@TestString); -- should be 281

*/
    DECLARE @PositionToReturn int = -1;
    DECLARE @Counter int = LEN(@StringToTest);
    DECLARE @NextCharacter nvarchar(1);
    DECLARE @InAString bit = 0;

    WHILE (@Counter > 0) AND (@PositionToReturn = -1)
    BEGIN
        SET @NextCharacter = SUBSTRING(@StringToTest, @Counter, 1);
        IF @NextCharacter = N'''' 
        BEGIN
            IF @InAString = 1 
            BEGIN
                SET @InAString = 0;
            END ELSE BEGIN
                SET @InAString = 1;
            END;
        END ELSE BEGIN
            IF @NextCharacter = N'@' AND @InAString = 0
            BEGIN
                IF SDU_Tools.PreviousNonWhitespaceCharacter(@StringToTest, @Counter) <> N'='
                BEGIN
                    SET @PositionToReturn = @Counter;
                END;
            END;
        END;
        SET @Counter -= 1;
    END;

    RETURN @PositionToReturn;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.CapturePerformanceTuningTrace
@DurationInMinutes int = 15,  
@TraceFileName nvarchar(256) = N'SDU_Trace',
@OutputFolderName nvarchar(256) = N'C:\Temp',
@DatabasesToCheck nvarchar(max) = N'ALL',
@MaximumFileSizeMB int = 4096
AS
BEGIN

-- Function:      Captures a performance tuning trace file
-- Parameters:    @DurationInMinutes -- (default is 15 minutes) Length of time the trace should run for
--                @TraceFileName -- (default is SDU_Trace) Name of the output trace file (.trc will be added if not present)
--                @OutputFolderName -- (default is C:\Temp) Name of the folder that the trace file will be created in
--                @DatabasesToCheck -- either ALL (default) or a comma-delimited list of database names
--                                     Note that if database level filtering is used (ie: not the value ALL) then
--                                     the trace will filter queries executed in the context of the database, not those
--                                     accessing the database from another context
--                @MaximumFileSizeMB -- (default is 4096) Maximum size of the trace file 
-- Action:        Captures a performance tuning trace file then terminates
-- Return:        Status (0 = success)
-- Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- Test examples: 
/*

EXEC SDU_Tools.CapturePerformanceTuningTrace @DurationInMinutes = 2,
                                             @TraceFileName = N'SDU_Trace',
                                             @OutputFolderName = N'C:\Temp',
                                             @DatabasesToCheck = N'WideWorldImporters,WideWorldImportersDW',
                                             @MaximumFileSizeMB = 8192;

*/

    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @OutputFileName nvarchar(256);
    DECLARE @ReturnValue int = 0;
    DECLARE @MaximumFileSize bigint = @MaximumFileSizeMB * 1024;
    DECLARE @TraceID int;
    DECLARE @Counter int;
    DECLARE @DatabaseName sysname;
    DECLARE @DatabaseFilter sysname;
    DECLARE @DurationValue varchar(8) = SDU_Tools.SecondsToDuration(@DurationInMinutes * 60);

    DECLARE @RPC_COMPLETED int = 10;
    DECLARE @SQL_BATCH_COMPLETED int = 12;

    DECLARE @TEXT_DATA int = 1;
    DECLARE @APPLICATION_NAME int = 10;
    DECLARE @SPID int = 12;
    DECLARE @DURATION int = 13;
    DECLARE @START_TIME int = 14;
    DECLARE @READS int = 16;
    DECLARE @WRITES int = 17;
    DECLARE @CPU int = 18;
    DECLARE @DATABASE_NAME int = 35;

    DECLARE @ON int = 1;
    
    DECLARE @OR int = 1;
    DECLARE @LIKE int = 6;

    DECLARE @STOP int = 0;
    DECLARE @START int = 1;
    DECLARE @CLOSE_AND_DELETE int = 2;

    DECLARE @CRLF nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @Databases TABLE
    (
        DatabaseEntryID int IDENTITY(1,1) PRIMARY KEY,
        DatabaseName sysname
    );

    SET @OutputFileName = LTRIM(RTRIM(@OutputFolderName)) + CASE WHEN RIGHT(@OutputFolderName, 1) <> N'\' THEN N'\' ELSE N'' END 
                        + LTRIM(RTRIM(@TraceFilename));

    IF RIGHT(@TraceFileName, 4) = N'.trc' 
    BEGIN
        SET @OutputFileName = LEFT(@OutputFileName, LEN(@OutputFileName) - 4);
    END;

    IF @DurationValue IS NULL
    BEGIN
        PRINT 'Invalid duration in minutes - must be less than 24 hours';
        SET @ReturnValue = -1;
    END ELSE BEGIN
        EXEC @ReturnValue = sp_trace_create @traceid = @TraceID OUTPUT, 
                                            @options = 0, 
                                            @tracefile = @OutputFilename, 
                                            @maxfilesize = @MaximumFileSize, 
                                            @stoptime = NULL; 
    END;

    IF @ReturnValue <> 0
    BEGIN
        PRINT N'Unable to create the trace to output file: ' + @OutputFileName + @CRLF + N'Error returned was: '
              + CASE @ReturnValue WHEN 1 THEN N'Unknown error'
                                  WHEN 10 THEN N'Invalid or incompatible options'
                                  WHEN 12 THEN N'Cannot create output file'
                                  WHEN 13 THEN N'Out of memory'
                                  WHEN 14 THEN N'Invalid stop time'
                                  WHEN 15 THEN N'Invalid parameters'
                                  ELSE N''
                END;
        SET @ReturnValue = -1;
    END ELSE BEGIN

        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @TEXT_DATA, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @APPLICATION_NAME, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @SPID, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @DURATION, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @START_TIME, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @READS, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @WRITES, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @CPU, @ON;
        EXEC sp_trace_setevent @TraceID, @RPC_COMPLETED, @DATABASE_NAME, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @TEXT_DATA, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @APPLICATION_NAME, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @SPID, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @DURATION, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @START_TIME, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @READS, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @WRITES, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @CPU, @ON;
        EXEC sp_trace_setevent @TraceID, @SQL_BATCH_COMPLETED, @DATABASE_NAME, @ON;

        IF LEN(@DatabasesToCheck) > 0 AND @DatabasesToCheck <> N'ALL'
        BEGIN
            INSERT @Databases (DatabaseName)
            SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@DatabasesToCheck, N',', 1);

            SET @Counter = 1;
            WHILE @Counter <= (SELECT MAX(DatabaseEntryID) FROM @Databases)
            BEGIN
                SET @DatabaseName = (SELECT DatabaseName FROM @Databases WHERE DatabaseEntryID = @Counter);
                SET @Counter += 1;
                SET @DatabaseFilter = N'%' + @DatabaseName + N'%';
                EXEC sp_trace_setfilter @TraceID, @DATABASE_NAME, @OR, @LIKE, @DatabaseFilter;
            END;
        END;

        EXEC sp_trace_setstatus @TraceID, @START;

        WAITFOR DELAY @DurationValue;

        EXEC sp_trace_setstatus @traceID = @TraceID, @status = @STOP;
        EXEC sp_trace_setstatus @traceID = @TraceID, @status = @CLOSE_AND_DELETE;
        
    END;

    RETURN @ReturnValue;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.LoadPerformanceTuningTrace
@TraceFileName nvarchar(256) = N'SDU_Trace',
@TraceFileFolderName nvarchar(256) = N'C:\Temp',
@ExportDatabaseName sysname = NULL,
@ExportSchemaName sysname = N'dbo',
@ExportTableName sysname = NULL,
@IncludeNormalizedCommand bit = 1,
@IgnoreSPReset bit = 1
AS
BEGIN

-- Function:      Loads a performance tuning trace file
-- Parameters:    @TraceFileName nvarchar(256) -- (default is SDU_Trace) Name of the output trace file (.trc will be added if not present)
--                @TraceFileFolderName nvarchar(256) -- (default is C:\Temp) Name of the folder that the trace file will be created in
--                @ExportDatabaseName sysname -- (default is current database) Database to load the trace file into
--                @ExportSchemaName sysname -- (default is dbo) Schema for the table to load the trace file into
--                @ExportTableName sysname -- (default is the trace file name) Table to load the trace file into (must not already exist)
--                @IncludeNormalizedCommand bit -- (default is 1) Should a normalized command be added to the trace (takes time)
--                @IgnoreSPReset bit -- (default is 1) Should sp_reset commands be ignored
-- Action:        Loads a performance tuning trace file and optionally normalizes the queries in it
-- Return:        Status (0 = success)
-- Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- Test examples: 
/*

EXEC SDU_Tools.LoadPerformanceTuningTrace @TraceFileName = N'SDU_Trace',
                                          @TraceFileFolderName = N'C:\Temp',
                                          @ExportDatabaseName = N'Development',
                                          @ExportSchemaName = N'dbo',
                                          @ExportTableName = N'SDU_Trace',
                                          @IncludeNormalizedCommand = 1,
                                          @IgnoreSPReset = 1;

*/

    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @TraceFileToLoad nvarchar(256);
    DECLARE @ReturnValue int = 0;
    DECLARE @SQL nvarchar(max);

    SET @TraceFileToLoad = LTRIM(RTRIM(@TraceFileFolderName)) + CASE WHEN RIGHT(@TraceFileFolderName, 1) <> N'\' THEN N'\' ELSE N'' END 
                         + LTRIM(RTRIM(@TraceFilename));

    IF RIGHT(@TraceFileName, 4) <> N'.trc' 
    BEGIN
        SET @TraceFileToLoad = @TraceFileToLoad + N'.trc';
    END;

    IF @ExportTableName IS NULL 
    BEGIN
        SET @ExportTableName = @TraceFileName;
    END;

    BEGIN TRY

        SET @SQL = N'
SELECT ROW_NUMBER() OVER (ORDER BY t.StartTime) AS RowNumber,
       CAST(TextData AS nvarchar(max)) AS TextData,
         t.Reads,
         t.Writes,
         t.Duration,
         t.CPU,
         t.StartTime,
         t.SPID, 
         t.ApplicationName, 
' + CASE WHEN @IncludeNormalizedCommand <> 0 THEN N'         SDU_Tools.ExtractSQLTemplate(t.TextData, 4000) AS Command' ELSE N'' END + N'
INTO ' + CASE WHEN @ExportDatabaseName IS NOT NULL THEN QUOTENAME(@ExportDatabaseName) + N'.' ELSE N'' END
       + QUOTENAME(@ExportSchemaName) + N'.' + QUOTENAME(@ExportTableName) + N'
FROM sys.fn_trace_gettable(''' + @TraceFileToLoad + ''', NULL) AS t
WHERE t.TextData IS NOT NULL
AND t.Reads IS NOT NULL
AND t.Writes IS NOT NULL
AND t.CPU IS NOT NULL
AND t.Duration IS NOT NULL
' + CASE WHEN @IgnoreSPReset <> 0 THEN N'AND t.TextData NOT LIKE ''%sp_reset%''' ELSE N'' END + N';';

        EXEC (@SQL);        

    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        SET @ReturnValue = -1;
    END CATCH;

    RETURN @ReturnValue;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.AnalyzePerformanceTuningTrace
@TraceDatabaseName sysname = NULL,
@TraceSchemaName sysname = N'dbo',
@TraceTableName sysname = N'SDU_Trace'
AS
BEGIN

-- Function:      Analyze a loaded performance tuning trace file
-- Parameters:    @TraceDatabaseName sysname -- (default is current database) Database that the trace was loaded into
--                @TraceSchemaName sysname -- (default is dbo) Schema for the table that the trace was loaded into
--                @TraceTableName sysname -- (default is SDU_Trace) Name of the table that the trace was loaded into
-- Action:        Analyzes a loaded performance tuning trace file in terms of both normalized and unnormalized queries
-- Return:        Status (0 = success)
-- Refer to this video: https://youtu.be/Laq7d4pFlQ0
--
-- Test examples: 
/*

EXEC SDU_Tools.AnalyzePerformanceTuningTrace @TraceDatabaseName = NULL,
                                             @TraceSchemaName = N'dbo',
                                             @TraceTableName = N'SDU_Trace';
											 
*/

    SET XACT_ABORT ON;
    SET NOCOUNT ON;

	DECLARE @FullTableName nvarchar(max) = QUOTENAME(COALESCE(@TraceDatabaseName, DB_NAME())) 
	                                     + N'.' + QUOTENAME(COALESCE(@TraceSchemaName, N'dbo'))
										 + N'.' + QUOTENAME(@TraceTableName);
	DECLARE @SQL nvarchar(max);

	SET @SQL = N'
SELECT SUM(Reads) AS TotalReads, SUM(Writes) AS TotalWrites, COUNT(*) AS CommandExecutions 
FROM ' + @FullTableName + N';'
	EXEC (@SQL);

	SET @SQL = N'
SELECT SUM(Reads) AS TotalReads,
       SUM(Reads) * 100 / (SELECT SUM(Reads) FROM ' + @FullTableName + N') AS ReadPercent,
         AVG(Reads) AS AverageReads,
         COUNT(*) AS Executions,
         REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
FROM ' + @FullTableName + N'
GROUP BY REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
ORDER BY TotalReads DESC;';
	EXEC (@SQL);

	SET @SQL = N'
SELECT SUM(Duration) AS TotalDuration,
       SUM(Duration) * 100 / (SELECT SUM(Duration) FROM ' + @FullTableName + N') AS DurationPercent,
         AVG(Duration) AS AverageDuration,
         COUNT(*) AS Executions,
         AVG(Reads) AS AverageReads,
         REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
FROM ' + @FullTableName + N'
GROUP BY REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
ORDER BY TotalDuration DESC;';
	EXEC (@SQL);

	SET @SQL = N'
SELECT SUM(1) AS TotalExecutions,
       SUM(1) * 100 / (SELECT SUM(1) FROM ' + @FullTableName + N') AS ExecutionPercent,
         AVG(Reads) AS AverageReads,
         REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
FROM ' + @FullTableName + N'
GROUP BY REPLACE(REPLACE(REPLACE(Command, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
ORDER BY TotalExecutions DESC;';
	EXEC (@SQL);

	SET @SQL = N'
SELECT COUNT(*) / 10 / DATEDIFF(second, (SELECT MIN(StartTime) FROM ' + @FullTableName + N'), 
       (SELECT MAX(StartTime) FROM ' + @FullTableName + N')) AS CommandsPerSecond
FROM ' + @FullTableName + N';';
	EXEC(@SQL);

	SET @SQL = N'
SELECT TOP(100)
       SUM(1) AS TotalExecutions,
       SUM(1) * 100 / (SELECT SUM(1) FROM ' + @FullTableName + N') AS ExecutionPercent,
         AVG(Reads) AS AverageReads,
         REPLACE(REPLACE(REPLACE(TextData, CHAR(13), '' ''), CHAR(10), '' ''), CHAR(9), '' '')
FROM ' + @FullTableName + N'
GROUP BY TextData
ORDER BY TotalExecutions DESC;';
	EXEC (@SQL);

END;
GO

--==================================================================================
-- Database Comparison Utiltiies
--==================================================================================

CREATE PROCEDURE SDU_Tools.GetDBSchemaCoreComparison
@Database1 sysname,
@Database2 sysname,
@IgnoreColumnID bit,
@IgnoreFillFactor bit
AS
BEGIN

-- Function:      Checks the schema of two databases, looking for basic differences (user objects only)
-- Parameters:    @Database1 sysname              -> name of the first database to check
--                @Database2 sysname              -> name of the second database to compare
--                @IgnoreColumnID bit             -> set to 1 if tables with the same columns but in different order
--                                                   are considered equivalent, otherwise set to 0
--                @IgnoreFillFactor bit           -> set to 1 if index fillfactors are to be ignored, otherwise
--                                                   set to 0
-- Action:        Performs a comparison of the schema of two databases
-- Return:        Rowset describing differences
-- Refer to video: https://youtu.be/8Q8dsxBU6XQ
--
-- Test examples: 
/*

EXEC SDU_Tools.GetDBSchemaCoreComparison N'DB1', N'DB2', 1, 1;

*/
  DECLARE @SQL nvarchar(max);
  DECLARE @SelectTablesQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               c.column_id AS ColumnID,
               c.[name] AS ColumnName,
               CASE WHEN typ.[name] IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''binary'', ''varbinary'') 
                    THEN typ.[name] + ''('' + CAST(c.max_length AS varchar(10)) + '')''
                    WHEN typ.[name] IN (''decimal'',''numeric'') 
                    THEN typ.[name] + ''('' + CAST(c.precision AS varchar(10)) + '','' + CAST(c.scale AS varchar(10)) + '')''
                    ELSE typ.[name] 
               END AS DataType
        FROM sys.tables AS t
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id]
        INNER JOIN sys.columns AS c
        ON t.[object_id] = c.[object_id]
        INNER JOIN sys.[types] AS typ
        ON c.system_type_id = typ.system_type_id 
        AND c.user_type_id = typ.user_type_id
        WHERE t.is_ms_shipped = 0
        ORDER BY SchemaName, TableName, ColumnID;';
  
  DECLARE @SelectIndexesQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               i.[name] AS IndexName,
               i.[type_desc] AS IndexType,
               i.is_primary_key AS IsPrimaryKey,
               i.is_unique AS IsUnique,
               i.is_unique_constraint As IsUniqueConstraint,
               i.is_disabled AS IsDisabled,
               i.fill_factor AS [FillFactor],
               i.ignore_dup_key AS IsIgnoreDupKey,
               i.allow_row_locks AS AllowsRowLocks,
               i.allow_page_locks AS AllowsPageLocks,
               i.has_filter AS IsFiltered,
               COALESCE(i.filter_definition,N'''') AS FilterDefinition
        FROM sys.indexes AS i
        INNER JOIN sys.tables AS t
        ON i.[object_id] = t.[object_id] 
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id] 
        WHERE t.is_ms_shipped = 0
        AND i.index_id > 0
        AND i.is_hypothetical = 0
        ORDER BY SchemaName, TableName, IndexName;';
  
  DECLARE @SelectIndexColumnsQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               i.[name] AS IndexName,
               ic.index_column_id AS IndexColumnID,
               c.[name] AS ColumnName,
               ic.is_included_column AS IsIncludedColumn
        FROM sys.indexes AS i
        INNER JOIN sys.index_columns AS ic 
        ON i.[object_id] = ic.[object_id]
        AND i.index_id = ic.index_id 
        INNER JOIN sys.columns AS c
        ON ic.[object_id] = c.[object_id] 
        AND ic.column_id = c.column_id 
        INNER JOIN sys.tables AS t
        ON i.[object_id] = t.[object_id] 
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id] 
        WHERE t.is_ms_shipped = 0
        AND i.index_id > 0
        ORDER BY SchemaName, TableName, IndexName, IndexColumnID;';
  
  IF OBJECT_ID(N'tempdb..#TableSchemas') IS NOT NULL
  BEGIN
    DROP TABLE #TableSchemas;
  END;
  IF OBJECT_ID(N'tempdb..#IndexSchemas') IS NOT NULL
  BEGIN
    DROP TABLE #IndexSchemas;
  END;
  IF OBJECT_ID(N'tempdb..#IndexColumnSchemas') IS NOT NULL
  BEGIN
    DROP TABLE #IndexColumnSchemas;
  END;

  CREATE TABLE #TableSchemas
  ( TableSchemaID int IDENTITY(1,1) 
      CONSTRAINT PK_#TableSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    ColumnID int NOT NULL,
    ColumnName sysname NOT NULL,
    Datatype varchar(50) NOT NULL
  );
  
  CREATE TABLE #IndexSchemas
  ( IndexSchemaID int IDENTITY(1,1)
      CONSTRAINT PK_#IndexSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    IndexName sysname NOT NULL,
    IndexType nvarchar(60) NOT NULL,
    IsPrimaryKey bit NOT NULL,
    IsUnique bit NOT NULL,
    IsUniqueConstraint bit NOT NULL,
    IsDisabled bit NOT NULL,
    FillFactorInUse int NOT NULL,
    IsIgnoreDupKey bit NOT NULL,
    AllowsRowLocks bit NOT NULL,
    AllowsPageLocks bit NOT NULL,
    IsFiltered bit NOT NULL,
    FilterDefinition nvarchar(max) NOT NULL
  );
  
  CREATE TABLE #IndexColumnSchemas
  ( IndexColumnSchemaID int IDENTITY(1,1) 
      CONSTRAINT PK_#IndexColumnSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    IndexName sysname NOT NULL,
    IndexColumnID int NOT NULL,
    ColumnName sysname NOT NULL,
    IsIncludedColumn bit NOT NULL
  );
  
  SET @SQL = N'USE ' + QUOTENAME(@Database1) + N'; ' + @SelectTablesQuery;
  INSERT #TableSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Database2) + N'; ' + @SelectTablesQuery;
  INSERT #TableSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Database1) + N'; ' + @SelectIndexesQuery;
  INSERT #IndexSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Database2) + N'; ' + @SelectIndexesQuery;
  INSERT #IndexSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Database1) + N'; ' + @SelectIndexColumnsQuery;
  INSERT #IndexColumnSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Database2) + N'; ' + @SelectIndexColumnsQuery;
  INSERT #IndexColumnSchemas 
  EXEC (@SQL);
  
  WITH Database1Tables
  AS 
  ( SELECT DISTINCT SchemaName, TableName
    FROM #TableSchemas 
    WHERE DatabaseName = @Database1
  ),
  Database2Tables
  AS
  ( SELECT DISTINCT SchemaName, TableName 
    FROM #TableSchemas 
    WHERE DatabaseName = @Database2
  ),
  Database1TableStructures
  AS
  ( SELECT *
    FROM #TableSchemas 
    WHERE DatabaseName = @Database1 
  ),
  Database2TableStructures 
  AS
  ( SELECT *
    FROM #TableSchemas 
    WHERE DatabaseName = @Database2
  ),
  Database1Indexes
  AS 
  ( SELECT DISTINCT SchemaName, TableName, IndexName 
    FROM #IndexSchemas 
    WHERE DatabaseName = @Database1
  ),
 Database2Indexes
  AS
  ( SELECT DISTINCT SchemaName, TableName, IndexName 
    FROM #IndexSchemas 
    WHERE DatabaseName = @Database2
  ),
  Database1IndexSchemas
  AS
  ( SELECT *
    FROM #IndexSchemas 
    WHERE DatabaseName = @Database1 
  ),
  Database2IndexSchemas
  AS
  ( SELECT * 
    FROM #IndexSchemas 
    WHERE DatabaseName = @Database2
  ),
  Database1IndexColumnSchemas
  AS
  ( SELECT *
    FROM #IndexColumnSchemas 
    WHERE DatabaseName = @Database1 
  ),
  Database2IndexColumnSchemas
  AS
  ( SELECT * 
    FROM #IndexColumnSchemas 
    WHERE DatabaseName = @Database2
  ),
  Database1OnlyTables 
  AS
  ( SELECT db1t.SchemaName,
           db1t.TableName
    FROM Database1Tables AS db1t
    WHERE NOT EXISTS (SELECT 1
                      FROM Database2Tables AS db2t
                      WHERE db2t.SchemaName = db1t.SchemaName 
                      AND db2t.TableName = db1t.TableName)
  ),
  Database2OnlyTables
  AS
  ( SELECT db2t.SchemaName,
           db2t.TableName
    FROM Database2Tables AS db2t
    WHERE NOT EXISTS (SELECT 1
                      FROM Database1Tables AS db1t
                      WHERE db1t.SchemaName = db2t.SchemaName 
                      AND db1t.TableName = db2t.TableName)
  ),
  Database1OnlyIndexes
  AS
  ( SELECT db1i.SchemaName,
           db1i.TableName,
           db1i.IndexName
    FROM Database1Indexes AS db1i
    WHERE NOT EXISTS (SELECT 1
                      FROM Database2Indexes AS db2i
                      WHERE db2i.SchemaName = db1i.SchemaName 
                      AND db2i.TableName = db1i.TableName 
                      AND db2i.IndexName = db1i.IndexName)
  ),
  Database2OnlyIndexes 
  AS
  ( SELECT db2i.SchemaName,
           db2i.TableName,
           db2i.IndexName
    FROM Database2Indexes AS db2i
    WHERE NOT EXISTS (SELECT 1
                      FROM Database1Indexes AS db1i
                      WHERE db1i.SchemaName = db2i.SchemaName 
                      AND db1i.TableName = db2i.TableName 
                      AND db1i.IndexName = db2i.IndexName)
  ),
  CommonTables
  AS 
  ( SELECT DISTINCT db1t.SchemaName, 
                    db1t.TableName 
    FROM Database1Tables AS db1t 
    INNER JOIN Database2Tables AS db2t 
    ON db1t.SchemaName = db2t.SchemaName 
    AND db1t.TableName = db2t.TableName 
  ),
  CommonIndexes
  AS
  ( SELECT DISTINCT db1i.SchemaName,
                    db1i.TableName,
                    db1i.IndexName 
    FROM Database1Indexes AS db1i 
    INNER JOIN Database2Indexes AS db2i 
    ON db1i.SchemaName = db2i.SchemaName 
    AND db1i.TableName = db2i.TableName 
    AND db1i.IndexName = db2i.IndexName 
  )
  SELECT 10 AS IssueCategory,
         CAST(N'TABLE' AS nvarchar(20)) AS IssueObject,
         CAST(N'DB1 ONLY' AS nvarchar(40)) AS IssueType,
         @Database1 AS DatabaseName,
         db1ot.SchemaName,
         db1ot.TableName,
         CAST(NULL AS sysname) AS IndexName
  FROM Database1OnlyTables AS db1ot
  UNION ALL
  SELECT 20, N'INDEX', N'DB1 ONLY',
         @Database1,
         db1oi.SchemaName,
         db1oi.TableName,
         db1oi.IndexName
  FROM Database1OnlyIndexes AS db1oi
  UNION ALL
  SELECT 30, N'TABLE', N'DB2 ONLY',
         @Database2,
         db2ot.SchemaName,
         db2ot.TableName,
         NULL
  FROM Database2OnlyTables AS db2ot
  UNION ALL
  SELECT 40, N'INDEX', N'DB2 ONLY',
         @Database2,
         db2oi.SchemaName,
         db2oi.TableName,
         db2oi.IndexName
  FROM Database2OnlyIndexes AS db2oi
  UNION ALL
  SELECT 50, N'TABLE', N'DIFFERENT',
         NULL,
         ct.SchemaName,
         ct.TableName,
         NULL
  FROM CommonTables AS ct 
  WHERE EXISTS (SELECT CASE WHEN @IgnoreColumnID <> 0 THEN NULL ELSE ColumnID END, ColumnName, Datatype 
                FROM Database1TableStructures
                WHERE SchemaName = ct.SchemaName 
                AND TableName = ct.TableName 
                EXCEPT
                SELECT CASE WHEN @IgnoreColumnID <> 0 THEN NULL ELSE ColumnID END, ColumnName, Datatype 
                FROM Database2TableStructures
                WHERE SchemaName = ct.SchemaName 
                AND TableName = ct.TableName)
  UNION ALL
  SELECT 60, N'INDEX', N'DIFFERENT',
         NULL,
         ci.SchemaName,
         ci.TableName,
         ci.IndexName
  FROM CommonIndexes AS ci
  WHERE EXISTS (SELECT IndexType,
                       IsPrimaryKey,
                       IsUnique,
                       IsUniqueConstraint,
                       IsDisabled,
                       CASE WHEN @IgnoreFillFactor <> 0 THEN 0 ELSE FillFactorInUse END,
                       IsIgnoreDupKey,
                       AllowsRowLocks,
                       AllowsPageLocks,
                       IsFiltered,
                       FilterDefinition
                FROM Database1IndexSchemas
                WHERE SchemaName = ci.SchemaName 
                AND TableName = ci.TableName 
                AND IndexName = ci.IndexName
                EXCEPT
                SELECT IndexType,
                       IsPrimaryKey,
                       IsUnique,
                       IsUniqueConstraint,
                       IsDisabled,
                       CASE WHEN @IgnoreFillFactor <> 0 THEN 0 ELSE FillFactorInUse END,
                       IsIgnoreDupKey,
                       AllowsRowLocks,
                       AllowsPageLocks,
                       IsFiltered,
                       FilterDefinition
                FROM Database2IndexSchemas 
                WHERE SchemaName = ci.SchemaName 
                AND TableName = ci.TableName 
                AND IndexName = ci.IndexName)
  OR EXISTS (SELECT CASE WHEN @IgnoreColumnID <> 0 THEN NULL ELSE IndexColumnID END,
                    ColumnName,
                    IsIncludedColumn
             FROM Database1IndexColumnSchemas
             WHERE SchemaName = ci.SchemaName 
             AND TableName = ci.TableName 
             AND IndexName = ci.IndexName
             EXCEPT
             SELECT CASE WHEN @IgnoreColumnID <> 0 THEN NULL ELSE IndexColumnID END,
                    ColumnName,
                    IsIncludedColumn
             FROM Database2IndexColumnSchemas 
             WHERE SchemaName = ci.SchemaName 
             AND TableName = ci.TableName 
             AND IndexName = ci.IndexName)
  ORDER BY IssueCategory, IssueObject, IssueType, DatabaseName, SchemaName, TableName, IndexName;
  
  DROP TABLE #TableSchemas;
  DROP TABLE #IndexSchemas;
  DROP TABLE #IndexColumnSchemas;
END;   
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.GetTableSchemaComparison
@Table1DatabaseName sysname,
@Table1SchemaName sysname,
@Table1TableName sysname,
@Table2DatabaseName sysname,
@Table2SchemaName sysname,
@Table2TableName sysname,
@IgnoreColumnID bit,
@IgnoreFillFactor bit
AS
BEGIN

-- Function:      Check the schema of two tables, looking for basic differences
-- Parameters:    @Table1DatabaseName sysname   -> name of the database containing the first table
--                @Table1SchemaName sysname     -> schema name for the first table
--                @Table1TableName sysname      -> table name for the first table
--                @Table2DatabaseName sysname   -> name of the database containing the second table
--                @Table2SchemaName sysname     -> schema name for the second table
--                @Table2TableName sysname      -> table name for the second table
--                @IgnoreColumnID bit           -> set to 1 if tables with the same columns but in different order
--                                                 are considered equivalent, otherwise set to 0
--                @IgnoreFillFactor bit         -> set to 1 if index fillfactors are to be ignored, otherwise
--                                                 set to 0
-- Action:        Performs a comparison of the schema of two tables
-- Return:        Rowset describing differences
-- Refer to video: https://youtu.be/8Q8dsxBU6XQ
--
-- Test examples: 
/*

-- EXEC SDU_Tools.GetTableSchemaComparison N'DB1', N'dbo', N'TABLE1', N'DB2', N'dbo', N'TABLE2', 1, 1;

*/
  DECLARE @SQL nvarchar(max);
  DECLARE @SelectColumnsQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               c.column_id AS ColumnID,
               c.[name] AS ColumnName,
               CASE WHEN typ.[name] IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''binary'', ''varbinary'') 
                    THEN typ.[name] + ''('' + CAST(c.max_length AS varchar(10)) + '')''
                    WHEN typ.[name] IN (''decimal'',''numeric'') 
                    THEN typ.[name] + ''('' + CAST(c.precision AS varchar(10)) + '','' + CAST(c.scale AS varchar(10)) + '')''
                    ELSE typ.[name] 
               END AS DataType
        FROM sys.tables AS t
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id]
        INNER JOIN sys.columns AS c
        ON t.[object_id] = c.[object_id]
        INNER JOIN sys.[types] AS typ
        ON c.system_type_id = typ.system_type_id 
        AND c.user_type_id = typ.user_type_id
        WHERE t.is_ms_shipped = 0';

  DECLARE @SelectIndexesQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               i.[name] AS IndexName,
               i.[type_desc] AS IndexType,
               i.is_primary_key AS IsPrimaryKey,
               i.is_unique AS IsUnique,
               i.is_unique_constraint As IsUniqueConstraint,
               i.is_disabled AS IsDisabled,
               i.fill_factor AS [FillFactor],
               i.ignore_dup_key AS IsIgnoreDupKey,
               i.allow_row_locks AS AllowsRowLocks,
               i.allow_page_locks AS AllowsPageLocks,
               i.has_filter AS IsFiltered,
               COALESCE(i.filter_definition,N'''') AS FilterDefinition
        FROM sys.indexes AS i
        INNER JOIN sys.tables AS t
        ON i.[object_id] = t.[object_id] 
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id] 
        WHERE t.is_ms_shipped = 0
        AND i.index_id > 0
        AND i.is_hypothetical = 0';
  
  DECLARE @SelectIndexColumnsQuery nvarchar(max)
    = N'SELECT DB_NAME() AS DatabaseName,
               s.[name] AS SchemaName,
               t.[name] AS TableName,
               i.[name] AS IndexName,
               ic.index_column_id AS IndexColumnID,
               c.[name] AS ColumnName,
               ic.is_included_column AS IsIncludedColumn
        FROM sys.indexes AS i
        INNER JOIN sys.index_columns AS ic 
        ON i.[object_id] = ic.[object_id]
        AND i.index_id = ic.index_id 
        INNER JOIN sys.columns AS c
        ON ic.[object_id] = c.[object_id] 
        AND ic.column_id = c.column_id 
        INNER JOIN sys.tables AS t
        ON i.[object_id] = t.[object_id] 
        INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id] 
        WHERE t.is_ms_shipped = 0
        AND i.index_id > 0';

  DECLARE @Table1WherePredicate nvarchar(max)
    = ' AND s.[name] = ''' + @Table1SchemaName 
      + ''' AND t.[name] = ''' + @Table1TableName 
      + '''';
  
  DECLARE @Table2WherePredicate nvarchar(max)
    = ' AND s.[name] = ''' + @Table2SchemaName 
      + ''' AND t.[name] = ''' + @Table2TableName 
      + '''';
  
  IF OBJECT_ID(N'tempdb..#TableSchemas') IS NOT NULL
  BEGIN
    DROP TABLE #TableSchemas;
  END;
  IF OBJECT_ID(N'tempdb..#IndexColumnSchemas') IS NOT NULL
  BEGIN
    DROP TABLE #IndexColumnSchemas;
  END;

  CREATE TABLE #TableSchemas
  ( TableSchemaID int IDENTITY(1,1) 
      CONSTRAINT PK_#TableSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    ColumnID int NOT NULL,
    ColumnName sysname NOT NULL,
    Datatype varchar(50) NOT NULL
  );
  
  CREATE TABLE #IndexSchemas
  ( IndexSchemaID int IDENTITY(1,1)
      CONSTRAINT PK_#IndexSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    IndexName sysname NOT NULL,
    IndexType nvarchar(60) NOT NULL,
    IsPrimaryKey bit NOT NULL,
    IsUnique bit NOT NULL,
    IsUniqueConstraint bit NOT NULL,
    IsDisabled bit NOT NULL,
    FillFactorInUse int NOT NULL,
    IsIgnoreDupKey bit NOT NULL,
    AllowsRowLocks bit NOT NULL,
    AllowsPageLocks bit NOT NULL,
    IsFiltered bit NOT NULL,
    FilterDefinition nvarchar(max) NOT NULL
  );
  
  CREATE TABLE #IndexColumnSchemas
  ( IndexColumnSchemaID int IDENTITY(1,1) 
      CONSTRAINT PK_#IndexColumnSchemas PRIMARY KEY,
    DatabaseName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    IndexName sysname NOT NULL,
    IndexColumnID int NOT NULL,
    ColumnName sysname NOT NULL,
    IsIncludedColumn bit NOT NULL
  );
  
  SET @SQL = N'USE ' + QUOTENAME(@Table1DatabaseName) + N'; ' + @SelectColumnsQuery + @Table1WherePredicate;
  INSERT #TableSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Table2DatabaseName) + N'; ' + @SelectColumnsQuery + @Table2WherePredicate;
  INSERT #TableSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Table1DatabaseName) + N'; ' + @SelectIndexesQuery + @Table1WherePredicate;
  INSERT #IndexSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Table2DatabaseName) + N'; ' + @SelectIndexesQuery + @Table2WherePredicate;
  INSERT #IndexSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Table1DatabaseName) + N'; ' + @SelectIndexColumnsQuery + @Table1WherePredicate;
  INSERT #IndexColumnSchemas 
  EXEC (@SQL);
  
  SET @SQL = N'USE ' + QUOTENAME(@Table2DatabaseName) + N'; ' + @SelectIndexColumnsQuery + @Table2WherePredicate;
  INSERT #IndexColumnSchemas 
  EXEC (@SQL);
  
  WITH Database1TableStructures
  AS
  ( SELECT *
    FROM #TableSchemas 
    WHERE DatabaseName = @Table1DatabaseName 
  ),
  Database2TableStructures 
  AS
  ( SELECT *
    FROM #TableSchemas 
    WHERE DatabaseName = @Table2DatabaseName
  ),
  Database1IndexSchemas
  AS
  ( SELECT *
    FROM #IndexSchemas 
    WHERE DatabaseName = @Table1DatabaseName
  ),
  Database2IndexSchemas
  AS
  ( SELECT *
    FROM #IndexSchemas 
    WHERE DatabaseName = @Table2DatabaseName
  ),
  Database1IndexColumnSchemas
  AS
  ( SELECT *
    FROM #IndexColumnSchemas 
    WHERE DatabaseName = @Table1DatabaseName 
  ),
  Database2IndexColumnSchemas
  AS
  ( SELECT * 
    FROM #IndexColumnSchemas 
    WHERE DatabaseName = @Table2DatabaseName
  ),
  Database1OnlyIndexes
  AS
  ( SELECT DISTINCT ics1.SchemaName,
                    ics1.TableName,
                    ics1.IndexName
    FROM #IndexColumnSchemas AS ics1
    WHERE NOT EXISTS (SELECT 1
                      FROM #IndexColumnSchemas AS ics2
                      WHERE ics2.SchemaName = ics1.SchemaName 
                      AND ics2.TableName = ics1.TableName 
                      AND ics2.IndexName = ics1.IndexName)
  ),
  Database2OnlyIndexes
  AS
  ( SELECT DISTINCT ics2.SchemaName,
                    ics2.TableName,
                    ics2.IndexName
    FROM #IndexColumnSchemas AS ics2
    WHERE NOT EXISTS (SELECT 1
                      FROM #IndexColumnSchemas AS ics1
                      WHERE ics1.SchemaName = ics2.SchemaName 
                      AND ics1.TableName = ics2.TableName 
                      AND ics1.IndexName = ics2.IndexName)
  ),
  CommonIndexes
  AS
  ( SELECT DISTINCT @Table1SchemaName AS Table1SchemaName,
                    @Table1TableName AS Table1TableName,
                    @Table2SchemaName AS Table2SchemaName,
                    @Table2TableName AS Table2TableName,
                    ics1.IndexName
    FROM #IndexColumnSchemas AS ics1
    INNER JOIN #IndexColumnSchemas AS ics2
    ON ics2.IndexName = ics1.IndexName
    WHERE ics1.SchemaName = @Table1SchemaName 
    AND ics1.TableName = @Table1TableName 
    AND ics2.SchemaName = @Table2SchemaName
    AND ics2.TableName = @Table2TableName 
  )
  SELECT 10 AS IssueCategory,
         CAST(N'TABLE' AS nvarchar(20)) AS IssueObject,
         CAST(N'DB1 ONLY' AS nvarchar(40)) AS IssueType,
         @Table1DatabaseName AS Table1DatabaseName,
         @Table1SchemaName AS Table1SchemaName,
         @Table1TableName AS Table1TableName,
         CAST(NULL AS sysname) AS Table2DatabaseName,
         CAST(NULL AS sysname) AS Table2SchemaName,
         CAST(NULL AS sysname) AS Table2TableName,
         CAST(NULL AS sysname) AS IndexName,
         CAST(NULL AS sysname) AS ColumnName,
         CAST(NULL AS int) AS Table1ColumnID,
         CAST(NULL AS int) AS Table2ColumnID,
         CAST(NULL AS varchar(50)) AS Table1Datatype,
         CAST(NULL AS varchar(50)) AS Table2Datatype
  WHERE EXISTS (SELECT 1 
                FROM #TableSchemas
                WHERE DatabaseName = @Table1DatabaseName 
                AND SchemaName = @Table1SchemaName 
                AND TableName = @Table1TableName)
  AND NOT EXISTS (SELECT 1 
                  FROM #TableSchemas
                  WHERE DatabaseName = @Table2DatabaseName 
                  AND SchemaName = @Table2SchemaName 
                  AND TableName = @Table2TableName)
  UNION ALL
  SELECT 20 AS IssueCategory,
         N'TABLE', N'DB2 ONLY',
         NULL,
         NULL,
         NULL,
         @Table2DatabaseName,
         @Table2SchemaName,
         @Table2TableName,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
  WHERE EXISTS (SELECT 1 
                FROM #TableSchemas
                WHERE DatabaseName = @Table2DatabaseName 
                AND SchemaName = @Table2SchemaName 
                AND TableName = @Table2TableName)
  AND NOT EXISTS (SELECT 1 
                  FROM #TableSchemas
                  WHERE DatabaseName = @Table1DatabaseName 
                  AND SchemaName = @Table1SchemaName 
                  AND TableName = @Table1TableName)
  UNION ALL
  SELECT 30, N'INDEX', N'DB1 ONLY',
         @Table1DatabaseName,
         db1oi.SchemaName,
         db1oi.TableName,
         NULL,
         NULL,
         NULL,
         db1oi.IndexName,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
  FROM Database1OnlyIndexes AS db1oi
  UNION ALL
  SELECT 40, N'INDEX', N'DB2 ONLY',
         NULL,
         NULL,
         NULL,
         @Table2DatabaseName,
         db2oi.SchemaName,
         db2oi.TableName,
         db2oi.IndexName,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
  FROM Database2OnlyIndexes AS db2oi
  UNION ALL
  SELECT 50, N'COLUMN', N'DB1 ONLY',
         @Table1DatabaseName,
         d1ts.SchemaName,
         d1ts.TableName,
         NULL,
         NULL,
         NULL,
         NULL,
         d1ts.ColumnName,
         d1ts.ColumnID,
         NULL,
         d1ts.Datatype,
         NULL
  FROM Database1TableStructures AS d1ts
  WHERE NOT EXISTS (SELECT 1 
                    FROM Database2TableStructures AS d2ts
                    WHERE d1ts.SchemaName = d2ts.SchemaName 
                    AND d1ts.TableName = d2ts.TableName 
                    AND d1ts.ColumnName = d2ts.ColumnName)
  UNION ALL
  SELECT 60, N'COLUMN', N'DB2 ONLY',
         NULL,
         NULL,
         NULL,
         @Table2DatabaseName,
         d2ts.SchemaName,
         d2ts.TableName,
         NULL,
         d2ts.ColumnName,
         NULL,
         d2ts.ColumnID,
         NULL,
         d2ts.Datatype 
  FROM Database2TableStructures AS d2ts
  WHERE NOT EXISTS (SELECT 1 
                    FROM Database1TableStructures AS d1ts
                    WHERE d2ts.SchemaName = d1ts.SchemaName 
                    AND d2ts.TableName = d1ts.TableName 
                    AND d2ts.ColumnName = d1ts.ColumnName)
  UNION ALL
  SELECT 70, N'COLUMN', N'TYPE MISMATCH',
         @Table1DatabaseName,
         d1ts.SchemaName,
         d1ts.TableName,
         @Table2DatabaseName,
         d2ts.SchemaName,
         d2ts.TableName,
         NULL,
         d1ts.ColumnName,
         d1ts.ColumnID,
         d2ts.ColumnID,
         d1ts.Datatype,
         d2ts.Datatype 
  FROM Database1TableStructures AS d1ts
  INNER JOIN Database2TableStructures AS d2ts
  ON d1ts.SchemaName = d2ts.SchemaName 
  AND d1ts.TableName = d2ts.TableName 
  AND d1ts.ColumnName = d2ts.ColumnName
  WHERE d1ts.Datatype <> d2ts.DataType 
  UNION ALL
  SELECT 80, N'COLUMN', N'COLUMNID MISMATCH',
         @Table1DatabaseName,
         d1ts.SchemaName,
         d1ts.TableName,
         @Table2DatabaseName,
         d2ts.SchemaName,
         d2ts.TableName,
         NULL,
         d1ts.ColumnName,
         d1ts.ColumnID,
         d2ts.ColumnID,
         d1ts.Datatype,
         d2ts.Datatype 
  FROM Database1TableStructures AS d1ts
  INNER JOIN Database2TableStructures AS d2ts
  ON d1ts.SchemaName = d2ts.SchemaName 
  AND d1ts.TableName = d2ts.TableName 
  AND d1ts.ColumnName = d2ts.ColumnName
  WHERE d1ts.ColumnID <> d2ts.ColumnID
  AND @IgnoreColumnID = 0
  UNION ALL
  SELECT 90, N'INDEX', N'DIFFERENT CONFIGURATION',
         @Table1DatabaseName,
         ci.Table1SchemaName,
         ci.Table1TableName,
         @Table2DatabaseName,
         ci.Table2SchemaName,
         ci.Table2TableName,
         ci.IndexName,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
  FROM CommonIndexes AS ci
  WHERE EXISTS (SELECT IndexType,
                       IsPrimaryKey,
                       IsUnique,
                       IsUniqueConstraint,
                       IsDisabled,
                       CASE WHEN @IgnoreFillFactor <> 0 THEN 0 ELSE FillFactorInUse END,
                       IsIgnoreDupKey,
                       AllowsRowLocks,
                       AllowsPageLocks,
                       IsFiltered,
                       FilterDefinition
                FROM Database1IndexSchemas
                WHERE SchemaName = ci.Table1SchemaName 
                AND TableName = ci.Table1TableName 
                AND IndexName = ci.IndexName
                EXCEPT
                SELECT IndexType,
                       IsPrimaryKey,
                       IsUnique,
                       IsUniqueConstraint,
                       IsDisabled,
                       CASE WHEN @IgnoreFillFactor <> 0 THEN 0 ELSE FillFactorInUse END,
                       IsIgnoreDupKey,
                       AllowsRowLocks,
                       AllowsPageLocks,
                       IsFiltered,
                       FilterDefinition
                FROM Database2IndexSchemas 
                WHERE SchemaName = ci.Table2SchemaName 
                AND TableName = ci.Table2TableName 
                AND IndexName = ci.IndexName)
  UNION ALL
  SELECT 100, N'INDEX', N'DIFFERENT COLUMNS',
         @Table1DatabaseName,
         ci.Table1SchemaName,
         ci.Table1TableName,
         @Table2DatabaseName,
         ci.Table2SchemaName,
         ci.Table2TableName,
         ci.IndexName,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL
  FROM CommonIndexes AS ci
  WHERE EXISTS (SELECT IndexColumnID,
                       ColumnName,
                       IsIncludedColumn
                FROM Database1IndexColumnSchemas
                WHERE SchemaName = ci.Table1SchemaName 
                AND TableName = ci.Table1TableName 
                AND IndexName = ci.IndexName
                EXCEPT
                SELECT IndexColumnID,
                       ColumnName,
                       IsIncludedColumn
                FROM Database2IndexColumnSchemas 
                WHERE SchemaName = ci.Table2SchemaName 
                AND TableName = ci.Table2TableName  
                AND IndexName = ci.IndexName);
  
  DROP TABLE #TableSchemas;
  DROP TABLE #IndexColumnSchemas;
END;   
GO

--==================================================================================
-- Database Utility Functions and Procedures
--==================================================================================

CREATE PROCEDURE SDU_Tools.AnalyzeTableColumns
@DatabaseName sysname = NULL,
@SchemaName sysname = N'dbo',
@TableName sysname,
@OrderByColumnName bit = 1,
@OutputSampleValues bit = 1,
@MaximumValuesPerColumn int = 100
AS
BEGIN

-- Function:      Analyze a table's columns
-- Parameters:    @DatabaseName sysname            -> (default current database) database to check
--                @SchemaName sysname              -> (default dbo) schema for the table
--                @TableName sysname               -> the table to analyze
--                @OrderByColumnName bit           -> if 1, output is in column name order, otherwise in column_id order
--                @OutputSampleValues bit          -> if 1 (default), outputs sample values from each column
--                @MaximumValuesPerColumn int      -> (default 100) if outputting sample values, up to how many
-- Action:        Provide metadata for a table's columns and list the distinct values held in the column (up to 
--                a maximum number of values). Note that filestream columns are not sampled, nor are any
--                columns of geometry, geography, or hierarchyid data types.
-- Return:        Rowset for table details, rowset for columns, rowsets for each column
-- Refer to this video: https://youtu.be/V-jCAT-TCXM
--
-- Test examples: 
/*

EXEC SDU_Tools.AnalyzeTableColumns N'WideWorldImporters', N'Warehouse', N'StockItems', 1, 1, 100; 

*/
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @SQL nvarchar(max);
    DECLARE @DatabaseNamePart sysname = CASE WHEN @DatabaseName IS NOT NULL THEN QUOTENAME(@DatabaseName) + N'.' ELSE N'' END;
    DECLARE @Counter int;
    DECLARE @ColumnName sysname;

    IF OBJECT_ID(N'tempdb..#ColumnList') IS NOT NULL
    BEGIN
        DROP TABLE #ColumnList;
    END;
    
    CREATE TABLE #ColumnList
    (
        ColumnListID int IDENTITY(1,1) PRIMARY KEY,
        ColumnName sysname NOT NULL,
        ColumnID int NOT NULL,
        DataType sysname NOT NULL,
        MaximumLength int NOT NULL,
        [Precision] int NOT NULL,
        [Scale] int NOT NULL,
        IsNullable bit NOT NULL,
        IsIdentity bit NOT NULL,
        IsComputed bit NOT NULL,
        IsFilestream bit NOT NULL,
        IsSparse bit NOT NULL,
        [CollationName] sysname NULL
    );
    
    SET @SQL = N'
INSERT #ColumnList (ColumnName, ColumnID, DataType, MaximumLength, [Precision], [Scale], IsNullable, IsIdentity, IsComputed, IsFilestream, IsSparse, [CollationName])
SELECT c.[name], c.column_id, typ.[name], c.max_length, c.[precision], c.[scale], c.is_nullable, c.is_identity, c.is_computed, c.is_filestream, c.is_sparse, c.[collation_name]
FROM ' + @DatabaseNamePart + N'sys.columns AS c
INNER JOIN ' + @DatabaseNamePart + N'sys.tables AS t
ON t.object_id = c.object_id 
INNER JOIN ' + @DatabaseNamePart + N'sys.schemas AS s
ON s.schema_id = t.schema_id 
INNER JOIN ' + @DatabaseNamePart + N'sys.types AS typ
ON typ.system_type_id = c.system_type_id AND typ.user_type_id = c.user_type_id
WHERE s.[name] = ''' + @SchemaName + N'''
AND t.[name] = ''' + @TableName + N'''
AND t.is_ms_shipped = 0
ORDER BY ' + CASE WHEN @OrderByColumnName <> 0 THEN N'c.[name]' ELSE N'c.column_id' END + N';';
    EXEC (@SQL);

    SELECT COALESCE(@DatabaseName, DB_NAME()) AS DatabaseName, @SchemaName AS SchemaName, @TableName AS TableName;
    SELECT ColumnName, ColumnID, DataType, MaximumLength, [Precision], [Scale], IsNullable, IsIdentity, IsComputed, IsFilestream, IsSparse, [CollationName] 
    FROM #ColumnList
    ORDER BY ColumnListID;

    IF @OutputSampleValues <> 0
    BEGIN
        SET @Counter = 1;
        WHILE @Counter <= (SELECT MAX(ColumnListID) FROM #ColumnList)
        BEGIN
            SET @ColumnName = (SELECT ColumnName 
                               FROM #ColumnList 
                               WHERE ColumnListID = @Counter 
                               AND IsFilestream = 0
                               AND DataType NOT IN (N'geography', N'geometry', N'hierarchyid'));
            IF @ColumnName IS NOT NULL
            BEGIN
                SET @SQL = N'
SELECT TOP(' + CAST(@MaximumValuesPerColumn AS nvarchar(20)) + N') ''' + @ColumnName + N''' AS ColumnName, ' + QUOTENAME(@ColumnName) + N' AS Value
FROM ' + @DatabaseNamePart + QUOTENAME(@Schemaname) + N'.' + QUOTENAME(@TableName) + N'
GROUP BY ' + QUOTENAME(@ColumnName) + N'
ORDER BY ' + QUOTENAME(@ColumnName) + N';';
                EXEC (@SQL);
            END;
            SET @Counter += 1;
        END;


    END;

    IF OBJECT_ID(N'tempdb..#ColumnList') IS NOT NULL
    BEGIN
        DROP TABLE #ColumnList;
    END;

END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.FindStringWithinADatabase
@DatabaseName sysname,
@StringToSearchFor nvarchar(max),
@IncludeActualRows bit = 1
AS
BEGIN

-- Function:      Finds a string anywhere within a database
-- Parameters:    @DatabaseName sysname            -> database to check
--                @StringToSearchFor nvarchar(max) -> string we're looking for
--                @IncludeActualRows bit           -> should the rows containing it be output
-- Action:        Finds a string anywhere within a database. Can be useful for testing masking 
--                of data. Checks all string type columns and XML columns.
-- Return:        Rowset for found locations, optionally also output the rows
-- Refer to this video: https://youtu.be/OpTdjMMjy8w
--
-- Test examples: 
/*

EXEC SDU_Tools.FindStringWithinADatabase N'WideWorldImporters', N'Kayla', 0; 
EXEC SDU_Tools.FindStringWithinADatabase N'WideWorldImporters', N'Kayla', 1; 
EXEC SDU_Tools.FindStringWithinADatabase N'AdventureWorks', N'Ken', 1; 

*/
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @DatabaseSQL nvarchar(max) = N'
USE ' + QUOTENAME(@DatabaseName) + N';

SET NOCOUNT ON;

DECLARE @SchemaName sysname;
DECLARE @TableName sysname;
DECLARE @ColumnName sysname;
DECLARE @IsNullable bit;
DECLARE @TableObjectID int;
DECLARE @Message nvarchar(max);
DECLARE @FullTableName nvarchar(max);
DECLARE @BaseDataTypeName sysname;
DECLARE @WereStringColumnsFound bit;
DECLARE @Predicate nvarchar(max);
DECLARE @SQL nvarchar(max);
DECLARE @SummarySQL nvarchar(max) = N'''';
DECLARE @NumberOfTables int;
DECLARE @TableCounter int = 0;
DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);
DECLARE @StringToSearchFor nvarchar(max) = N''' + REPLACE(@StringToSearchFor, N'''', N'''''') + N''';
DECLARE @IncludeActualRows bit = ' + CASE WHEN @IncludeActualRows = 0 THEN N'0' ELSE N'1' END + N';

IF OBJECT_ID(N''tempdb..#FoundLocations'') IS NOT NULL
BEGIN
       DROP TABLE #FoundLocations;
END;

CREATE TABLE #FoundLocations
(
    FullTableName nvarchar(max),
    NumberOfRows bigint
);

SET @NumberOfTables = (SELECT COUNT(*) FROM sys.tables AS t
                                       WHERE t.is_ms_shipped = 0
                                       AND t.[type] = N''U'');

DECLARE TableList CURSOR FAST_FORWARD READ_ONLY
FOR 
SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS TableName, object_id AS TableObjectID
FROM sys.tables AS t
WHERE t.is_ms_shipped = 0
AND t.[type] = N''U''
ORDER BY SchemaName, TableName;

OPEN TableList;
FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @TableObjectID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TableCounter += 1;
    SET @FullTableName = QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@TableName);
    SET @Message = N''Checking table '' 
                 + CAST(@TableCounter AS nvarchar(20)) 
                 + N'' of '' 
                 + CAST(@NumberOfTables AS nvarchar(20)) 
                 + N'': '' 
                 + @FullTableName;
    PRINT @Message;
    
    SET @WereStringColumnsFound = 0;
    SET @Predicate = N'''';
    
    DECLARE ColumnList CURSOR FAST_FORWARD READ_ONLY
    FOR
    SELECT c.[name] AS ColumnName, t.[name] AS BaseDataTypeName
    FROM sys.columns AS c
    INNER JOIN sys.[types] AS t
    ON t.system_type_id = c.system_type_id 
    AND t.user_type_id = c.system_type_id -- note: want the base type not the actual type
    WHERE c.[object_id] = @TableObjectID 
    AND t.[name] IN (N''text'', N''ntext'', N''varchar'', N''nvarchar'', N''char'', N''nchar'', N''xml'')
    AND (c.max_length >= LEN(@StringToSearchFor) OR c.max_length < 0) -- allow for max types
    ORDER BY ColumnName;
    
    OPEN ColumnList;
    FETCH NEXT FROM ColumnList INTO @ColumnName, @BaseDataTypeName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @WereStringColumnsFound = 1;
        IF @Predicate <> N''''
        BEGIN
        SET @Predicate += N'' OR '';
        END;
        SET @Predicate += CASE WHEN @BaseDataTypeName = N''xml''
                               THEN N''CAST('' + QUOTENAME(@ColumnName) + N'' AS nvarchar(max))''
                               ELSE QUOTENAME(@ColumnName) 
                          END
                        + N'' LIKE N''''%'' + @StringToSearchFor + N''%'''''';
        FETCH NEXT FROM ColumnList INTO @ColumnName, @BaseDataTypeName;
    END;
    
    CLOSE ColumnList;
    DEALLOCATE ColumnList;
    
    IF @WereStringColumnsFound <> 0
    BEGIN
        SET @SQL = N''SET NOCOUNT ON; 
                 INSERT #FoundLocations (FullTableName, NumberOfRows)
                 SELECT N'''''' + @FullTableName + N'''''', COUNT_BIG(*) FROM '' 
                        + @FullTableName 
                        + N'' WHERE '' 
                        + @Predicate
                        + N'';'';
        EXECUTE (@SQL);
        
        IF (SELECT NumberOfRows FROM #FoundLocations WHERE FullTableName = @FullTableName) > 0
        BEGIN
            SET @SummarySQL += N''SELECT * FROM '' + @FullTableName + N'' WHERE '' + @Predicate + N'';'' + @CrLf;
        END;
    END;
    
    FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @TableObjectID;
END;

CLOSE TableList;
DEALLOCATE TableList;

SELECT * 
FROM #FoundLocations 
WHERE NumberOfRows > 0 
ORDER BY FullTableName;

DROP TABLE #FoundLocations;

IF @SummarySQL <> N'''' AND @IncludeActualRows <> 0
BEGIN
    EXECUTE (@SummarySQL);
END;' + @CrLf;
    EXECUTE (@DatabaseSQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListSubsetIndexes
@DatabasesToCheck nvarchar(max) = N'ALL'
AS
BEGIN

-- Function:      Lists indexes that appear to be subsets of other indexes
-- Parameters:    @DatabasesToCheck -- either ALL (default) or a comma-delimited list of database names
-- Action:        Finds indexes that appear to be subsets of other indexes
-- Return:        One rowset with details of each subset index
-- Refer to this video: https://youtu.be/aICj46bmKJs
--
-- Test examples: 
/*

EXEC SDU_Tools.ListSubsetIndexes;

*/
    DECLARE @DatabaseName sysname;
    DECLARE @SQLCommandPart1 nvarchar(4000);
    DECLARE @SQLCommandPart2 nvarchar(4000);
    DECLARE @SQLCommandPart3 nvarchar(4000);
    DECLARE @SQLCommandPart4 nvarchar(4000);
    
    IF OBJECT_ID(N'tempdb..#RowsToReport') IS NOT NULL 
    BEGIN
        DROP TABLE #RowsToReport;
    END;
    
    CREATE TABLE #RowsToReport 
    ( RowNumber int IDENTITY(1,1),
      DatabaseName sysname,
      SchemaName sysname,
      TableName sysname,
      IndexName sysname
    );
         
    SET NOCOUNT ON;
    
    DECLARE DatabaseList CURSOR FAST_FORWARD READ_ONLY
    FOR SELECT d.[name] 
        FROM sys.databases AS d
        WHERE d.[name] NOT IN (N'master', N'msdb', N'tempdb', N'model', N'distribution')
        AND d.[name] NOT LIKE N'ReportServer%'
        AND (@DatabasesToCheck = N'ALL' 
             OR d.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString(@DatabasesToCheck, N',', 1)))
        ORDER BY d.[name];
    
    OPEN DatabaseList;
    FETCH NEXT FROM DatabaseList INTO @DatabaseName;
    WHILE @@FETCH_STATUS = 0
    BEGIN
    
        SET @SQLCommandPart1 = N'USE ' + QUOTENAME(@DatabaseName) + N'; 
        DECLARE @MaxOutputWidth int = 4000;
        DECLARE @SchemaName sysname;
        DECLARE @TableName sysname;
        DECLARE @IndexName sysname;
        DECLARE @IndexType nvarchar(128);
        DECLARE @ColumnName sysname;
        DECLARE @IndexColumnID int;
        DECLARE @IsIncluded bit;
        DECLARE @IsUnique bit;
        DECLARE @IsPrimaryKey bit;
        DECLARE @LastIndexName sysname = N'''';
        DECLARE @Output nvarchar(max);
        DECLARE @NameColumnWidth int = (SELECT MAX(LEN(i.[name])) 
                                        FROM sys.indexes AS i 
                                        INNER JOIN sys.tables AS t 
                                                  ON i.[object_id] = t.[object_id] 
                                        WHERE t.is_ms_shipped = 0) + 12;
        DECLARE @OutputRows TABLE 
        ( 
            RowNumber int IDENTITY(1,1), 
            OutputRow varchar(max) 
        );
        DECLARE TableList CURSOR FAST_FORWARD READ_ONLY
        FOR 
        SELECT SCHEMA_NAME(t.[schema_id]) AS SchemaName,
               t.[name] AS TableName 
        FROM sys.tables AS t
        WHERE t.is_ms_shipped = 0
        AND EXISTS (SELECT 1 FROM sys.indexes AS i 
                             WHERE t.[object_id] = i.[object_id] 
                             AND i.index_id > 0)
        ORDER BY SchemaName, TableName;
    
        OPEN TableList;
        FETCH NEXT FROM TableList INTO @SchemaName, @TableName;
        WHILE @@FETCH_STATUS = 0
        BEGIN
    
            SET @LastIndexName = N'''';
    
            DECLARE IndexColumnList CURSOR FAST_FORWARD READ_ONLY
            FOR
            SELECT i.[name] AS IndexName, 
                   i.[type_desc] AS IndexType,
                   c.[name] AS ColumnName, 
                   ic.index_column_id AS IndexColumnID,
                   ic.is_included_column AS IsIncluded,
                   i.is_unique AS IsUnique,
                   i.is_primary_key AS IsPrimaryKey 
            FROM sys.indexes AS i
            INNER JOIN sys.index_columns AS ic
                ON i.[object_id] = ic.[object_id] 
                AND i.index_id = ic.index_id 
            INNER JOIN sys.columns AS c
                ON ic.[object_id] = c.[object_id] 
                AND ic.column_id = c.column_id 
            INNER JOIN sys.tables AS t
                ON i.[object_id] = t.[object_id] 
            WHERE SCHEMA_NAME(t.[schema_id]) = @SchemaName 
            AND t.[name] = @TableName 
            ORDER BY IndexType, IndexName, IsIncluded, IndexColumnID, ColumnName;
                 
            DELETE @OutputRows;';

            SET @SQLCommandPart2 = '
    
            OPEN IndexColumnList;
            FETCH NEXT FROM IndexColumnList 
                INTO @IndexName, @IndexType, @ColumnName, @IndexColumnID, @IsIncluded, @IsUnique, @IsPrimaryKey;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF @LastIndexName <> @IndexName BEGIN
                    IF @LastIndexName <> '''' INSERT @OutputRows VALUES (@Output);
                    SET @Output = LEFT(CASE WHEN @IsPrimaryKey <> 0 
                                            THEN ''PK'' 
                                            ELSE ''  '' 
                                       END 
                                       + CASE WHEN @IndexType = ''CLUSTERED'' 
                                              THEN ''CL'' 
                                              ELSE ''NC'' 
                                         END 
                                       + CASE WHEN @IsUnique <> 0 
                                              THEN ''UQ'' 
                                              ELSE ''  '' 
                                         END
                                       + '' '' + @IndexName 
                                       + SPACE(128), @NameColumnWidth);
                    SET @LastIndexName = @IndexName;
                END;  
                SET @Output += CASE WHEN @IsIncluded <> 0 
                                    THEN ''(Incl) '' 
                                    ELSE '''' 
                               END + @ColumnName + '', '';
                FETCH NEXT FROM IndexColumnList 
                    INTO @IndexName, @IndexType, @ColumnName, @IndexColumnID, @IsIncluded, @IsUnique, @IsPrimaryKey;
            END;
                 
            IF @LastIndexName <> '''' INSERT @OutputRows VALUES (@Output);
                 
            CLOSE IndexColumnList;
            DEALLOCATE IndexColumnList;';

            SET @SQLCommandPart3 = '             
                              
            PRINT N''Table: '' + @SchemaName + N''.'' + @TableName;
            PRINT '' '';
    
            DECLARE RowList CURSOR FAST_FORWARD READ_ONLY
            FOR 
            SELECT CASE WHEN EXISTS (SELECT 1 FROM @OutputRows AS or2 
                                              WHERE SUBSTRING(or2.OutputRow, 
                                                              @NameColumnWidth + 1, 
                                                              LEN(SUBSTRING(or1.OutputRow, 
                                                                            @NameColumnWidth + 1,
                                                                            @MaxOutputWidth))) 
                                                              = SUBSTRING(or1.OutputRow, 
                                                                          @NameColumnWidth + 1, 
                                                                          @MaxOutputWidth)
                                              AND or1.OutputRow <> or2.OutputRow)
                                     AND or1.OutputRow NOT LIKE ''PK%''
                        THEN N''* '' 
                        ELSE N''  ''
                    END 
                    + SUBSTRING(OutputRow, 1, @MaxOutputWidth - 5) AS OutputRow 
            FROM @OutputRows AS or1
            ORDER BY RowNumber;
    
            OPEN RowList;
            FETCH NEXT FROM RowList INTO @Output;';

            SET @SQLCommandPart4 = '            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF RIGHT(@Output, 2) = N'', '' SET @Output = LEFT(@Output, LEN(@Output) - 1);
                PRINT @Output;
                IF LEFT(@Output, 1) = N''*'' 
                BEGIN
                    INSERT #RowsToReport (DatabaseName, SchemaName, TableName, IndexName)
                    VALUES (DB_NAME(DB_ID()), @SchemaName, @TableName, LTRIM(RTRIM(SUBSTRING(@Output, 10, @NameColumnWidth - 7))));
                END;
                FETCH NEXT FROM RowList INTO @Output;
            END;
            CLOSE RowList;
            DEALLOCATE RowList;
    
            PRINT '' '';
    
            FETCH NEXT FROM TableList INTO @SchemaName, @TableName;
        END;
    
        CLOSE TableList;
        DEALLOCATE TableList;';

        EXECUTE(@SQLCommandPart1 + @SQLCommandPart2 + @SQLCommandPart3 + @SQLCommandPart4);
        
        FETCH NEXT FROM DatabaseList INTO @DatabaseName;
    END;
    
    CLOSE DatabaseList;
    DEALLOCATE DatabaseList;
    
    SELECT DatabaseName, SchemaName, TableName, IndexName 
    FROM #RowsToReport 
    ORDER BY RowNumber;

    IF OBJECT_ID(N'tempdb..#RowsToReport') IS NOT NULL 
    BEGIN
        DROP TABLE #RowsToReport;
    END;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ShowBackupCompletionEstimates
AS
BEGIN

-- Function:      Shows completion estimates for any currently executing backups
-- Parameters:    None
-- Action:        Shows completion estimates for any currently executing backups
-- Return:        One rowset with details of each currently executing backup
-- Refer to this video: Refer to this video: https://youtu.be/M-Gh4CfQkIg
--
-- Test examples: 
/*

EXEC SDU_Tools.ShowBackupCompletionEstimates;

*/
    SELECT r.session_id AS SessionID,
           r.percent_complete AS PercentComplete, 
           r.start_time AS StartTime,
           DATEDIFF(second, r.start_time, GETDATE()) AS DurationSoFar, 
           DATEADD(second, DATEDIFF(second, r.start_time, GETDATE()) * 100 / r.percent_complete, GETDATE())
              AS EstimatedCompletionTime,
           st.text AS LastSQLStatement
    FROM sys.dm_exec_requests AS r
    OUTER APPLY sys.dm_exec_SQL_text(r.SQL_handle) AS st
    WHERE LOWER(r.command) LIKE '%backup%'
    ORDER BY r.session_id;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.EmptySchema
@DatabaseName sysname,
@SchemaName sysname
AS
BEGIN

-- Function:      Removes objects in the specified schema in the specified database
-- Parameters:    @DatabaseName -> database containing the schema
--                @SchemaName -> schema to empty (cannot be dbo, sys, or SDU_Tools)
-- Action:        Removes objects in the specified schema in the current database
--                Note: must be run from within the same database as the schema
-- Return:        One rowset with details of each currently executing backup
-- Refer to this video: Refer to this video: https://youtu.be/ygQNeirGdlM
--
-- Test examples: 
/*

USE WideWorldImporters;
GO
CREATE SCHEMA XYZABC AUTHORIZATION dbo;
GO
CREATE TABLE XYZABC.TestTable (TestTableID int IDENTITY(1,1) PRIMARY KEY);
GO
EXEC SDU_Tools.EmptySchema @DatabaseName = N'WideWorldImporters', @SchemaName = N'XYZABC';
GO

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @SQL nvarchar(max) = 
N'USE ' + QUOTENAME(@DatabaseName) + N';
    DECLARE @SchemaName sysname = N''' + @SchemaName + N''';
    DECLARE @SQL nvarchar(max);
    DECLARE @ReturnValue int = 0;
    DECLARE @SchemaID int = SCHEMA_ID(@SchemaName);
    
    IF @SchemaID IS NULL OR @SchemaName IN (N''sys'', N''dbo'', N''SDU_Tools'')
    BEGIN
        RAISERROR (''Selected schema is not present in the current database'', 16, 1);
        SET @ReturnValue = -1;
    END
    ELSE 
    BEGIN -- drop all existing objects in the schema
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
        ORDER BY CASE o.[type] WHEN ''V'' THEN 1    -- view
                               WHEN ''P'' THEN 2    -- stored procedure
                               WHEN ''PC'' THEN 3   -- clr stored procedure
                               WHEN ''FN'' THEN 4   -- scalar function
                               WHEN ''FS'' THEN 5   -- clr scalar function
                               WHEN ''AF'' THEN 6   -- clr aggregate
                               WHEN ''FT'' THEN 7   -- clr table-valued function
                               WHEN ''TF'' THEN 8   -- table-valued function
                               WHEN ''IF'' THEN 9   -- inline table-valued function
                               WHEN ''TR'' THEN 10  -- trigger
                               WHEN ''TA'' THEN 11  -- clr trigger
                               WHEN ''D'' THEN 12   -- default
                               WHEN ''F'' THEN 13
                               WHEN ''C'' THEN 14   -- check constraint
                               WHEN ''UQ'' THEN 15  -- unique constraint
                               WHEN ''PK'' THEN 16  -- primary key constraint
                               WHEN ''U'' THEN 17   -- table
                               WHEN ''TT'' THEN 18  -- table type
                               WHEN ''SO'' THEN 19  -- sequence
                 END;
        
        WHILE @ObjectCounter <= (SELECT MAX(ObjectRemovalOrder) FROM @ObjectsToRemove)
        BEGIN
            SELECT @ObjectTypeCode = otr.ObjectTypeCode,
                   @ObjectName = otr.ObjectName,
                   @TableName = otr.TableName 
            FROM @ObjectsToRemove AS otr 
            WHERE otr.ObjectRemovalOrder = @ObjectCounter;
    
            SET @SQL = CASE WHEN @ObjectTypeCode = ''V'' 
                            THEN N''DROP VIEW '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode IN (''P'' , ''PC'')
                            THEN N''DROP PROCEDURE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode IN (''FN'', ''FS'', ''FT'', ''TF'', ''IF'')
                            THEN N''DROP FUNCTION '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode IN (''TR'', ''TA'')
                            THEN N''DROP TRIGGER '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode IN (''C'', ''D'', ''F'', ''PK'', ''UQ'')
                            THEN N''ALTER TABLE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@TableName) 
                                 + N'' DROP CONSTRAINT '' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode = ''U''
                            THEN N''DROP TABLE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode = ''AF''
                            THEN N''DROP AGGREGATE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode = ''TT''
                            THEN N''DROP TYPE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                            WHEN @ObjectTypeCode = ''SO''
                            THEN N''DROP SEQUENCE '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@ObjectName) + N'';''
                       END;
    
                IF @SQL IS NOT NULL
                BEGIN
                    EXECUTE(@SQL);
                END;
    
            SET @ObjectCounter += 1;
        END;
    END;';
    EXECUTE (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.PrintMessage
@MessageToPrint nvarchar(max) 
AS
BEGIN

-- Function:      Print a message immediately 
-- Parameters:    @MessageToPrint nvarchar(max) -> The message to be printed
-- Action:        Prints a message immediately rather than waiting for PRINT to be returned
-- Return:        Nil
-- Refer to this video: https://youtu.be/Coabe1oY8Vg
--
-- Test examples: 
/*

EXEC SDU_Tools.PrintMessage N'Hello';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    RAISERROR (@MessageToPrint, 10, 1) WITH NOWAIT;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ShowCurrentBlocking
@DatabaseName sysname 
AS
BEGIN

-- Function:      Looks for requests that are blocking right now
-- Parameters:    @DatabaseName sysname         -> Database to process
-- Action:        Lists sessions holding locks, the SQL they are executing, then 
--                lists blocked items and the SQL they are trying to execute
-- Return:        Two rowsets
-- Refer to this video: https://youtu.be/utIPkuqfTu0
--
-- Test examples: 
/*

EXEC SDU_Tools.ShowCurrentBlocking @DatabaseName = N'WideWorldImporters';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT tl.request_session_id AS SessionID,
           s.login_name AS LoginName,
           tl.resource_type AS ObjectType,
           tl.request_mode AS RequestMode,
           tl.request_type AS RequestType,
           tl.request_status AS RequestStatus,
           s.open_transaction_count AS OpenTransactionCount,
           st.text AS SQLText,
           mrsh.text AS LastSQLText,
           tl.resource_associated_entity_id AS AssociatedEntityID
    FROM sys.dm_tran_locks AS tl 
    INNER JOIN sys.databases AS d
        ON tl.resource_database_id = d.database_id 
    LEFT OUTER JOIN sys.dm_exec_sessions AS s
        ON tl.request_session_id = s.session_id 
    LEFT OUTER JOIN sys.dm_exec_requests AS r
        ON tl.request_session_id = r.request_id
    LEFT OUTER JOIN sys.dm_exec_connections AS c
        ON tl.request_session_id = c.session_id 
    OUTER APPLY sys.dm_exec_SQL_text(r.SQL_handle) AS st
    OUTER APPLY sys.dm_exec_SQL_text(c.most_recent_SQL_handle) AS mrsh
    WHERE d.[name] = @DatabaseName;
    
    WITH BlockedSessions
    AS
    ( SELECT s.session_id AS BlockedSessionID, 
             r.blocking_session_id AS BlockedBy,
             st.text AS BlockedSQLText
      FROM sys.dm_exec_requests AS r
      INNER JOIN sys.dm_exec_sessions AS s
        ON r.session_id = s.session_id 
      INNER JOIN sys.dm_exec_connections AS c
        ON s.session_id = c.session_id 
      OUTER APPLY sys.dm_exec_SQL_text(c.most_recent_SQL_handle) AS st
      WHERE r.blocking_session_id <> 0
    ),
    BlockingSessions
    AS
    ( SELECT s.session_id AS BlockingSessionID, st.text AS BlockingSQLText
      FROM BlockedSessions AS bs
      INNER JOIN sys.dm_exec_sessions AS s
        ON s.session_id = s.session_id 
      INNER JOIN sys.dm_exec_connections AS c
        ON s.session_id = c.session_id 
      OUTER APPLY sys.dm_exec_SQL_text(c.most_recent_SQL_handle) AS st
    )
    SELECT s.BlockingSessionID, 
           s.BlockingSQLText,
           b.BlockedSessionID, 
           b.BlockedBy, 
           b.BlockedSQLText
    FROM BlockingSessions AS s
    INNER JOIN BlockedSessions AS b
        ON s.BlockingSessionID  = b.BlockedBy
    ORDER BY b.BlockedBy, b.BlockedSessionID;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ExecuteJobAndWaitForCompletion
@JobName sysname,
@MaximumWaitSecondsForJobStart int = 300,  -- 5 minutes
@MaximumWaitSecondsForJobCompletion int = 3600,  -- 1 hour
@PrintDebugOutput bit = 0  -- 0 = turn debug off, 1 = turn debug on
AS 
BEGIN
-- Function:      Executes a SQL Server Agent job synchronously (waits for it to complete)
-- Parameters:    @JobName sysname         -> Job to execute
--                @MaximumWaitSecondsForJobStart int -> Timeout for waiting for job start
--                @MaximumWaitSecondsForJobCompletion int -> Timeout waiting for job completion
--                @PrintDebugOutput bit -> set to 1 for more verbose output
-- Action:        Starts an agent job and waits for it to complete
-- Return:        Error on unable to execute job or timeout
-- Refer to this video: https://youtu.be/zTNMgez6ubo
--
-- Test examples: 
/*

EXEC SDU_Tools.ExecuteJobAndWaitForCompletion @JobName = 'Daily ETL';

*/
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @StartDate int;
    DECLARE @StartTime int;
    DECLARE @InstanceID int;
    DECLARE @ElapsedSeconds int;
    DECLARE @JobID uniqueidentifier;
    DECLARE @ExecutionStatus int;
    DECLARE @ExecutionResult int;
    DECLARE @MaximumJobStep int;
    DECLARE @ErrorMessage nvarchar(max);

    BEGIN TRY

        SELECT TOP(1) @JobID = j.job_id
        FROM msdb.dbo.sysjobs AS j
        WHERE j.[name] = @JobName;

        IF @JobID IS NULL
        BEGIN
            SET @ErrorMessage = N'ERROR: No such job ' + QUOTENAME(@JobName);
            PRINT @ErrorMessage;
            THROW 50000, @ErrorMessage, 1;
        END;

        IF @PrintDebugOutput <> 0 
        BEGIN
            SET @ErrorMessage = N'DEBUG: Located job: ' + CAST(@JobID AS nvarchar(50));
            RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
        END;

        SELECT @MaximumJobStep = MAX(js.step_id) 
        FROM msdb.dbo.sysjobsteps AS js
        WHERE js.job_id = @JobID;

        IF @PrintDebugOutput <> 0 
        BEGIN
            SET @ErrorMessage = N'DEBUG: Total job steps: ' + CAST(@MaximumJobStep AS nvarchar(50));
            RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
        END;

        SET @ElapsedSeconds = 0;

        WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobactivity AS ja 
                               WHERE ja.job_id = @JobID
                               AND ja.run_Requested_date IS NOT NULL  
                               AND ja.stop_execution_date IS NULL)
        BEGIN
            IF @PrintDebugOutput <> 0 
            BEGIN
                SET @ErrorMessage = N'WARNING: Job already running: Waiting to retry start';
                RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
            END;
            WAITFOR DELAY '00:00:01';
            SET @ElapsedSeconds += 1;
            IF @ElapsedSeconds > @MaximumWaitSecondsForJobStart
            BEGIN
                SET @ErrorMessage = N'ERROR: Timeout waiting for previous job instance to complete';
                PRINT @ErrorMessage;
                THROW 50000, @ErrorMessage, 1;
            END;
        END;

        EXEC @ExecutionResult = msdb.dbo.sp_start_job @JobName;

        IF @ExecutionResult <> 0
        BEGIN
            SET @ErrorMessage = N'ERROR: Unable to start job: ' + QUOTENAME(@JobName);
            PRINT @ErrorMessage;
            THROW 50000, @ErrorMessage, 1;
        END;

        IF @PrintDebugOutput <> 0 
        BEGIN
            SET @ErrorMessage = N'DEBUG: Start job returned execution status: ' + CAST(@ExecutionResult AS nvarchar(50));
            RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
        END;

        WAITFOR DELAY '0:0:05';
        SET @ElapsedSeconds = 5;

        WHILE @StartDate IS NULL
        BEGIN
            SELECT TOP(1) @StartDate = jh.run_date, @StartTime = jh.run_time, @InstanceID = jh.instance_id
            FROM msdb.dbo.sysjobhistory AS jh
            WHERE jh.job_id = @JobID 
            AND jh.step_id = 1
            ORDER BY jh.run_date DESC, jh.run_time DESC, jh.instance_id DESC;

            IF @StartDate IS NULL
            BEGIN
                IF @PrintDebugOutput <> 0 
                BEGIN
                    SET @ErrorMessage = N'DEBUG: Start time not found. Waiting for 5 seconds';
                    RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
                END;

                WAITFOR DELAY '00:00:05';
                SET @ElapsedSeconds += 5;

                IF @ElapsedSeconds > @MaximumWaitSecondsForJobStart
                BEGIN
                    SET @ErrorMessage = N'ERROR: Exceeded wait time to start job: ' + QUOTENAME(@JobName);
                    PRINT @ErrorMessage;
                    THROW 50000, @ErrorMessage, 1;
                END;
            END ELSE BEGIN
                IF @PrintDebugOutput <> 0 
                BEGIN
                    SET @ErrorMessage = N'DEBUG: Job start date: ' + CAST(@StartDate AS nvarchar(50)) + N' with start time: ' + CAST(@StartTime AS nvarchar(50));
                    RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
                END;
            END;
        END;

        SET @ElapsedSeconds = 0;
        WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobactivity AS ja 
                               WHERE ja.job_id = @JobID
                               AND ja.run_requested_date IS NOT NULL  
                               AND ja.stop_execution_date IS NULL)
        BEGIN
            If @PrintDebugOutput <> 0
            BEGIN
                SET @ErrorMessage = N'DEBUG: Job is running. Waiting for completion';
                RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
            END;

            WAITFOR DELAY '00:00:01';
            SET @ElapsedSeconds += 1;
            
            IF @ElapsedSeconds > @MaximumWaitSecondsForJobCompletion
            BEGIN
                SET @ErrorMessage = N'ERROR: Job completion timeout';
                PRINT @ErrorMessage;
                THROW 50000, @ErrorMessage, 1;
            END;
        END;

        SELECT TOP(1) @ExecutionStatus = jh.run_status
        FROM msdb.dbo.sysjobhistory AS jh
        WHERE jh.job_id = @JobID 
        AND jh.run_date = @StartDate 
        AND jh.run_time = @StartTime 
        AND jh.step_id = 0 
        AND jh.instance_id > @InstanceID;

        WHILE @ExecutionStatus IS NULL
        BEGIN
            SELECT TOP(1) @ExecutionStatus = jh.run_status
            FROM msdb.dbo.sysjobhistory AS jh
            WHERE jh.job_id = @JobID 
            AND jh.run_date = @StartDate 
            AND jh.run_time = @StartTime 
            AND jh.step_id = 0 
            AND jh.instance_id > @InstanceID;

            IF @ExecutionStatus IS NULL
            BEGIN
                If @PrintDebugOutput <> 0
                BEGIN
                    SET @ErrorMessage = N'DEBUG: Execution status is NULL. Waiting for 1 second';
                    RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
                END;

                WAITFOR DELAY '00:00:01';
                SET @ElapsedSeconds += 1;
                
                IF @ElapsedSeconds > @MaximumWaitSecondsForJobCompletion
                BEGIN
                    SET @ErrorMessage = N'ERROR: Job exceeded completion timeout: ' + QUOTENAME(@JobName);
                    PRINT @ErrorMessage;
                    THROW 50000, @ErrorMessage, 1;
                END;
            END ELSE BEGIN
                If @PrintDebugOutput <> 0
                BEGIN
                    SET @ErrorMessage = N'DEBUG: Job returned execution status:  ' + CAST(@ExecutionStatus AS nvarchar(50));
                    RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
                END;
            END;
        END;

        IF @ExecutionStatus = 0 
        BEGIN
            IF @PrintDebugOutput <> 0
            BEGIN
                SET @ErrorMessage = N'ERROR: Job execution failed: ' + QUOTENAME(@JobName);
                RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
            END;
            THROW 50000, N'Job execution returned a failure outcome', 1;
        END;

    END TRY
    BEGIN CATCH
        SET @ErrorMessage = N'ERROR: Job execution failed: ' + QUOTENAME(@JobName) + N' ' + ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 0, 1) WITH NOWAIT;
        THROW;
    END CATCH;
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListAllDataTypesInUse
@DatabaseName sysname,
@SchemasToList nvarchar(max),  -- N'ALL' for all
@TablesToList nvarchar(max),   -- N'ALL' for all
@ColumnsToList nvarchar(max)   -- N'ALL' for all
AS
BEGIN

-- Function:      ListAllDataTypesInUse
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        ListAllDataTypesInUse (user tables only)
-- Return:        Rowset a distinct list of DataTypes
-- Refer to this video: https://youtu.be/1MzqnkLeoNM
--
-- Test examples: 
/*

EXEC SDU_Tools.ListAllDataTypesInUse @DatabaseName = N'WideWorldImporters',
                                     @SchemasToList = N'ALL', 
                                     @TablesToList = N'ALL', 
                                     @ColumnsToList = N'ALL';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = 
'   SELECT DISTINCT
           typ.[name] + CASE WHEN typ.[name] IN (N''decimal'', N''numeric'')
                             THEN N''('' + CAST(c.precision AS nvarchar(20)) + N'', '' 
                                  + CAST(c.scale AS nvarchar(20)) + N'')''
                             WHEN typ.[name] IN (N''varchar'', N''nvarchar'', N''char'', N''nchar'')
                             THEN N''('' + CASE WHEN c.max_length < 0 
                                              THEN N''max'' 
                                              ELSE CAST(c.max_length AS nvarchar(20)) 
                                         END + N'')''
                             WHEN typ.[name] IN (N''time'', N''datetime2'', N''datetimeoffset'')
                             THEN N''('' + CAST(c.scale AS nvarchar(20)) + N'')''
                             ELSE N''''
                        END AS DataType
    FROM ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
        ON s.[schema_id] = t.[schema_id]
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.columns AS c
        ON t.[object_id] = c.[object_id] 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.[types] AS typ 
        ON c.system_type_id = typ.system_type_id
        AND c.user_type_id = typ.user_type_id 
    WHERE t.[type] = N''U'''
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @ColumnsToList = N'ALL' 
           THEN N''
           ELSE N'    AND c.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @ColumnsToList + ''', N'','', 1)))'
      END + @CrLf 
    + N'    ORDER BY DataType;';
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListColumnsAndDataTypes
@DatabaseName sysname,
@SchemasToList nvarchar(max),  -- N'ALL' for all
@TablesToList nvarchar(max),   -- N'ALL' for all
@ColumnsToList nvarchar(max)   -- N'ALL' for all
AS
BEGIN

-- Function:      Lists the data types for all columns
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        Lists the data types for all columns (user tables only)
-- Return:        Rowset containing SchemaName, TableName, ColumnName, and DataType. Within each 
--                table, columns are listed in column ID order
-- Refer to this video: https://youtu.be/FlkRho_Hngk
--
-- Test examples: 
/*

EXEC SDU_Tools.ListColumnsAndDataTypes @DatabaseName = N'WideWorldImporters',
                                       @SchemasToList = N'ALL', 
                                       @TablesToList = N'ALL', 
                                       @ColumnsToList = N'ALL';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = 
'   SELECT s.[name] AS SchemaName, 
           t.[name] AS TableName, 
           c.[name] AS ColumnName,
           typ.[name] + CASE WHEN typ.[name] IN (N''decimal'', N''numeric'')
                             THEN N''('' + CAST(c.precision AS nvarchar(20)) + N'', '' 
                                  + CAST(c.scale AS nvarchar(20)) + N'')''
                             WHEN typ.[name] IN (N''varchar'', N''nvarchar'', N''char'', N''nchar'')
                             THEN N''('' + CASE WHEN c.max_length < 0 
                                              THEN N''max'' 
                                              ELSE CAST(c.max_length AS nvarchar(20)) 
                                         END + N'')''
                             WHEN typ.[name] IN (N''time'', N''datetime2'', N''datetimeoffset'')
                             THEN N''('' + CAST(c.scale AS nvarchar(20)) + N'')''
                             ELSE N''''
                        END AS DataType
    FROM ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
        ON s.[schema_id] = t.[schema_id]
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.columns AS c
        ON t.[object_id] = c.[object_id] 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.[types] AS typ 
        ON c.system_type_id = typ.system_type_id
        AND c.user_type_id = typ.user_type_id 
    WHERE t.[type] = N''U'''
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @ColumnsToList = N'ALL' 
           THEN N''
           ELSE N'    AND c.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @ColumnsToList + ''', N'','', 1)))'
      END + @CrLf 
    + N'    ORDER BY SchemaName, TableName, c.column_id;';
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListMismatchedDataTypes
@DatabaseName sysname,
@SchemasToList nvarchar(max),  -- N'ALL' for all
@TablesToList nvarchar(max),   -- N'ALL' for all
@ColumnsToList nvarchar(max)   -- N'ALL' for all
AS
BEGIN

-- Function:      ListMismatchedDataTypes
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        List columns with the same name that are defined with different data types (user tables only)
-- Return:        Rowset a list of mismatched DataTypes
-- Refer to this video: https://youtu.be/i6mmzhu4T9g
--
-- Test examples: 
/*

EXEC SDU_Tools.ListMismatchedDataTypes @DatabaseName = N'WideWorldImporters',
                                       @SchemasToList = N'ALL', 
                                       @TablesToList = N'ALL', 
                                       @ColumnsToList = N'ALL';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = 
'WITH ColumnDataTypes
AS
(
    SELECT s.[name] AS SchemaName, 
           t.[name] AS TableName,
           c.[name] AS ColumnName,
           typ.[name] + CASE WHEN typ.[name] IN (N''decimal'', N''numeric'')
                             THEN N''('' + CAST(c.[precision] AS nvarchar(20)) + N'', '' + CAST(c.[scale] AS nvarchar(20)) + N'')''
                             WHEN typ.[name] IN (N''varchar'', N''nvarchar'', N''char'', N''nchar'')
                             THEN N''('' + CASE WHEN c.max_length < 0 
                                              THEN N''max'' 
                                              ELSE CAST(c.max_length AS nvarchar(20)) 
                                         END + N'')''
                             WHEN typ.[name] IN (N''time'', N''datetime2'', N''datetimeoffset'')
                             THEN N''('' + CAST(c.[scale] AS nvarchar(20)) + N'')''
                             ELSE N''''
                        END AS DataType
    FROM ' + QUOTENAME(@DatabaseName) + N'.sys.columns AS c
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t 
    ON t.object_id = c.object_id 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    ON s.schema_id = t.schema_id 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.types AS typ 
    ON typ.system_type_id = c.system_type_id 
    AND typ.user_type_id = c.user_type_id 
    WHERE t.is_ms_shipped = 0
    AND t.[type] = N''U'''
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @ColumnsToList = N'ALL' 
           THEN N''
           ELSE N'    AND c.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @ColumnsToList + ''', N'','', 1)))'
      END + @CrLf + N'
)
SELECT cdt.ColumnName, cdt.DataType, N''('' + cdt.SchemaName + N''.'' + cdt.TableName + N'')'' AS TableSchema
FROM ColumnDataTypes AS cdt
WHERE EXISTS (SELECT 1 FROM ColumnDataTypes AS cdtl WHERE cdtl.ColumnName = cdt.ColumnName AND cdtl.DataType <> cdt.DataType)
ORDER BY ColumnName, cdt.DataType, TableSchema;';
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListUnusedIndexes
@DatabaseName sysname
AS
BEGIN

-- Function:      List indexes that appear to be unused
-- Parameters:    @DatabaseName sysname         -> Database to process
-- Action:        List indexes that appear to be unused (user tables only)
--                These indexes might be candidates for reconsideration and removal
--                but be careful about doing so, particularly for unique indexes
-- Return:        Rowset of schema name, table, name, index name, and is unique
-- Refer to this video: https://youtu.be/SNVSBWPsBnw
-- Test examples: 
/*

EXEC SDU_Tools.ListUnusedIndexes @DatabaseName = N'WideWorldImporters';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = 
'   SELECT s.[name] AS SchemaName, t.[name] AS TableName, i.[name] AS IndexName, i.is_unique AS IsUnique
    FROM ' + QUOTENAME(@DatabaseName) + N'.sys.indexes AS i
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
        ON t.[object_id] = i.[object_id] 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
        ON t.[schema_id] = s.[schema_id]
    LEFT OUTER JOIN sys.dm_db_index_usage_stats AS ius
    ON i.[object_id] = ius.[object_id] 
    AND i.index_id = ius.index_id 
    AND ius.database_id = DB_ID(''' + @DatabaseName + N''')
    WHERE ius.last_user_seek IS NULL 
    AND ius.last_user_scan IS NULL
    AND ius.last_user_lookup IS NULL
    AND i.[name] IS NOT NULL
    AND i.index_id > 1
    AND t.is_ms_shipped = 0
    AND i.is_primary_key = 0
    AND i.is_hypothetical = 0
    AND i.is_disabled = 0
    ORDER BY SchemaName, TableName, IndexName;' + @CrLf;
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListUserTableSizes
@DatabaseName sysname,
@SchemasToList nvarchar(max),  -- N'ALL' for all
@TablesToList nvarchar(max),   -- N'ALL' for all
@ExcludeEmptyTables bit = 0,   -- 1 for yes
@IsOutputOrderedBySize bit = 0 -- 1 for yes
AS
BEGIN

-- Function:      Lists the size and number of rows for all or selected user tables
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ExcludeEmptyTables bit       -> 0 for list all, 1 for don't list empty objects
--                @IsOutputOrderedBySize bit    -> 0 for alphabetical, 1 for size descending
-- Action:        Lists the size and number of rows for all or selected user tables
-- Return:        Rowset containing SchemaName, TableName, TotalRows, TotalReservedMB, TotalUsedMB,
--                   TotalFreeMB in either alphabetical order or size descending order 
-- Refer to this video: https://youtu.be/mwOpnit0zqg
--
-- Test examples: 
/*

EXEC SDU_Tools.ListUserTableSizes @DatabaseName = N'WideWorldImporters',
                                  @SchemasToList = N'ALL', 
                                  @TablesToList = N'ALL', 
                                  @ExcludeEmptyTables = 0,
                                  @IsOutputOrderedBySize = 1;

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = N'
SELECT s.[name] AS SchemaName,
       t.[name] AS TableName,
       p.rows AS TotalRows,
       CAST(ISNULL(SUM(au.total_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalReservedMB,
       CAST(ISNULL(SUM(au.used_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalUsedMB,
       CAST(ISNULL(SUM(au.total_pages - au.used_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalFreeMB
FROM ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    ON s.[schema_id] = t.[schema_id] 
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.indexes AS i 
    ON t.[object_id] = i.[object_id]
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.partitions AS p 
    ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.allocation_units AS au 
    ON au.container_id = p.partition_id
WHERE t.is_ms_shipped = 0
AND t.[name] NOT LIKE ''dt%'' 
AND t.[name] <> ''sysdiagrams''' + @CrLf
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))' + @CrLf
      END 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))' + @CrLf
      END
    + N'GROUP BY s.[name], t.[name], p.rows' + @CrLf
    + CASE WHEN @ExcludeEmptyTables = 0
           THEN N''
           ELSE N'HAVING p.rows > 0' + @CrLf 
      END
    + CASE WHEN @IsOutputOrderedBySize = 0 
           THEN N'ORDER BY SchemaName, TableName;'
           ELSE N'ORDER BY TotalUsedMB DESC, SchemaName, TableName;'
      END;
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListUserTableAndIndexSizes
@DatabaseName sysname,
@SchemasToList nvarchar(max),    -- N'ALL' for all
@TablesToList nvarchar(max),     -- N'ALL' for all
@ExcludeEmptyIndexes bit = 0,    -- 1 for yes
@ExcludeTableStructure bit = 0,  -- 1 for yes
@IsOutputOrderedBySize bit = 0   -- 1 for yes
AS
BEGIN

-- Function:      Lists the size and number of rows for all or selected user tables and indexes
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ExcludeEmptyIndexes bit      -> 0 for list all, 1 for don't list empty objects
--                @ExcludeTableStructure bit    -> 0 for list all, 1 for don't list base table (clustered index or heap)
--                @IsOutputOrderedBySize bit    -> 0 for alphabetical, 1 for size descending
-- Action:        Lists the size and number of rows for all or selected user tables and indexes
-- Return:        Rowset containing SchemaName, TableName, IndexName, TotalRows, TotalReservedMB, 
--                TotalUsedMB, TotalFreeMB in either alphabetical order or size descending order 
-- Refer to this video: https://youtu.be/mwOpnit0zqg
--
-- Test examples: 
/*

EXEC SDU_Tools.ListUserTableAndIndexSizes @DatabaseName = N'WideWorldImporters',
                                          @SchemasToList = N'ALL', 
                                          @TablesToList = N'ALL', 
                                          @ExcludeEmptyIndexes = 0,
										  @ExcludeTableStructure = 0,
                                          @IsOutputOrderedBySize = 0;

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = N'
SELECT s.[name] AS SchemaName,
       t.[name] AS TableName,
       i.[name] AS IndexName,
       p.rows AS TotalRows,
       CAST(ISNULL(SUM(au.total_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalReservedMB,
       CAST(ISNULL(SUM(au.used_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalUsedMB,
       CAST(ISNULL(SUM(au.total_pages - au.used_pages), 0) * 8192.0 / 1024.0 / 1024.0 AS decimal(18,2)) AS TotalFreeMB
FROM ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    ON s.[schema_id] = t.[schema_id] 
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.indexes AS i 
    ON t.[object_id] = i.[object_id]
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.partitions AS p 
    ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.allocation_units AS au 
    ON au.container_id = p.partition_id
WHERE t.is_ms_shipped = 0
AND t.[name] NOT LIKE ''dt%'' 
AND t.[name] <> ''sysdiagrams''' + @CrLf
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))' + @CrLf
      END 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))' + @CrLf
      END
    + CASE WHEN @ExcludeTableStructure = 0
           THEN N''
           ELSE N'    AND i.index_id > 1' + @CrLf
      END
    + N'GROUP BY s.[name], t.[name], i.[name], p.rows' + @CrLf
    + CASE WHEN @ExcludeEmptyIndexes = 0
           THEN N''
           ELSE N'HAVING p.rows > 0' + @CrLf 
      END
    + CASE WHEN @IsOutputOrderedBySize = 0 
           THEN N'ORDER BY SchemaName, TableName, IndexName;'
           ELSE N'ORDER BY TotalUsedMB DESC, SchemaName, TableName, IndexName;'
      END;
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE PROCEDURE SDU_Tools.ListUseOfDeprecatedDataTypes
@DatabaseName sysname,
@SchemasToList nvarchar(max),  -- N'ALL' for all
@TablesToList nvarchar(max),   -- N'ALL' for all
@ColumnsToList nvarchar(max)   -- N'ALL' for all
AS
BEGIN

-- Function:      Lists any use of deprecated data types
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        Lists any use of deprecated data types (user tables only)
-- Return:        Rowset containing SchemaName, TableName, ColumnName, DataType, and Suggested Alternate Type. 
--                Within each table, columns are listed in column ID order
-- Refer to this video: https://youtu.be/kVVxIMMwdRI
--
-- Test examples: 
/*

EXEC SDU_Tools.ListUseOfDeprecatedDataTypes @DatabaseName = N'msdb',
                                            @SchemasToList = N'ALL', 
                                            @TablesToList = N'ALL', 
                                            @ColumnsToList = N'ALL';

*/
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);

    DECLARE @SQL nvarchar(max) = 
'   SELECT s.[name] AS SchemaName, 
           t.[name] AS TableName, 
           c.[name] AS ColumnName,
           typ.[name] + CASE WHEN typ.[name] IN (N''decimal'', N''numeric'')
                             THEN N''('' + CAST(c.precision AS nvarchar(20)) + N'', '' 
                                  + CAST(c.scale AS nvarchar(20)) + N'')''
                             WHEN typ.[name] IN (N''varchar'', N''nvarchar'', N''char'', N''nchar'')
                             THEN N''('' + CASE WHEN c.max_length < 0 
                                              THEN N''max'' 
                                              ELSE CAST(c.max_length AS nvarchar(20)) 
                                         END + N'')''
                             WHEN typ.[name] IN (N''time'', N''datetime2'', N''datetimeoffset'')
                             THEN N''('' + CAST(c.scale AS nvarchar(20)) + N'')''
                             ELSE N''''
                        END AS DataType,
            CASE typ.[name] WHEN N''image'' THEN ''varbinary(max)''
                            WHEN N''text'' THEN ''varchar(max)''
                            WHEN N''ntext'' THEN ''nvarchar(max)''
            END AS SuggestedReplacementType
    FROM ' + QUOTENAME(@DatabaseName) + N'.sys.schemas AS s
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.tables AS t
        ON s.[schema_id] = t.[schema_id]
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.columns AS c
        ON t.[object_id] = c.[object_id] 
    INNER JOIN ' + QUOTENAME(@DatabaseName) + N'.sys.[types] AS typ 
        ON c.system_type_id = typ.system_type_id
        AND c.user_type_id = typ.user_type_id 
    WHERE t.[type] = N''U''
    AND typ.[name] IN (''image'', ''text'', ''ntext'')' + @CrLf
    + CASE WHEN @SchemasToList = N'ALL' 
           THEN N''
           ELSE N'    AND s.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @SchemasToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @TablesToList = N'ALL' 
           THEN N''
           ELSE N'    AND t.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @TablesToList + ''', N'','', 1)))'
      END + @CrLf 
    + CASE WHEN @ColumnsToList = N'ALL' 
           THEN N''
           ELSE N'    AND c.[name] IN (SELECT StringValue COLLATE DATABASE_DEFAULT FROM SDU_Tools.SplitDelimitedString('''
                + @ColumnsToList + ''', N'','', 1)))'
      END + @CrLf 
    + N'    ORDER BY SchemaName, TableName, c.column_id;';
    EXEC (@SQL);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.IsXActAbortON()
RETURNS bit
AS
BEGIN

-- Function:      Checks if XACT_ABORT is on
-- Parameters:    None
-- Action:        Checks if XACT_ABORT is on
-- Return:        bit
-- Refer to this video: https://youtu.be/Bx81-MTqr1k
-- 
-- Test examples: 
/*

SET XACT_ABORT OFF;
SELECT SDU_Tools.IsXActAbortON();
SET XACT_ABORT ON;
SELECT SDU_Tools.IsXActAbortON();
SET XACT_ABORT OFF;

*/
    RETURN CASE WHEN (16384 & @@OPTIONS) = 16384 
                THEN CAST(1 AS bit) 
                ELSE CAST(0 AS bit)
           END;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.StartOfFinancialYear
(
    @DateWithinYear date,
    @FirstMonthOfFinancialYear int
 
)
RETURNS date
AS
BEGIN

-- Function:      Return date of beginnning of financial year
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Calculates the first date of the financial year for any given date 
-- Return:        date
-- Refer to this video: https://youtu.be/wc8ZS_XPKZs
--
-- Test examples: 
/*

SELECT SDU_Tools.StartOfFinancialYear(SYSDATETIME(), 7);
SELECT SDU_Tools.StartOfFinancialYear(GETDATE(), 11);

*/
    RETURN CAST(CAST(YEAR(ISNULL(@DateWithinYear, SYSDATETIME())) 
                     - CASE WHEN MONTH(SYSDATETIME()) < @FirstMonthOfFinancialYear 
                            THEN 1 
                            ELSE 0 
                       END AS varchar(4)) 
                + RIGHT('00' + CAST(@FirstMonthOfFinancialYear AS varchar(2)), 2)
                + '01' AS date);
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.EndOfFinancialYear
(
    @DateWithinYear date,
    @FirstMonthOfFinancialYear int
 
)
RETURNS date
AS
BEGIN

-- Function:      Return last date of financial year
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Calculates the last date of the financial year for any given date 
-- Return:        date
-- Refer to this video: https://youtu.be/wc8ZS_XPKZs
--
-- Test examples: 
/*

SELECT SDU_Tools.EndOfFinancialYear(SYSDATETIME(), 7);
SELECT SDU_Tools.EndOfFinancialYear(GETDATE(), 11);

*/
    RETURN DATEADD(day, -1, DATEADD(year, 1, SDU_Tools.StartOfFinancialYear(@DateWithinYear, @FirstMonthOfFinancialYear)));
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.CalculateAge
(
    @StartingDate date,
    @CalculationDate date
)
RETURNS int
AS
BEGIN

-- Function:      Return an age in years from a starting date to a calculation date
-- Parameters:    @StartingDate date -> when the calculation begins (often a date of birth)
--                @CalculationDate date -> when the age is calculated to (often the current date)
-- Action:        Return an age in years from a starting date to a calculation date 
-- Return:        int    (NULL if @StartingDate is later than @CalculationDate)
-- Refer to this video: https://youtu.be/4XTubsQKPlw
--
-- Test examples: 
/*

SELECT SDU_Tools.CalculateAge('1968-11-20', SYSDATETIME());
SELECT SDU_Tools.CalculateAge('1942-09-16', '2017-12-31');

*/
    RETURN CASE WHEN @CalculationDate >= @StartingDate
                THEN DATEDIFF(year, @StartingDate, @CalculationDate) 
                     - CASE WHEN DATEADD(day, DATEDIFF(day, @StartingDate, @CalculationDate), @StartingDate) 
                                 < DATEADD(year, DATEDIFF(year, @StartingDate, @CalculationDate), @StartingDate)
                            THEN 1
                            ELSE 0
                        END
            END;
END;
GO

------------------------------------------------------------------------------------

CREATE FUNCTION SDU_Tools.PGObjectName(@SQLObjectName sysname)
RETURNS nvarchar(63)
AS 
BEGIN

-- Function:      Converts a SQL Server object name to a PostgreSQL object name
-- Parameters:    @SQLObjectName sysname
-- Action:        Converts a Pascal-cased or camel-cased SQL Server object name
--                to a name suitable for a database engine like PostgreSQL that
--                likes snake-cased names. Limits the identifier to 63 characters
--                and copes with a number of common abbreviations like ID that
--                would otherwise cause issues with the formation of the name.
-- Return:        varchar(63)
-- Refer to this video: https://youtu.be/2ZPa1dgOZew
--
-- Test examples: 
/*

SELECT SDU_Tools.PGObjectName(N'CustomerTradingName');
SELECT SDU_Tools.PGObjectName(N'AccountID');

*/
    RETURN SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                     SDU_Tools.SnakeCase(
                         SDU_Tools.SeparateByCase(@SQLObjectName, N' ')) COLLATE DATABASE_DEFAULT, 
                     N'i_d', N'id'), N'u_r_l', N'url'), N'b_i', N'bi'), N'f_k', N'fk'), N'd_f', N'df'), N'__', N'_'), N'__', N'_'), 1, 63);
END;
GO