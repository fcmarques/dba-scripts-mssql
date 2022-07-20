/*
	https://www.simple-talk.com/sql/t-sql-programming/writing-to-word-from-sql-server/
*/

create procedure [dbo].[spExportToWord] (
@SourceServer varchar(30)=null,
@SourceUID varchar(30)=null,
@SourcePWD varchar(30)=null,
@SourceDatabase varchar(100)=null,
@QueryText varchar(200),
@ConnectionString varchar(255) =null,
@DocumentFile varchar(100),
@TableFormat varchar(100)='professional',
@tableHeading varchar(7000)=null)
/*

 create table sample(
		[ ] varchar(80),
		[Software Sales] varchar(80),
		[Hardware Sales] varchar(80),
		[Consultancy] varchar(80),
		[Total] varchar(80))
insert into sample select 'First Quarter','£1940','£567','£765','£3272'
insert into sample select 'Second Quarter','£15960','£3685','£34000','£53645'
insert into sample select 'Third Quarter','£39480','£5000','£23000','£67480'
insert into sample select 'Fourth Quarter','£23960','£3549','£3470','£30979'
insert into sample select 'Total','£81340','£12801','£61235','£155376'
spExportToword @QueryText='Select * from sample',
	@documentFile='C:\report5.doc',@Tableformat='Grid 6'
spExportToword @QueryText='Select * from sample',
	@documentFile='C:\report6.doc',@Tableformat='Grid 6',@tableHeading='This is a pretty impressive table'
	
*/
AS

Declare @hr int,
		@strErrorMessage varchar(1000),
		@objDBC int,
		@objRecordSet int,
		@objErrorObject int,
		@objWord int,
		@objDocument int,
		@ObjRange int,
		@objTable int,
		@Row int,
		@Bucket int,
		@ii int,
		@Fieldname varchar(100),
		@fields int,
		@recordCount int,
		@TableLength int,
		@Command varchar(255),
		@State int,
		@EOF int,
		@FieldValue varchar(8000),
		@wdAlertsNone int,
		@wdTableFormat int
Select @wdAlertsNone=0

Select @wdTableFormat= case replace(@TableFormat,' ','')
when '3DEffects1' then 32 
when '3DEffects2' then 33 
when '3DEffects3' then 34 
when 'Classic1' then 4 
when 'Classic2' then 5 
when 'Classic3' then 6 
when 'Classic4' then 7 
when 'Colorful1' then 8 
when 'Colorful2' then 9 
when 'Colorful3' then 10 
when 'Colourful1' then 8 
when 'Colourful2' then 9 
when 'Colourful3' then 10 
when 'Columns1' then 11 
when 'Columns2' then 12 
when 'Columns3' then 13 
when 'Columns4' then 14 
when 'Columns5' then 15 
when 'Contemporary' then 35 
when 'Elegant' then 36 
when 'Grid1' then 16 
when 'Grid2' then 17 
when 'Grid3' then 18 
when 'Grid4' then 19 
when 'Grid5' then 20 
when 'Grid6' then 21 
when 'Grid7' then 22 
when 'Grid8' then 23 
when 'List1' then 24 
when 'List2' then 25 
when 'List3' then 26 
when 'List4' then 27 
when 'List5' then 28 
when 'List6' then 29 
when 'List7' then 30 
when 'List8' then 31 
when 'None' then 0 
when 'Professional' then 37 
when 'Simple1' then 1 
when 'Simple2' then 2 
when 'Simple3' then 3 
when 'Subtle1' then 38 
when 'Subtle2' then 39 
when 'Web1' then 40 
when 'Web2' then 41 
when 'Web3' then 42 
else 0 end

set nocount on
IF @QueryText IS NULL 
	BEGIN
	raiserror ('A query string is required for spExportToWord',16,1)
	RETURN 1
	END

-- Sets the server to the local server by default
IF @SourceServer IS NULL SELECT @SourceServer = @@servername
-- Sets the database to the local one by default
IF @SourceDatabase IS NULL SELECT @SourceDatabase = DB_name()
--if he hasn't specified a connection string...
if @connectionString is null
	if @SourcePWD is null or @SourceUID is null
		begin
		select @ConnectionString='Driver={SQL Server};	
Server='+@SourceServer+';
Database='+@SourceDatabase+'; 
trusted_Connection=Yes'
		end
	else
		Begin
		select @ConnectionString='Driver={SQL Server}; 
Server='+@SourceServer+';
Database='+@SourceDatabase+';
User ID='+@SourceUID+';
Password='+@SourcePWD
		end
--now we will create the connection string
Select @strErrorMessage='Making ADODB connection ',
			@objErrorObject=null
