/*
The C.R.U.D. of Excel
=====================
 
 
 
Phil and I have teamed up on this workbench, which demonstrates how to create, read, update and delete information in Excel using T-SQL, from SQL Server. As always, the workbench is structured so that it can be pasted into Query Analyser and SSMS, and the individual examples executed - you can download the .sql from the "Code Download" link above, load it up and start experimenting!
 
Contents
========
 
Creating Excel spreadsheets via ADODB
Manipulating Excel data via a linked server
Synchronising the Spreadsheet with SQL Server Tables
Manipulating Excel data using OPENDATASOURCE and OPENROWSET functions
Creating Excel spreadsheets using sp_MakeWebTask
OLE Automation
 
 
 
We start by showing you how to create an Excel Spreadsheet from SQL Server in TSQL(Transact SQL), create a worksheet, attach to it as a linked server, write to it, read from it, update it as if it was an ordinary SQL Server Database table, and then synchronise the data in the worksheet with SQL Server. We also illustrate the use of OPENQUERY, OPENDATASOURCE and OPENROWSET.
 
To create the Excel spreadsheet, we show how to attach to an ADODB source from SQL Server and execute SQL against that source. We then show you an alternative 'quick cheat' way (using sp_makewebtask) to create and populate an excel spreadsheet from Transact SQL.
 
If you need more control over the Excel Spreadsheet that you are creating, we then show you how to do it via OLE automation. This will enable you to do anything you can do via keystrokes, and allow you to generate full Excel reports with pivot tables and Graphs.
 
Using this technique, you should be able to populate the data, or place data in particular calls or ranges. You can even do 'macro substitutions'
 
A word of caution before you start. If you have your security wide open, it is not just you who would be able to write out data as a spreadsheet. An intruder would be able to do it with that list of passwords or credit-card numbers. In a production system, this sort of operation needs to be properly ring-fenced. We tend to create a job queue and have a special user, with the appropriate permissions, on the Task Scheduler, to do anything that involves OLE automation or xp_CMDShell. Security precautions can get quite complex, but they are outside the scope of the article.
 
Some of what we illustrate can be done using DTS or SSIS. Unfortunately, these are outside the scope of this article. In fact, transferring data between Excel and SQL Server can be done in a surprising variety of ways and it would be fun one day to
try to list them all
  
First we need some simple test data
*/
CREATE TABLE ##CambridgePubs
        (Pubname VARCHAR(40),
        Address VARCHAR(80),
        Postcode VARCHAR(8))
 
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Bees In The Wall','36 North Road,
Whittlesford, Cambridge','CB2 4NZ'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Blackamoors Head','205 Victoria Road,
Cambridge','CB4 3LF'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Blue Lion','2 Horningsea Road,
Fen Ditton, Cambridge','CB5 8SZ'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Cambridge Blue','85-87 Gwydir Street,
Cambridge','CB1 2LG'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Champion Of The Thames','68 King Street,
Cambridge','CB1 1LN'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Cross Keys','77 Ermine Street,
Caxton, Cambridge','CB3 8PQ'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Crown Inn','11 High Street,
Linton, Cambridge','CB1 6HS'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Devonshire Arms','1 Devonshire Road,
Cambridge','CB1 2BH'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Duke Of Argyle','90 Argyle Street,
Cambridge','CB1 3LS'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Duke Of Wellington','49 Alms Hill,
Bourn, Cambridge','CB3 7SH'
INSERT INTO ##CambridgePubs (PubName, Address, Postcode)
    SELECT 'Eagle Public House','Benet Street,
Cambridge','CB2 3QN'
/*And so on. (The full import file is in the ZIP, as is the Excel
file!)
Create the table and then execute the contents of CambridgePubs.SQL
 
Creating Excel spreadsheets via ADODB
-----------------------------------------
 
First, we need to create the spreadsheet with the correct headings (PubName, Address, PostCode)
 
There are two possible ways one might do this. The most obvious way is using the CREATE statement to create the worksheet and define the columns, but there seems to be no way of doing this by linking the excel FILE, unless the Excel file already exists. We need a utility stored procedure to get at ADODB in order to create databases and execute DDL and SQL against it. */
 
