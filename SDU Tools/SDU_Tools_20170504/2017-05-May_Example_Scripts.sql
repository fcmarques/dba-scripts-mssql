-- 2017-05-May SDU_Tools Sample Scripts 
-- Version 3.8
-- SDU_Tools Copyright 2017 Dr Greg Low

-- Name:          SDU_Tools.CalculateAge
-- Function:      Return an age in years from a starting date to a calculation date
-- Parameters:    @StartingDate date -> when the calculation begins (often a date of birth)
--                @CalculationDate date -> when the age is calculated to (often the current date)
-- Action:        Return an age in years from a starting date to a calculation date 
-- Return:        int    (NULL if @StartingDate is later than @CalculationDate)
--

SELECT SDU_Tools.CalculateAge('1968-11-20', SYSDATETIME());
SELECT SDU_Tools.CalculateAge('1942-09-16', '2017-12-31');
GO

-- Name:          SDU_Tools.AsciiOnly
-- Function:      Removes or replaces all non-ASCII characters in a string
-- Parameters:    @InputString nvarchar(max) - String to be processed (unicode or single byte)
--                @ReplacementCharacters varchar(10) - Up to 10 characters to replace non-ASCII 
--                                                     characters with - can be blank
--                @AreControlCharactersRemoved bit - Should all control characters also be replaced
-- Action:        Finds all non-ASCII characters in a string and either removes or replaces them
-- Return:        varchar(max)
--

SELECT SDU_Tools.AsciiOnly('Hello°â€¢ There', '', 0);
SELECT SDU_Tools.AsciiOnly('Hello° There', '?', 0);
SELECT SDU_Tools.AsciiOnly('Hello° There' + CHAR(13) + CHAR(10) + ' John', '', 1);
GO

-- Name:          SDU_Tools.FormatDataTypeName 
-- Function:      Converts data type components into an output string
-- Parameters:    @DataTypeName sysname - the name of the data type
--                @Precision int - the decimal or numeric precision
--                @Scale int - the scale for the value
--                @MaximumLength - the maximum length of string values
-- Action:        Converts data type, precision, scale, and maximum length
--                into the standard format used in scripts
-- Return:        nvarchar(max)
--

SELECT SDU_Tools.FormatDataTypeName(N'decimal', 18, 2, NULL);
SELECT SDU_Tools.FormatDataTypeName(N'nvarchar', NULL, NULL, 12);
SELECT SDU_Tools.FormatDataTypeName(N'bigint', NULL, NULL, NULL);

-- Name:          SDU_Tools.PGObjectName 
-- Function:      Converts a SQL Server object name to a PostgreSQL object name
-- Parameters:    @SQLObjectName sysname
-- Action:        Converts a Pascal-cased or camel-cased SQL Server object name
--                to a name suitable for a database engine like PostgreSQL that
--                likes snake-cased names. Limits the identifier to 63 characters
--                and copes with a number of common abbreviations like ID that
--                would otherwise cause issues with the formation of the name.
-- Return:        varchar(63)
--

SELECT SDU_Tools.PGObjectName(N'CustomerTradingName');
SELECT SDU_Tools.PGObjectName(N'AccountID');
GO

-- Name:          SDU_Tools.ListMismatchedDataTypes
-- Function:      ListMismatchedDataTypes
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        List columns with the same name that are defined with different data types (user tables only)
-- Return:        Rowset a list of mismatched DataTypes
--

EXEC SDU_Tools.ListMismatchedDataTypes @DatabaseName = N'WideWorldImporters',
                                       @SchemasToList = N'ALL', 
                                       @TablesToList = N'ALL', 
                                       @ColumnsToList = N'ALL';

-- Name:          SDU_Tools.ExecuteJobAndWaitForCompletion
-- Function:      Executes a SQL Server Agent job synchronously (waits for it to complete)
-- Parameters:    @JobName sysname         -> Job to execute
--                @MaximumWaitSecondsForJobStart int -> Timeout for waiting for job start
--                @MaximumWaitSecondsForJobCompletion int -> Timeout waiting for job completion
--                @PrintDebugOutput bit -> set to 1 for more verbose output
-- Action:        Starts an agent job and waits for it to complete
-- Return:        Error on unable to execute job or timeout
--