EXEC @hr=sp_OACreate 'ADODB.Connection', @objDBC OUT
if @hr=0 Select @strErrorMessage='Assigning ConnectionString property "' 
			+ @ConnectionString + '"',
			@objErrorObject=@objDBC
if @hr=0 EXEC @hr=sp_OASetProperty @objDBC, 
			'ConnectionString', @ConnectionString
if @hr=0 Select @strErrorMessage
		='Opening the connection'
if @hr=0 EXEC @hr=sp_OAMethod @objDBC, 'Open'
if @hr=0 Select @strErrorMessage
		='Executing the query'

if @hr=0 EXEC @hr=sp_OAMethod @objDBC, 'Execute',
		 @objRecordSet out , @QueryText

if @hr=0 Select @strErrorMessage='Getting the RS State ',
				@objErrorObject=@objRecordSet
if @hr=0 
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'State',
		@State OUT
if @hr=0 Select @strErrorMessage='Getting whether the EOF was reached '
if @hr=0 
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'EOF',
		@eof OUT
if @hr=0 Select @strErrorMessage='Getting the field count '
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'fields.count',
		@fields OUT
Select @RecordCount=0
while @hr=0 and @Eof=0 and @State=1 and @fields>0
	begin
	Select @RecordCount=@RecordCount+1
	if @hr=0 Select @strErrorMessage='moving to the next record ',
				@objErrorObject=@objRecordSet
	if @hr=0 EXEC @hr=sp_OAMethod @objRecordSet, 'MoveNext' 
	if @hr=0 Select @strErrorMessage='Getting whether the EOF was reached ',
				@objErrorObject=@objRecordSet
	if @hr=0 
		EXEC @hr=sp_OAGetProperty @objRecordSet, 'EOF',	@eof OUT

	select @ii=@ii+1
	end	
EXEC sp_OAMethod @objRecordSet, 'Close'

if @hr=0 Select @strErrorMessage
		='Executing the query'

if @hr=0 EXEC @hr=sp_OAMethod @objDBC, 'Execute',
		 @objRecordSet out , @QueryText

if @hr=0 Select @strErrorMessage='Getting the RS State ',
				@objErrorObject=@objRecordSet
if @hr=0 
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'State',
		@State OUT
if @hr=0 Select @strErrorMessage='Getting whether the EOF was reached '
if @hr=0 
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'EOF',
		@eof OUT
if @hr=0 Select @strErrorMessage='Getting the field count '
	EXEC @hr=sp_OAGetProperty @objRecordSet, 'fields.count',
		@fields OUT
--trap nonsense recordcount and add a header row
Select @TableLength = case when @recordCount>0 then @recordcount+1 else 20 end

if @hr=0 and @Eof=0 and @State=1
	Begin
	Select @strErrorMessage='instantiating Word application ',
			@objErrorObject=null
	EXEC @hr=sp_OACreate 'Word.Application', @objWord OUT
	if @hr=0 Select @strErrorMessage='Ensuring no alerts',
			@objErrorObject=@objWord
	if @hr=0 EXEC @hr=sp_OASetProperty @objWord, 
			'DisplayAlerts', @wdAlertsNone
	if @hr=0 Select @strErrorMessage='Ensuring Word invisible',
			@objErrorObject=@objWord
	if @hr=0 EXEC @hr=sp_OASetProperty @objWord, 
			'Visible', 0
	if @hr=0 Select @strErrorMessage ='Creating a new file',
			@objErrorObject=@objWord
	if @hr=0 EXEC sp_OAMethod @objWord, 'Documents.Add', 
			@objDocument output
	if @TableHeading is not null
		begin
		if @hr=0 Select @strErrorMessage ='Writing the heading',
				@objErrorObject=@objWord,
				@command='Selection.TypeText("'+replace(@tableHeading,'"','')+'")'
		if @hr=0 EXEC sp_OAMethod @objWord,	@command
		if @hr=0 Select @strErrorMessage ='ending the paragraph'
		if @hr=0 EXEC sp_OAMethod @objWord,'Selection.TypeParagraph()'
		end
	if @hr=0 Select @strErrorMessage ='Creating a range',
				@objErrorObject=@objdocument
	if @hr=0 EXEC @hr=sp_OAMethod @objWord, 'Selection.Range', 
			@objRange output 
	
	if @hr=0 Select @strErrorMessage ='Adding a table',
				@objErrorObject=@objdocument
	if @hr=0 EXEC @hr=sp_OAMethod @objdocument, 'Tables.Add', 
			@bucket output ,@objRange,@TableLength,@fields

	if @hr=0 Select @strErrorMessage ='getting the table object',
				@objErrorObject=@objdocument
	if @hr=0 EXEC @hr=sp_OAGetProperty @objdocument, 'Tables(1)', 
			@objTable output 
	end