CREATE PROCEDURE spExecute_ADODB_SQL
@DDL VARCHAR(2000),
@DataSource VARCHAR(100),
@Worksheet VARCHAR(100)=NULL,
@ConnectionString VARCHAR(255)
--    = 'Provider=Microsoft.Jet.OLEDB.4.0;
    = 'Provider=Microsoft.ACE.OLEDB.15.0;
Data Source=%DataSource;
Extended Properties=Excel 8.0'
AS
DECLARE
    @objExcel INT,
    @hr INT,
    @command VARCHAR(255),
    @strErrorMessage VARCHAR(255),
    @objErrorObject INT,
    @objConnection INT,
    @bucket INT
 
SELECT @ConnectionString
    =REPLACE (@ConnectionString, '%DataSource', @DataSource)
IF @Worksheet IS NOT NULL
    SELECT @DDL=REPLACE(@DDL,'%worksheet',@Worksheet)
 
SELECT @strErrorMessage='Making ADODB connection ',
            @objErrorObject=NULL
EXEC @hr=sp_OACreate 'ADODB.Connection', @objconnection OUT
IF @hr=0
    SELECT @strErrorMessage='Assigning ConnectionString property "'
            + @ConnectionString + '"',
            @objErrorObject=@objconnection
IF @hr=0 EXEC @hr=sp_OASetProperty @objconnection,
            'ConnectionString', @ConnectionString
IF @hr=0 SELECT @strErrorMessage
        ='Opening Connection to XLS, for file Create or Append'
IF @hr=0 EXEC @hr=sp_OAMethod @objconnection, 'Open'
IF @hr=0 SELECT @strErrorMessage
        ='Executing DDL "'+@DDL+'"'
IF @hr=0 EXEC @hr=sp_OAMethod @objconnection, 'Execute',
        @Bucket out , @DDL
IF @hr<>0
    BEGIN
    DECLARE
        @Source VARCHAR(255),
        @Description VARCHAR(255),
        @Helpfile VARCHAR(255),
        @HelpID INT
   
    EXECUTE sp_OAGetErrorInfo @objErrorObject, @source output,
        @Description output,@Helpfile output,@HelpID output
    SELECT @strErrorMessage='Error whilst '
        +COALESCE(@strErrorMessage,'doing something')+', '
        +COALESCE(@Description,'')
    RAISERROR (@strErrorMessage,16,1)
    END
EXEC @hr=sp_OADestroy @objconnection
GO
--------------------------------------
/* Now we have it, it is easy */
 
spExecute_ADODB_SQL @DDL='Create table CambridgePubs
(Pubname Text, Address Text, Postcode Text)',
@DataSource ='C:\CambridgePubs.xls'
--the excel file will have been created on the Database server of the
-- database you currently have a connection to
 
--We could now insert data into the spreadsheet, if we wanted
spExecute_ADODB_SQL @DDL='insert into CambridgePubs
(Pubname,Address,Postcode)
values (''The Bird in Hand'',
''23, Marshall Road, Cambridge CB4 2DQ'',
''CB4 2DQ'')',
@DataSource ='C:\CambridgePubs.xls'
 
--you could drop it again!
spExecute_ADODB_SQL @DDL='drop table CambridgePubs',
@DataSource ='c:\CambridgePubs.xls'
 
/* Manipulating Excel data via a linked server
----------------------------------------------
 
We can now link to the created excel file as follows */
 
EXEC sp_addlinkedserver 'CambridgePubDatabase',
@srvproduct = '',
@provider = 'Microsoft.Jet.OLEDB.4.0',
@datasrc = 'C:\CambridgePubs.xls',
@provstr = 'Excel 8.0;'
GO
 
EXEC sp_addlinkedsrvlogin 'CambridgePubDatabase', 'false'
GO
 
--to drop the link, we do this!
--EXEC sp_dropserver 'CambridgePubDatabase', 'droplogins'
 
-- Get the spreadsheet data via OpenQuery
SELECT * FROM OPENQUERY
    (CambridgePubDatabase, 'select * from [CambridgePubs]')
GO
--or more simply, do this
SELECT * FROM CambridgePubDatabase...CambridgePubs
 
--so now we can insert our data into the Excel Spreadsheet
INSERT INTO CambridgePubDatabase...CambridgePubs
    (Pubname, Address, postcode)
    SELECT Pubname, Address, postcode FROM ##CambridgePubs
 