EXEC SDU_Tools.ExecuteJobAndWaitForCompletion @JobName = 'Job that does not exist', @PrintDebugOutput = 1;
EXEC SDU_Tools.ExecuteJobAndWaitForCompletion @JobName = 'Daily ETL', @PrintDebugOutput = 1;

-- Name:          SDU_Tools.CapturePerformanceTuningTrace
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
--

EXEC SDU_Tools.CapturePerformanceTuningTrace @DurationInMinutes = 2,
                                             @TraceFileName = N'SDU_Trace',
                                             @OutputFolderName = N'C:\Temp',
                                             @DatabasesToCheck = N'WideWorldImporters,WideWorldImportersDW',
                                             @MaximumFileSizeMB = 8192;


-- Name:          SDU_Tools.LoadPerformanceTuningTrace
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

EXEC SDU_Tools.LoadPerformanceTuningTrace @TraceFileName = N'SDU_Trace',
                                          @TraceFileFolderName = N'C:\Temp',
                                          @ExportDatabaseName = N'Development',
                                          @ExportSchemaName = N'dbo',
                                          @ExportTableName = N'SDU_Trace',
                                          @IncludeNormalizedCommand = 1,
                                          @IgnoreSPReset = 1;

-- Name:          SDU_Tools.AnalyzePerformanceTuningTrace
-- Function:      Analyze a loaded performance tuning trace file
-- Parameters:    @TraceDatabaseName sysname -- (default is current database) Database that the trace was loaded into
--                @TraceSchemaName sysname -- (default is dbo) Schema for the table that the trace was loaded into
--                @TraceTableName sysname -- (default is SDU_Trace) Name of the table that the trace was loaded into
-- Action:        Analyzes a loaded performance tuning trace file in terms of both normalized and unnormalized queries
-- Return:        Status (0 = success)
--

EXEC SDU_Tools.AnalyzePerformanceTuningTrace @TraceDatabaseName = NULL,
                                             @TraceSchemaName = N'dbo',
                                             @TraceTableName = N'SDU_Trace';

-----------------------------------------------------------------------------------
-- 2017-04-April Example Scripts

-- Name:          SDU_Tools.FindSubsetIndexes
-- Function:      Finds indexes that appear to be subsets of other indexes
-- Parameters:    @DatabasesToCheck -- either ALL (default) or a comma-delimited list of database names
-- Action:        Finds indexes that appear to be subsets of other indexes
-- Return:        One rowset with details of each subset index

USE WWI_Production;
GO
CREATE INDEX IX_dbo_Customers_TradingName_CreditLimit
ON dbo.Customers 
(
	TradingName,
	CreditLimit
);
GO
USE Development;
GO
EXEC SDU_Tools.ListSubsetIndexes N'WWI_Production';
GO

-- Name:          SDU_Tools.QuoteString
-- Function:      Quotes a string
-- Parameters:    @InputString varchar(max)
-- Action:        Quotes a string (also doubles embedded quotes)
-- Return:        nvarchar(max)

DECLARE @Him nvarchar(max) = N'his name';
DECLARE @Them nvarchar(max) = N'they''re here';

SELECT @Him AS Him, SDU_Tools.QuoteString(@Him) AS QuotedHim
     , @Them AS Them, SDU_Tools.QuoteString(@Them) AS QuotedThem;

GO

-- Name:          SDU_Tools.LeftPad 
-- Function:      Left pads a string
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Left pads a string to a target length with a given padding character.
--                Truncates the data if it is too large. With implicitly cast numeric
--                and other data types if not passed as strings.
-- Return:        nvarchar(max)

SELECT SDU_Tools.LeftPad(N'Hello', 14, N'o');
SELECT SDU_Tools.LeftPad(18, 10, N'0');

-- Name:          SDU_Tools.RightPad
-- Function:      Right pads a string
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Right pads a string to a target length with a given padding character.
--                Truncates the data if it is too large. With implicitly cast numeric
--                and other data types if not passed as strings.
-- Return:        nvarchar(max)