else
	begin
	EXEC sp_OAMethod @objRecordSet, 'Close'
	EXEC sp_OAMethod @objDBC, 'Close'
	EXEC sp_OADestroy @objDBC
	EXEC sp_OADestroy @objRecordSet

	Raiserror ('No result set from ''%s'', using ''%s''',16,1,@connectionString, @queryText)
	return 1
	end
Select @Row=1
if @hr=0 and @Eof=0 and @State=1
	begin
	Select @ii=0
	while @ii<@fields and @hr=0
		begin
		if @hr=0 Select @strErrorMessage='Getting each field name ',
			@Command='fields('+cast(@ii as varchar(3))+').name',
				@objErrorObject=@objRecordSet
		if @hr=0 
			EXEC @hr=sp_OAGetProperty @objRecordSet, @command,
				@fieldName OUT
		--select @FieldName,@ii,@fields
		if @hr=0 Select @strErrorMessage='Setting the table heading font ',
			@Command='Cell(1,'+cast(@ii+1 as varchar(3))+').range.font.bold',
			@objErrorObject=@objTable
		if @hr=0 
			EXEC @hr=sp_OASetProperty @objTable, @command, 1

		if @hr=0 Select @strErrorMessage='Setting the table heading value ',
			@Command='Cell(1,'+cast(@ii+1 as varchar(3))+').range.Text',
			@objErrorObject=@objTable
		if @hr=0 
			EXEC @hr=sp_OASetProperty @objTable, @command, @FieldName
	 select @strErrorMessage=@strErrorMessage+ ' with '+@Command
    --   objTable.Cell(1, @ii).Range.Text = @FieldValue
		Select @ii=@ii+1			
		end	
	end


while @hr=0 and @Eof=0 and @State=1 and @fields>0
	begin
	Select @Row=@Row+1
	Select @ii=0
	while @ii<@fields and @hr=0
		begin
		if @hr=0 Select @strErrorMessage='Getting each field value ',
			@Command='fields('+cast(@ii as varchar(3))+').value',
				@objErrorObject=@objRecordSet
		if @hr=0 
			EXEC @hr=sp_OAGetProperty @objRecordSet, @command,
				@fieldvalue OUT
    --objTable.Cell(@row, @ii).Range.Text = objItem.Name
		if @hr=0 Select @strErrorMessage='Setting the data table cell ',
			@objErrorObject=@objTable,
			@Command='Cell('+cast(@row as varchar(3))+','+cast(@ii+1 as varchar(3))+').range.Text'
		if @hr=0 
			EXEC @hr=sp_OASetProperty @objTable, @command, @FieldValue
	    select @strErrorMessage=@strErrorMessage+ ' with '+@Command
		Select @ii=@ii+1			
		end	
	if @hr=0 Select @strErrorMessage='moving to the next record ',
				@objErrorObject=@objRecordSet
	if @hr=0 EXEC @hr=sp_OAMethod @objRecordSet, 'MoveNext' 
	if @hr=0 Select @strErrorMessage='Getting whether the EOF was reached ',
				@objErrorObject=@objRecordSet
	if @hr=0 
		EXEC @hr=sp_OAGetProperty @objRecordSet, 'EOF',	@eof OUT

	select @ii=@ii+1
	end	
if @hr=0 Select @strErrorMessage='Autoformatting to style '+cast(@wdTableFormat as varchar(2)),
	@objErrorObject=@objTable,
	@command='AutoFormat('+cast(@wdTableFormat as varchar(2))+')'
if @hr=0 
	EXEC @hr=sp_OAMethod @objTable, @command

if @hr=0 Select @strErrorMessage ='Saving the document as '+@Documentfile,
			@objErrorObject=@objWord
if @hr=0 EXEC @hr = sp_OAMethod @objWord,
		'ActiveDocument.SaveAs' , NULL , @DocumentFile
EXEC sp_OAMethod @objRecordSet, 'Close'
EXEC sp_OAMethod @objDBC, 'Close'
EXEC sp_OAMethod @objWord, 'Quit'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	raiserror (@strErrorMessage,16,1)
	end
EXEC sp_OADestroy @objDBC
EXEC sp_OADestroy @objRecordSet
Exec sp_oaDestroy @objDocument
EXEC sp_OADestroy @objTable
EXEC sp_OADestroy @objRange
EXEC sp_OADestroy @objWord
return @hr
GO