/*Synchronizing the Spreadsheet with SQL Server tables
------------------------------------------------------
 
As we are directly manipulating the Excel data in the worksheet as if it was a table we can do joins.
 
What about synchronising the table after editing the excel spreadsheet?
 
To try this out, you'll need to delete, alter and insert a few rows from the excel spreadsheet, remembering to close it after you've done it
*/
 
 
--Firstly, we'll delete any rows from ##CambridgePubs
-- that do not exist in the Excel spreadsheet
 
DELETE FROM ##CambridgePubs
FROM ##CambridgePubs c
LEFT OUTER JOIN CambridgePubDatabase...CambridgePubs ex
ON c.address LIKE ex.address
    AND c.pubname LIKE ex.pubname
    AND c.postcode LIKE ex.postcode
WHERE ex.pubname IS NULL
 
-- then we insert into #CambridgePubs any rows in the spreadsheet
-- that don't exist in #CambridgePubs
 
INSERT INTO ##CambridgePubs (Pubname,Address,Postcode)
SELECT ex.Pubname,ex.Address,ex.Postcode
FROM CambridgePubDatabase...CambridgePubs ex
LEFT OUTER JOIN ##CambridgePubs c
ON c.address LIKE ex.address
    AND c.pubname LIKE ex.pubname
    AND c.postcode LIKE ex.postcode
WHERE c.pubname IS NULL
 
--all done (reverse syncronisation would be similar)
 
/*Manipulating Excel data using OPENDATASOURCE and OPENROWSET
-------------------------------------------------------------
 
If you don't want to do the linking, you can also read the data like
this*/
 