SELECT SDU_Tools.RightPad(N'Hello', 14, N'o');
SELECT SDU_Tools.RightPad(18, 10, N'.');

-- Name:          SDU_Tools.SeparateByCase
-- Function:      Insert a separator between Pascal cased or Camel cased words
-- Parameters:    @InputString varchar(max)
-- Action:        Insert a separator between Pascal cased or Camel cased words
-- Return:        nvarchar(max)

SELECT SDU_Tools.SeparateByCase(N'APascalCasedSentence', N' ');
SELECT SDU_Tools.SeparateByCase(N'someCamelCasedWords', N' ');

-- Name:          SDU_Tools.SecondsToDuration
-- Function:      Convert a number of seconds to a SQL Server duration string
-- Parameters:    @NumberOfSeconds int 
-- Action:        Converts a number of seconds to a SQL Server duration string (similar to programming identifiers)
--                The value must be less than 24 hours (between 0 and 86399) otherwise the return value is NULL
-- Return:        varchar(8)

SELECT SDU_Tools.SecondsToDuration(910);   -- 15 minutes 10 seconds
SELECT SDU_Tools.SecondsToDuration(88000);   -- should return NULL

-- Name:          SDU_Tools.AnalyzeTableColumns
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

EXEC SDU_Tools.AnalyzeTableColumns N'WideWorldImporters', N'Warehouse', N'StockItems', 1, 1, 100; 

-- Name:          SDU_Tools.PrintMessage
-- Function:      Print a message immediately 
-- Parameters:    @MessageToPrint nvarchar(max) -> The message to be printed
-- Action:        Prints a message immediately rather than waiting for PRINT to be returned
-- Return:        Nil

EXEC SDU_Tools.PrintMessage N'Hello';

-- Name:          SDU_Tools.StartOfFinancialYear
-- Function:      Return date of beginnning of financial year
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Calculates the first date of the financial year for any given date 
-- Return:        date

SELECT SDU_Tools.StartOfFinancialYear(SYSDATETIME(), 7);
SELECT SDU_Tools.StartOfFinancialYear(GETDATE(), 11);

-- Name:          SDU_Tools.EndOfFinancialYear
-- Function:      Return last date of financial year
-- Parameters:    @DateWithinYear date (use GETDATE() or SYSDATETIME() for today)
--                @FirstMonthOfFinancialYear int
-- Action:        Calculates the last date of the financial year for any given date 
-- Return:        date

SELECT SDU_Tools.EndOfFinancialYear(SYSDATETIME(), 7);
SELECT SDU_Tools.EndOfFinancialYear(GETDATE(), 11);

GO

-----------------------------------------------------------------------------------
-- 2017-03-March Example Scripts

-- Create the sample database for the examples

USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE [name] = N'WWI_Production')
BEGIN
	ALTER DATABASE WWI_Production SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE WWI_Production;
END;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE [name] = N'WWI_UAT')
BEGIN
	ALTER DATABASE WWI_UAT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE WWI_UAT;
END;
GO

CREATE DATABASE WWI_Production;
GO

USE WWI_Production;
GO

CREATE TABLE dbo.Customers
(
	CustomerID int IDENTITY(1,1) 
		CONSTRAINT PK_dbo_Customers PRIMARY KEY,
	TradingName nvarchar(30) NOT NULL,
	PrimaryPhoneNumber nvarchar(20) NULL,
	CreditLimit decimal(18,2) NULL
);

CREATE INDEX IX_dbo_Customers_TradingName 
ON dbo.Customers 
(
	TradingName
);
GO

INSERT dbo.Customers (TradingName, PrimaryPhoneNumber, CreditLimit)
VALUES ('ACM Cinemas Oz', '+61 7 3423-9929', 4000);
GO

CREATE DATABASE WWI_UAT;
GO

USE WWI_UAT;
GO

CREATE TABLE dbo.Customers
(
	CustomerID int IDENTITY(1,1) 
		CONSTRAINT PK_dbo_Customers PRIMARY KEY,
	TradingName nvarchar(50) NOT NULL,
	CreditLimit decimal(18,2) NULL,
	PrimaryPhoneNumber text NULL
);

CREATE INDEX IX_dbo_Customers_TradingName 
ON dbo.Customers 
(
	TradingName
)
INCLUDE
(
	CreditLimit
);
GO

SELECT *
INTO dbo.Customers_Backup
FROM dbo.Customers;
GO

USE Development;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE [name] = N'Development')
BEGIN
	ALTER DATABASE Development SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Development;
END;
GO

CREATE DATABASE Development;
GO

USE Development;
GO

SET NOCOUNT ON;
GO

-- Name:          SDU_Tools.ProperCase
-- Function:      Apply Proper Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Proper Casing to a string !!! (also removes multiple spaces)
-- Return:        varchar(max)

SELECT SDU_Tools.ProperCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.ProperCase(N'janet mcdermott');
SELECT SDU_Tools.ProperCase(N'the curly-Haired  company');
SELECT SDU_Tools.ProperCase(N'po Box 1086');
GO

-- Name:          SDU_Tools.TitleCase
-- Function:      Apply Title Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Title Casing to a string (similar to book titles)
-- Return:        nvarchar(max)

SELECT SDU_Tools.TitleCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.TitleCase(N'janet mcdermott');
SELECT SDU_Tools.TitleCase(N'the case of sherlock holmes and the curly-Haired  company');
GO

-- Name:          SDU_Tools.CamelCase
-- Function:      Apply Camel Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Camel Casing to a string (also removes spaces)
-- Return:        varchar(max)

SELECT SDU_Tools.CamelCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.CamelCase(N'janet mcdermott');
SELECT SDU_Tools.CamelCase(N'the curly-Haired  company');
SELECT SDU_Tools.CamelCase(N'po Box 1086');
GO

-- Name:          SDU_Tools.PascalCase
-- Function:      Apply Pascal Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Pascal Casing to a string (also removes spaces)
-- Return:        varchar(max)

SELECT SDU_Tools.PascalCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.PascalCase(N'janet mcdermott');
SELECT SDU_Tools.PascalCase(N'the curly-Haired  company');
SELECT SDU_Tools.PascalCase(N'po Box 1086');
GO

-- Name:          SDU_Tools.SnakeCase
-- Function:      Apply Snake Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Snake Casing to a string !!! (also removes multiple spaces)
-- Return:        varchar(max)

SELECT SDU_Tools.SnakeCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.SnakeCase(N'janet mcdermott');
SELECT SDU_Tools.SnakeCase(N'the curly-Haired  company');
SELECT SDU_Tools.SnakeCase(N'po Box 1086');
GO

-- Name:          SDU_Tools.KebabCase
-- Function:      Apply Kebab Casing to a string
-- Parameters:    @InputString varchar(max)
-- Action:        Apply Kebab Casing to a string !!! (also removes multiple spaces)
-- Return:        varchar(max)

SELECT SDU_Tools.KebabCase(N'the  quick   brown fox consumed a macrib at mcdonalds');
SELECT SDU_Tools.KebabCase(N'janet mcdermott');
SELECT SDU_Tools.KebabCase(N'the curly-Haired  company');
SELECT SDU_Tools.KebabCase(N'po Box 1086');
GO

-- Name:          SDU_Tools.PercentEncode
-- Function:      Apply percent encoding to a string (could be used for URL Encoding)
-- Parameters:    @StringToEncode varchar(max)
-- Action:        Encodes reserved characters that might be used in HTML or URL encoding
--                Encoding is based on PercentEncoding article https://en.wikipedia.org/wiki/Percent-encoding
--                Only characters allowed unencoded are A-Z,a-z,0-9,-,_,.,~     (note: not the comma)
-- Return:        varchar(max)

SELECT SDU_Tools.PercentEncode('www.sqldownunder.com/podcasts');
SELECT SDU_Tools.PercentEncode('this should be a URL but it contains spaces and special characters []{}234');
GO