SELECT *
FROM OPENDATASOURCE( 'Microsoft.Jet.OLEDB.4.0',
 'Data Source="C:\CambridgePubs.xls";
  Extended properties=Excel 8.0')...CambridgePubs
--and write to it
 
UPDATE OPENDATASOURCE ('Microsoft.Jet.OleDB.4.0',
'Data Source="C:\CambridgePubs.xls";
extended Properties=Excel 8.0')...CambridgePubs
SET Address='St. Kilda Road, Cambridge'
WHERE Pubname = 'Jenny Wren'
 
INSERT INTO OPENDATASOURCE ('Microsoft.Jet.OleDB.4.0',
'Data Source="C:\CambridgePubs.xls";
extended Properties=Excel 8.0')...CambridgePubs
(Pubname,Address,Postcode )
SELECT 'The St George','65 Cavendish Road','CB2 4RT'
 
--You can read and write toExcel Sheet using OpenRowSet,
--if the mood takes you
 
SELECT * FROM OPENROWSET('Microsoft.Jet.OLEDB.4.0',
'Excel 8.0;DATABASE=C:\CambridgePubs.xls', 'Select * from CambridgePubs')
 
UPDATE OPENROWSET('Microsoft.Jet.OLEDB.4.0',
'Excel 8.0;DATABASE=c:\CambridgePubs.xls',
'Select * from CambridgePubs')
    SET Address='34 Glemsford Road' WHERE Address = '65 Cavendish Road'
 
INSERT INTO OPENROWSET ('Microsoft.Jet.OLEDB.4.0',
'Excel 8.0;DATABASE=c:\CambridgePubs.xls',
'Select * from CambridgePubs')
(Pubname, Address, Postcode)
SELECT 'The Bull', 'Antioch Road','CB2 5TY'
 
/*Creating Excel Spreadsheets using sp_makewebtask
--------------------------------------------------
 
Instead of creating the Excel spreadsheet with OLEDB One can use the
sp_makewebtask
 
Users must have SELECT permissions to run a specified query and CREATE PROCEDURE permissions in the database in which the query will run. The SQL Server account must have permissions to write the generated HTML document to the specified location. Only members of the sysadmin server role can impersonate other users.
*/
 
sp_makewebtask @outputfile = 'c:\CambridgePubsHTML2.xls',
  @query = 'Select * from ##CambridgePubs',
  @colheaders =1,
    @FixedFont=0,@lastupdated=0,@resultstitle='Cambridge Pubs',
  @dbname ='MyDatabaseName'
 
/* This is fine for distributing information from databases but no good
if you subsequently want to open it via ODBC.*/
 
/*OLE Automation
----------------
 
So far, so good. However, we really want rather more than this. When we create an excel file for a business report, we want the data and we also want nice formatting, defined ranges, sums, calculated fields and pretty graphs. If we do financial reporting, we want a pivot table and so on in order to allow a degree of data mining by the recipient. A different approach is required.
 
We can, of course, use Excel to extract the data from the database. However, in this example, we'll create a spreadsheet, write the data into it, fit the columns nicely and define a range around the data
 
*/ 

ALTER PROCEDURE [dbo].[spDMOExportToExcel] (
@SourceServer VARCHAR(30),
@SourceUID VARCHAR(30)=NULL,
@SourcePWD VARCHAR(30)=NULL,
@QueryText VARCHAR(200),
@filename VARCHAR(100),
@WorksheetName VARCHAR(100)='Worksheet',
@RangeName VARCHAR(80)='MyRangeName'
)
AS
DECLARE @objServer INT,
@objQueryResults INT,
@objCurrentResultSet INT,
@objExcel INT,
@objWorkBooks INT,
@objWorkBook INT,
@objWorkSheet INT,
@objRange INT,
@hr INT,
@Columns INT,
@Rows INT,
@Output INT,
@currentColumn INT,
@currentRow INT,
@ResultSetRow INT,
@off_Column INT,
@off_Row INT,
@command VARCHAR(255),
@ColumnName VARCHAR(255),
@value VARCHAR(255),
@strErrorMessage VARCHAR(255),
@objErrorObject INT,
@Alphabet VARCHAR(27)
 
SELECT @Alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
 
IF @QueryText IS NULL
    BEGIN
    RAISERROR ('A query string is required for spDMOExportToExcel',16,1)
    RETURN 1
    END
 
-- Sets the server to the local server
IF @SourceServer IS NULL SELECT @SourceServer = @@servername
 
SET NOCOUNT ON
 
SELECT @strErrorMessage = 'instantiating the DMO',
    @objErrorObject=@objServer
EXEC @hr= sp_OACreate 'SQLDMO.SQLServer', @objServer OUT
 
IF @SourcePWD IS NULL OR @SourceUID IS NULL
    BEGIN
    --use a trusted connection
    IF @hr=0 SELECT @strErrorMessage=
    'Setting login to windows authentication on '
    +@SourceServer, @objErrorObject=@objServer
    IF @hr=0 EXEC @hr=sp_OASetProperty @objServer, 'LoginSecure', 1
    IF @hr=0 SELECT @strErrorMessage=
    'logging in to the requested server using windows authentication on '
        +@SourceServer
    IF @SourceUID IS NULL AND @hr=0 EXEC @hr=sp_OAMethod @objServer,
        'Connect', NULL, @SourceServer
    IF @SourceUID IS NOT NULL AND @hr=0
        EXEC @hr=sp_OAMethod
            @objServer, 'Connect', NULL, @SourceServer ,@SourceUID
    END
ELSE
    BEGIN
    IF @hr=0
       SELECT @strErrorMessage = 'Connecting to '''+@SourceServer+
                              ''' with user ID '''+@SourceUID+'''',
              @objErrorObject=@objServer
    IF @hr=0
        EXEC @hr=sp_OAMethod @objServer, 'Connect', NULL,
            @SourceServer, @SourceUID, @SourcePWD
    END
 
--now we execute the query
IF @hr=0 SELECT @strErrorMessage='executing the query "'
        +@querytext+'", on '+@SourceServer,
        @objErrorObject=@objServer,
        @command = 'ExecuteWithResults("' + @QueryText + '")'
IF @hr=0
    EXEC @hr=sp_OAMethod @objServer, @command, @objQueryResults OUT
 
IF @hr=0 
     SELECT @strErrorMessage='getting the first result set for "'
        +@querytext+'", on '+@SourceServer,
        @objErrorObject=@objQueryResults
IF @hr=0 EXEC @hr=sp_OAMethod
    @objQueryResults, 'CurrentResultSet', @objCurrentResultSet OUT
IF @hr=0
    SELECT @strErrorMessage='getting the rows and columns "'
        +@querytext+'", on '+@SourceServer
IF @hr=0
    EXEC @hr=sp_OAMethod @objQueryResults, 'Columns', @Columns OUT
IF @hr=0
    EXEC @hr=sp_OAMethod @objQueryResults, 'Rows', @Rows OUT
 
--so now we have the queryresults. We start up Excel
IF @hr=0
    SELECT @strErrorMessage='Creating the Excel Application, on '
        +@SourceServer, @objErrorObject=@objExcel
IF @hr=0
    EXEC @hr=sp_OACreate 'Excel.Application', @objExcel OUT
IF @hr=0 SELECT @strErrorMessage='Getting the WorkBooks object '
IF @hr=0
    EXEC @hr=sp_OAGetProperty @objExcel, 'WorkBooks',
        @objWorkBooks OUT
--create a workbook
IF @hr=0
    SELECT @strErrorMessage='Adding a workbook ',
        @objErrorObject=@objWorkBooks
IF @hr=0
    EXEC @hr=sp_OAGetProperty @objWorkBooks, 'Add', @objWorkBook OUT
 
--and a worksheet
IF @hr=0
    SELECT @strErrorMessage='Adding a worksheet ',
        @objErrorObject=@objWorkBook
IF @hr=0
    EXEC @hr=sp_OAGetProperty @objWorkBook, 'worksheets.Add',
        @objWorkSheet OUT
 
IF @hr=0
    SELECT @strErrorMessage='Naming a worksheet as "'
        +@WorksheetName+'"', @objErrorObject=@objWorkBook
IF @hr=0 
    EXEC @hr=sp_OASetProperty @objWorkSheet, 'name', @WorksheetName
 
SELECT @currentRow = 1
 
--so let's write out the column headings
SELECT @currentColumn = 1
WHILE (@currentColumn <= @Columns AND @hr=0)
        BEGIN
        IF @hr=0
            SELECT @strErrorMessage='getting column heading '
                                    +LTRIM(STR(@currentcolumn)) ,
                @objErrorObject=@objQueryResults,
                @Command='ColumnName('
                            +CONVERT(VARCHAR(3),@currentColumn)+')'
        IF @hr=0 EXEC @hr=sp_OAGetProperty @objQueryResults,
                                            @command, @ColumnName OUT
        IF @hr=0 
            SELECT @strErrorMessage='assigning the column heading '+
              + LTRIM(STR(@currentColumn))
              + ' from the query string',
            @objErrorObject=@objExcel,
            @command='Cells('+LTRIM(STR(@currentRow)) +', '
                                + LTRIM(STR(@CurrentColumn))+').value'
        IF @hr=0
            EXEC @hr=sp_OASetProperty @objExcel, @command, @ColumnName
        SELECT @currentColumn = @currentColumn + 1
        END
 
--format the headings in Bold nicely
IF @hr=0
    SELECT @strErrorMessage='formatting the column headings in bold ',
        @objErrorObject=@objWorkSheet,
        @command='Range("A1:'
            +SUBSTRING(@alphabet,@currentColumn/26,1) 
            +SUBSTRING(@alphabet,@currentColumn % 26,1)
            +'1'+'").font.bold'
IF @hr=0 EXEC @hr=sp_OASetProperty @objWorkSheet, @command, 1
--now we write out the data
 
SELECT @currentRow = 2
WHILE (@currentRow <= @Rows+1 AND @hr=0)
    BEGIN
    SELECT @currentColumn = 1
    WHILE (@currentColumn <= @Columns AND @hr=0)
        BEGIN
        IF @hr=0
            SELECT
            @strErrorMessage=
                'getting the value from the query string'
                + LTRIM(STR(@currentRow)) +','
                + LTRIM(STR(@currentRow))+')',
            @objErrorObject=@objQueryResults,
            @ResultSetRow=@CurrentRow-1
        IF @hr=0
            EXEC @hr=sp_OAMethod @objQueryResults, 'GetColumnString',
                @value OUT, @ResultSetRow, @currentColumn
        IF @hr=0
            SELECT @strErrorMessage=
                    'assigning the value from the query string'
                + LTRIM(STR(@CurrentRow-1)) +', '
                + LTRIM(STR(@currentcolumn))+')' ,
                @objErrorObject=@objExcel,
                @command='Cells('+STR(@currentRow) +', ' 
                                    + STR(@CurrentColumn)+').value'
        IF @hr=0
            EXEC @hr=sp_OASetProperty @objExcel, @command, @value
        SELECT @currentColumn = @currentColumn + 1
        END
    SELECT @currentRow = @currentRow + 1
    END
--define the name range
--Cells(1, 1).Resize(10, 5).Name = "TheData"
IF @hr=0 SELECT @strErrorMessage='assigning a name to a range '
        + LTRIM(STR(@CurrentRow-1)) +', '
        + LTRIM(STR(@currentcolumn-1))+')' ,
    @objErrorObject=@objExcel,
    @command='Cells(1, 1).Resize('+STR(@currentRow-1) +', '
                                    + STR(@CurrentColumn-1)+').Name'
IF @hr=0 EXEC @hr=sp_OASetProperty @objExcel, @command, @RangeName
 
--Now autofilt the columns we've written to
IF @hr=0 SELECT @strErrorMessage='Auto-fit the columns ',
            @objErrorObject=@objWorkSheet,
            @command='Columns("A:'
                +SUBSTRING(@alphabet,(@Columns / 26),1) 
                +SUBSTRING(@alphabet,(@Columns % 26),1)+
                '").autofit'
 
IF @hr=0 --insert into @bucket(bucket)
        EXEC @hr=sp_OAMethod @objWorkSheet, @command, @output out
 
 
IF @hr=0 SELECT @command ='del "' + @filename + '"'
IF @hr=0 EXECUTE master..xp_cmdshell @Command, no_output
IF @hr=0
    SELECT @strErrorMessage='Saving the workbook as "'+@filename+'"',
        @objErrorObject=@objRange,
        @command = 'SaveAs("' + @filename + '")'
IF @hr=0 EXEC @hr=sp_OAMethod @objWorkBook, @command
IF @hr=0 SELECT @strErrorMessage='closing Excel ',
        @objErrorObject=@objExcel
EXEC @hr=sp_OAMethod @objWorkBook, 'Close'
EXEC sp_OAMethod @objExcel, 'Close'
 
IF @hr<>0
    BEGIN
    DECLARE
        @Source VARCHAR(255),
        @Description VARCHAR(255),
        @Helpfile VARCHAR(255),
        @HelpID INT
   
    EXECUTE sp_OAGetErrorInfo @objErrorObject,
        @source output,@Description output,
        @Helpfile output,@HelpID output
    SELECT @hr, @source, @Description,@Helpfile,@HelpID output
    SELECT @strErrorMessage='Error whilst '
            +COALESCE(@strErrorMessage,'doing something')
            +', '+COALESCE(@Description,'')
    RAISERROR (@strErrorMessage,16,1)
    END
EXEC sp_OADestroy @objServer
EXEC sp_OADestroy @objQueryResults
EXEC sp_OADestroy @objCurrentResultSet
EXEC sp_OADestroy @objExcel
EXEC sp_OADestroy @objWorkBooks
EXEC sp_OADestroy @objWorkBook
EXEC sp_OADestroy @objRange
RETURN @hr
GO
 
--Now we can create our pubs spreadsheet, and can do it from any of
--our servers
--
spDMOExportToExcel @SourceServer='MyServer',
@SourceUID= 'MyUserID',
@SourcePWD = 'MyPassword',
@QueryText = 'use MyDatabase
select Pubname, Address, Postcode from ##CambridgePubs',
@filename = 'C:\MyPubDatabase.xls',
@WorksheetName='MyFavouritePubs',
@RangeName ='MyRangeName'
 
--or if you are using integrated security!
spDMOExportToExcel @SourceServer='MyServer',
@QueryText = 'use MyDatabase
select Pubname, Address, Postcode from ##CambridgePubs',
@filename = 'C:\MyPubDatabase.xls',
@WorksheetName='MyFavouritePubs',
@RangeName ='MyRangeName'
 
 
/* Although this is a very handy stored procedure, you'll probably need to modify and add to it for particular purposes.
 
We use the DMO method because we like to dump build data into Excel spreadsheets e.g. users, logins, Job Histories. However, an ADODB version is very simple to do and can be made much faster for reads and writes.
 
We have just inserted values, but you can insert formulae and formatting numberformat) and create or change borders. You can, in fact, manipulate the spreadsheet in any way you like. When we do this, we record macros in Excel and then convert these macros to TSQL! Using the above example, it should be simple */