-- Name:          SDU_Tools.SplitDelimitedString
-- Function:      Splits a delimited string (usually either a CSV or TSV)
-- Parameters:    @StringToSplit nvarchar(max)       -> string that will be split
--                @Delimiter nvarchar(10)            -> delimited used (usually either N',' or NCHAR(9) for tab)
--                @TrimOutput bit                    -> if 1 then trim strings before returning them
-- Action:        Splits delimited strings - usually comma-delimited strings CSVs or tab-delimited strings (TSVs)
--                Delimiter can be specified
--                Optionally, the output strings can be trimmed
-- Return:        Table containing a column called StringValue nvarchar(max)

SELECT * FROM SDU_Tools.SplitDelimitedString(N'hello, there, greg', N',', 0);
SELECT * FROM SDU_Tools.SplitDelimitedString(N'hello' + NCHAR(9) + N'there' + NCHAR(9) + N'greg', NCHAR(9), 1);
GO

-- Name:          SDU_Tools.TrimWhitespace
-- Function:      Trims all whitespace around a string
-- Parameters:    @InputString nvarchar(max)
-- Action:        Removes any leading or trailing space, tab, carriage return, 
--                linefeed characters.
-- Return:        nvarchar(max)

DECLARE @CR_LF nchar(2) = NCHAR(13) + NCHAR(10);
DECLARE @TAB char(1) = NCHAR(9);

SELECT '-->' + SDU_Tools.TrimWhitespace(N'Test String') + '<--';
SELECT '-->' + SDU_Tools.TrimWhitespace(N'  Test String     ') + '<--';
SELECT '-->' + SDU_Tools.TrimWhitespace(N'  Test String  ' + @CR_LF + N' ' + @TAB + N'   ') + '<--';
GO

-- Name:          SDU_Tools.PreviousNonWhitespaceCharacter
-- Function:      Locates the previous non-whitespace character in a string
-- Parameters:    @StringToTest nvarchar(max)
--                @CurrentPosition int
-- Action:        Finds the previous non-whitespace character backwards from the 
--                current position.
-- Return:        nvarchar(1)

DECLARE @CR_LF nchar(2) = NCHAR(13) + NCHAR(10);
DECLARE @TAB char(1) = NCHAR(9);
DECLARE @TestString nvarchar(max) = N'Hello there ' + @TAB + ' fred ' + @CR_LF + 'again';
--                                    123456789112      3     456789     2  1     23456

SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,11); -- should be r
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,15); -- should be e
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,22); -- should be d
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,1);  -- should be blank
SELECT SDU_Tools.PreviousNonWhitespaceCharacter(@TestString,0);  -- should be blank
GO

-- Name:          SDU_Tools.Base64ToVarbinary
-- Function:      Converts a base 64 value to varbinary
-- Parameters:    @Base64ValueToConvert varchar(max)
-- Action:        Converts a base 64 value to varbinary
-- Return:        varbinary(max)

SELECT SDU_Tools.Base64ToVarbinary('qrvM3e7/');
GO

-- Name:          SDU_Tools.BarbinaryToBase64
-- Function:      Converts a varbinary value to base 64 encoding
-- Parameters:    @VarbinaryValueToConvert varbinary(max)
-- Action:        Converts a varbinary value to base 64 encoding
-- Return:        varchar(max)

SELECT SDU_Tools.VarbinaryToBase64(0xAABBCCDDEEFF);
GO

-- Name:          SDU_Tools.CharToHexadecimal
-- Function:      Converts a single character to a hexadecimal string
-- Parameters:    CharacterToConvert char(1)
-- Action:        Converts a single character to a hexadecimal string
-- Return:        char(2)

SELECT SDU_Tools.CharToHexadecimal('A');
SELECT SDU_Tools.CharToHexadecimal('K');
SELECT SDU_Tools.CharToHexadecimal('1');
SELECT SDU_Tools.CharToHexadecimal('/');
GO

-- Name:          SDU_Tools.SQLVariantInfo
-- Function:      Returns information about a sql_variant value
-- Parameters:    @SQLVariantValue sql_variant
-- Action:        Returns information about a sql_variant value
-- Return:        Rowset with BaseType, MaximumLength

DECLARE @Value sql_variant;

SET @Value = 'hello';
SELECT * FROM SDU_Tools.SQLVariantInfo(@Value);
GO

-- Name:          SDU_Tools.GetDBSchemaCoreComparison
-- Function:      Checks the schema of two databases, looking for basic differences (user objects only)
-- Parameters:    @Database1 sysname              -> name of the first database to check
--                @Database2 sysname              -> name of the second database to compare
--                @IgnoreColumnID bit             -> set to 1 if tables with the same columns but in different order
--                                                   are considered equivalent, otherwise set to 0
--                @IgnoreFillFactor bit           -> set to 1 if index fillfactors are to be ignored, otherwise
--                                                   set to 0
-- Action:        Performs a comparison of the schema of two databases
-- Return:        Rowset describing differences

EXEC SDU_Tools.GetDBSchemaCoreComparison N'WWI_Production', N'WWI_UAT', 1, 1;
GO

-- Name:          SDU_Tools.GetTableSchemaComparison
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

EXEC SDU_Tools.GetTableSchemaComparison N'WWI_Production', N'dbo', N'Customers', N'WWI_UAT', N'dbo', N'Customers', 1, 1;
GO

EXEC SDU_Tools.GetTableSchemaComparison N'WWI_Production', N'dbo', N'Customers', N'WWI_UAT', N'dbo', N'Customers', 0, 1;
GO

-- Name:          SDU_Tools.FindStringWithinADatabase
-- Function:      Finds a string anywhere within a database
-- Parameters:    @DatabaseName sysname            -> database to check
--                @StringToSearchFor nvarchar(max) -> string we're looking for
--                @IncludeActualRows bit           -> should the rows containing it be output
-- Action:        Finds a string anywhere within a database. Can be useful for testing masking 
--                of data. Checks all string type columns and XML columns.
-- Return:        Rowset for found locations, optionally also output the rows

EXEC SDU_Tools.FindStringWithinADatabase N'WideWorldImporters', N'Kayla', 0; 
EXEC SDU_Tools.FindStringWithinADatabase N'WideWorldImporters', N'Kayla', 1; 
GO

-- Name:          SDU_Tools.ListAllDataTypesInUse
-- Function:      Lists every distinct data type being used
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        ListAllDataTypesInUse (user tables only)
-- Return:        Rowset a distinct list of DataTypes

EXEC SDU_Tools.ListAllDataTypesInUse @DatabaseName = N'WWI_Production',
                                     @SchemasToList = N'ALL', 
                                     @TablesToList = N'ALL', 
                                     @ColumnsToList = N'ALL';

EXEC SDU_Tools.ListAllDataTypesInUse @DatabaseName = N'WideWorldImporters',
                                     @SchemasToList = N'ALL', 
                                     @TablesToList = N'ALL', 
                                     @ColumnsToList = N'ALL';
GO

-- Name:          SDU_Tools.ListColumnsAndDataTypes
-- Function:      Lists the data types for all columns
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        Lists the data types for all columns (user tables only)
-- Return:        Rowset containing SchemaName, TableName, ColumnName, and DataType. Within each 
--                table, columns are listed in column ID order

EXEC SDU_Tools.ListColumnsAndDataTypes @DatabaseName = N'WWI_Production',
                                       @SchemasToList = N'ALL', 
                                       @TablesToList = N'ALL', 
                                       @ColumnsToList = N'ALL';

EXEC SDU_Tools.ListColumnsAndDataTypes @DatabaseName = N'WideWorldImporters',
                                       @SchemasToList = N'ALL', 
                                       @TablesToList = N'ALL', 
                                       @ColumnsToList = N'ALL';
GO

-- Name:          SDU_Tools.ListUnusedIndexes
-- Function:      List indexes that appear to be unused
-- Parameters:    @DatabaseName sysname         -> Database to process
-- Action:        List indexes that appear to be unused (user tables only)
--                These indexes might be candidates for reconsideration and removal
--                but be careful about doing so, particularly for unique indexes
-- Return:        Rowset of schema name, table, name, index name, and is unique

EXEC SDU_Tools.ListUnusedIndexes @DatabaseName = N'WWI_Production';
GO

-- Name:          SDU_Tools.ListUseOfDeprecatedDataTypes
-- Function:      Lists any use of deprecated data types
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ColumnsToList nvarchar(max)  -> 'ALL' or comma-delimited list of tables to list
-- Action:        Lists any use of deprecated data types (user tables only)
-- Return:        Rowset containing SchemaName, TableName, ColumnName, and DataType. Within each 
--                table, columns are listed in column ID order

EXEC SDU_Tools.ListUseOfDeprecatedDataTypes @DatabaseName = N'msdb',
                                            @SchemasToList = N'ALL', 
                                            @TablesToList = N'ALL', 
                                            @ColumnsToList = N'ALL';
GO

-- Name:          SDU_Tools.ListUserTableSizes
-- Function:      Lists the size and number of rows for all or selected user tables
-- Parameters:    @DatabaseName sysname         -> Database to process
--                @SchemasToList nvarchar(max)  -> 'ALL' or comma-delimited list of schemas to list
--                @TablesToList nvarchar(max)   -> 'ALL' or comma-delimited list of tables to list
--                @ExcludeEmptyTables bit       -> 0 for list all, 1 for don't list empty objects
--                @IsOutputOrderedBySize bit    -> 0 for alphabetical, 1 for size descending
-- Action:        Lists the size and number of rows for all or selected user tables
-- Return:        Rowset containing SchemaName, TableName, TotalRows, TotalReservedMB, TotalUsedMB,
--                   TotalFreeMB in either alphabetical order or size descending order 

EXEC SDU_Tools.ListUserTableSizes @DatabaseName = N'WideWorldImporters',
                                  @SchemasToList = N'ALL', 
                                  @TablesToList = N'ALL', 
                                  @ExcludeEmptyTables = 0,
                                  @IsOutputOrderedBySize = 0;
GO

-- Name:          SDU_Tools.ListUserTableAndIndexSizes
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

EXEC SDU_Tools.ListUserTableAndIndexSizes @DatabaseName = N'WideWorldImporters',
                                          @SchemasToList = N'ALL', 
                                          @TablesToList = N'ALL', 
                                          @ExcludeEmptyIndexes = 0,
										  @ExcludeTableStructure = 0,
                                          @IsOutputOrderedBySize = 0;
GO

-- Name:          SDU_Tools.EmptySchema
-- Function:      Removes objects in the specified schema in the specified database
-- Parameters:    @DatabaseName -> database containing the schema
--                @SchemaName -> schema to empty (cannot be dbo, sys, or SDU_Tools)
-- Action:        Removes objects in the specified schema in the current database
--                Note: must be run from within the same database as the schema
-- Return:        One rowset with details of each currently executing backup

USE WideWorldImporters;
GO
CREATE SCHEMA XYZABC AUTHORIZATION dbo;
GO
CREATE TABLE XYZABC.TestTable (TestTableID int IDENTITY(1,1) PRIMARY KEY);
GO
USE Development;
GO
EXEC SDU_Tools.EmptySchema @DatabaseName = N'WideWorldImporters', @SchemaName = N'XYZABC';
GO

-- Name:          SDU_Tools.IsXActAbortON
-- Function:      Checks if XACT_ABORT is on
-- Parameters:    None
-- Action:        Checks if XACT_ABORT is on
-- Return:        bit

SET XACT_ABORT OFF;
SELECT SDU_Tools.IsXActAbortON();
SET XACT_ABORT ON;
SELECT SDU_Tools.IsXActAbortON();
SET XACT_ABORT OFF;
GO

-- Name:          SDU_Tools.ShowBackupCompletionEstimates
-- Function:      Shows completion estimates for any currently executing backups
-- Parameters:    None
-- Action:        Shows completion estimates for any currently executing backups
-- Return:        One rowset with details of each currently executing backup
-- Test examples: 

-- BACKUP DATABASE WideWorldImporters TO DISK = 'C:\temp\WWI.bak' WITH FORMAT, INIT;
EXEC SDU_Tools.ShowBackupCompletionEstimates;
GO

-- Name:          SDU_Tools.ShowCurrentBlocking
-- Function:      Looks for requests that are blocking right now
-- Parameters:    @DatabaseName sysname         -> Database to process
-- Action:        Lists sessions holding locks, the SQL they are executing, then 
--                lists blocked items and the SQL they are trying to execute
-- Return:        Two rowsets

EXEC SDU_Tools.ShowCurrentBlocking @DatabaseName = N'WWI_Production';
GO
-- USE WWI_Production; BEGIN TRAN; UPDATE dbo.Customers SET CreditLimit += 100;
-- USE WWI_Production; SELECT * FROM dbo.Customers;
-- ROLLBACK;

EXEC SDU_Tools.ShowCurrentBlocking @DatabaseName = N'WWI_Production';
GO

-- Name:          SDU_Tools.ScriptSQLLogins
-- Function:      Scripts all SQL Logins
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all specified SQL logins, with password hashes, security IDs, default 
--                databases and languages
-- Return:        nvarchar(max)

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptSQLLogins(N'ALL');
PRINT @SQL;
GO
CREATE LOGIN GregInternal WITH PASSWORD = N'BigSecret01';
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptSQLLogins(N'GregInternal,sa');
PRINT @SQL;
GO
DROP LOGIN GregInternal;
GO

-- Name:          SDU_Tools.ScriptWindowsLogins
-- Function:      Scripts all Windows Logins
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all specified Windows logins, with default databases and languages
-- Return:        nvarchar(max)

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptWindowsLogins(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptWindowsLogins(N'NT AUTHORITY\SYSTEM,NT SERVICE\SQLWriter');
PRINT @SQL;
GO

-- Name:          SDU_Tools.ScriptServerRoleMembers
-- Function:      Scripts all Server Role Members
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all server role members for the selected logins
-- Return:        nvarchar(max)

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerRoleMembers(N'ALL');
PRINT @SQL;
GO
CREATE LOGIN GregInternal WITH PASSWORD = N'BigSecret01';
GO
ALTER SERVER ROLE diskadmin ADD MEMBER GregInternal;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerRoleMembers(N'GregInternal,sa');
PRINT @SQL;
GO
DROP LOGIN GregInternal;
GO

-- Name:          SDU_Tools.ScriptServerPermissions
-- Function:      Scripts all Server Permissions
-- Parameters:    @LoginsToScript nvarchar(max) - comma-delimited list of login names to script or ALL
-- Action:        Scripts all server permissions for the selected logins
-- Return:        nvarchar(max)

DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerPermissions(N'ALL');
PRINT @SQL;
GO
DECLARE @SQL nvarchar(max) = SDU_Tools.ScriptServerPermissions(N'GregInternal,sa');
PRINT @SQL;
GO

-- Name:          SDU_Tools.ExecuteOrPrint
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

DECLARE @SQL nvarchar(max) = N'
SELECT ''Hello Greg'';
SELECT 2 + 3;
GO
SELECT ''Wow'';
';

EXEC SDU_Tools.ExecuteOrPrint @StringToExecuteOrPrint = @SQL,
                              @PrintOnly = 1,
                              @IncludeGO = 1,
                              @NumberOfCrLfAfterGO = 1;

SET @SQL = N'SELECT ''Another statement'';';

EXEC SDU_Tools.ExecuteOrPrint @StringToExecuteOrPrint = @SQL,
                              @PrintOnly = 1,
                              @IncludeGO = 1,
                              @NumberOfCrLfAfterGO = 1;
GO

DECLARE @SQL nvarchar(max) = N'
SELECT ''Hello Greg'';
SELECT 2 + 3;
GO
SELECT ''Wow'';
';

EXEC SDU_Tools.ExecuteOrPrint @StringToExecuteOrPrint = @SQL,
                              @PrintOnly = 0,
                              @IncludeGO = 1,
                              @NumberOfCrLfAfterGO = 1;
GO

-- Name:          SDU_Tools.ExtractSQLTemplate
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

SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where customerid = 12 and customername = ''fred'' order by customerid;', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where customerid = 12', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select (2+2);', 4000);
SELECT SDU_Tools.ExtractSQLTemplate('select * from customers where sid = 0x12AEBCDEF2342AE2', 4000);




