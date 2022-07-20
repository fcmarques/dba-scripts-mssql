/******************************************************************************************
This script returns the info on http://sqlserverbuilds.blogspot.com as a table
*******************************************************************************************
Version:	1.0
Author:		Theo Ekelmans
Email:		theo@ekelmans.com
Date:		2017-05-22
*******************************************************************************************
This script uses wget.exe from this excellent site: https://eternallybored.org/misc/wget/
Save the wget.exe file in the same folder as the ERRORLOG file (or change the path below)
******************************************************************************************/
set nocount on

-- Lots of royally sized vars :)
begin
declare @out table (
	    ID int identity(1,1) PRIMARY KEY, -- All tables need an ID, right?
	    LongSqlVersion varchar(1000), -- The header text of each SQL version
	    SqlVersion varchar(1000),	 -- 7, 2000, 2005, 2008, 2008R2, 2012, 2016, 2017 etc.
	    htmlID int, -- The order in which data is read from sqlserverbuilds.blogspot.com
	    line varchar(8000),  -- The raw data from sqlserverbuilds.blogspot.com
	    ProductVersion varchar(1000), -- This is the column to match the output of SERVERPROPERTY('ProductVersion') against, i have fixed all the exceptions i could find , thanks to MS for being so consistent .**NOT** :)
	    build varchar(1000),	  -- The build label that sqlserverbuilds.blogspot.com uses (this is not always the same as SERVERPROPERTY(ProductVersion'') reports), use this columnt together with the new columt to update your local table
	    fileversion varchar(1000), -- Don't ask, i have no idea....
	    kb varchar(1000),  -- The knowledgebase article for this patch
	    description varchar(1000),  -- The knowledgebase description for this patch
	    url varchar(1000), -- The knowledgebase download link for this patch
	    releasedate varchar(1000), -- Guess....
	    latest_sp bit, -- This bit is high for the latest SP for this SqlVersion (and the reason why i built this script)
	    latest_cu bit, -- This bit is high for the latest CU for this SqlVersion (and the reason why i built this script)
	    rtm bit, -- This bit is high is this build is the RTM (release to market) version, and most definitly not the build you want to be on!
	    new bit) -- If you know what were the latest released builds? Say hello to yopur little bitty friend :)
declare @Cmd varchar(1000) 
declare @Path varchar(1000)
declare @FileName varchar (1024)
declare @OLEResult int
declare @FS int
declare @FileID int
declare @Message varchar (8000)
declare @LongSqlVersion as varchar(250)
declare @CurrentSqlVersion as varchar(20)
declare @ID int
declare @SqlVersion varchar(20)
declare @StartLine int
declare @EndLine int
declare @htmlID int
declare @line varchar(8000)
declare @ProductVersion varchar(1000)
declare @build varchar(1000)
declare @fileversion varchar(1000)
declare @KB varchar(1000)
declare @description varchar(1000)
declare @url varchar(1250)
declare @releasedate varchar(1000)
declare @latest_sp bit
declare @latest_cu bit
declare @rtm bit
declare @new bit
declare @pos int
declare @oldpos int
declare @counter int
declare @l varchar(1000) 
declare @htmlLine table(
		[ID] [int] identity(1,1) NOT NULL, 
		line varchar(max))
declare @SqlVersionTables table(
		ID int identity(1,1) PRIMARY KEY,
		LongSqlVersion varchar(250), 
		SqlVersion varchar(20), 
		StartLine int, 
		EndLine int)
declare @html table(
		[ID] [int] identity(1,1) NOT NULL, 
		line varchar(max))
declare @htmlRows table (
		ID int PRIMARY KEY, 
		pos int, 
		epos int, 
		td varchar(8000))
end

--------------------------------------------------------------------------------
-- Phase 1 : Download the homepage and store it in @out
--------------------------------------------------------------------------------


-- Get SQL errorlog path (a convenient place to store WGET.EXE and the out.html files)
set @Path = (select substring(cast(SERVERPROPERTY('ErrorLogFileName') as varchar(256)), 1 , len(cast(SERVERPROPERTY('ErrorLogFileName') as varchar(256))) - 8))
set @FileName = @Path+'out.html'

-- Go get it (html output goes to the out.html)
set @Cmd = 'CMD /S /C " "'+@Path+'wget.exe" --quiet -O "'+@Path+'out.html" http://sqlserverbuilds.blogspot.nl " '
exec xp_cmdshell @Cmd, no_output 

-- Create an instance of the file system object
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0
	BEGIN
		PRINT 'Scripting.FileSystemObject'
		PRINT 'Error code: ' + CONVERT (varchar, @OLEResult)
	END

-- Open the out.htmlfile for reading
EXEC @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 1, 1
IF @OLEResult <> 0
	BEGIN
		PRINT 'OpenTextFile'
		PRINT 'Error code: ' + CONVERT (varchar, @OLEResult)
	END

-- Read the first line into the @Message variable
EXECUTE @OLEResult = sp_OAMethod @FileID, 'ReadLine', @Message OUT

-- Keep looping through the file until the @OLEResult variable is < 0; this indicates that the end of the file has been reached.
WHILE @OLEResult >= 0
	BEGIN
		-- Save each line into a table variable
		insert into @html(line)
		select @Message

		EXECUTE @OLEResult = sp_OAMethod @FileID, 'ReadLine', @Message OUT
	END

-- Clean up
EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

----Debug point------
--select * from @html 


---------------------------------------------------------------------
-- Check at what line each of the SQL version tables start 
---------------------------------------------------------------------
insert into @SqlVersionTables 
select	SUBSTRING(line, CHARINDEX('>', line, 8) + 1, len(line) - 6 - CHARINDEX('>', line, 8) + 1) as [LongSqlVersion],
		SUBSTRING(line, 11, CHARINDEX('>', line, 8) -11) as [SqlVersion], 
		ID, 
		0 
from	@html 
where	line like '%<h1 id=sql%'

-- And at what line they end
update @SqlVersionTables
set EndLine = ( select top 1 ID
				from @html 
				where ID > s.StartLine
				and line like '</table>%'
				order by ID) 
from @SqlVersionTables s

----Debug point------
--select * from @SqlVersionTables 
    
------------------------------------------------------------------------
-- Extract html lines for each of the sql version tables 
------------------------------------------------------------------------
declare	curSqlVer CURSOR FOR  
select	 ID
		,LongSqlVersion
		,SqlVersion
		,StartLine
		,EndLine
from	@SqlVersionTables 

OPEN curSqlVer   
FETCH NEXT FROM curSqlVer INTO @ID, @LongSqlVersion, @CurrentSqlVersion, @StartLine, @EndLine 

WHILE @@FETCH_STATUS = 0   
BEGIN   

    insert into @out 
    select  @LongSqlVersion 
			,@CurrentSqlVersion 
			,ID
			,replace(replace(line, '</tr>', ''), '<tr>', '') as line -- strip the tr tags
			,'' as ProductVersion
			,'' as build
			,'' as fv
			,'' as kb
			,'' as descr
			,'' as url 
			,getdate() as rd
			,0 as lsp 
			,0 as lcu
			,0 as rtm 
			,0 as new
    from	   @html
    where   ID between (select StartLine from @SqlVersionTables where SqlVersion = @CurrentSqlVersion ) + 1
			       and (select EndLine   from @SqlVersionTables where SqlVersion = @CurrentSqlVersion ) 
    and	   line like '<tr><td%' -- Only the rows of the tables are interesting
    and	   len(line) > 0        -- IF they are filled 
    order by ID

    FETCH NEXT FROM curSqlVer INTO @ID, @LongSqlVersion, @CurrentSqlVersion, @StartLine, @EndLine    
END   

CLOSE curSqlVer   
DEALLOCATE curSqlVer

----------------------------------------------------------
-- Loop thought the table rows, stip all html tags 
----------------------------------------------------------

declare curOut CURSOR FOR 
select  ID, 
	   LongSqlVersion, 
	   SqlVersion, 
	   htmlID, 
	   line, 
	   ProductVersion,
	   build, 
	   fileversion, 
	   kb,
	   description, 
	   url, 
	   releasedate, 
	   latest_sp, 
	   latest_cu, 
	   rtm,
	   new
FROM	   @out
ORDER BY htmlID
FOR UPDATE

OPEN curOut   
FETCH NEXT FROM curOut INTO @ID, @LongSqlVersion, @SqlVersion, @htmlID, @line, @ProductVersion, @build, @fileversion, @KB, @description, @url, @releasedate, @latest_sp, @latest_cu, @rtm, @new 

WHILE @@FETCH_STATUS = 0   
BEGIN   
    set @counter = 1 
    set @oldpos=0
    set @pos=patindex('%<td%',@line) 

	-- Loop through the chars in the html row and find the start of every td tag
	-- Insert every td into a row in @htmlrows
    while @pos > 0 and @oldpos<>@pos
    begin
	   insert into @htmlRows Values (@counter, @pos, 0, '')

	   set @oldpos=@pos
	   set @pos=patindex('%<td%',Substring(@line,@pos + 1,len(@line))) + @pos
   
	   update @htmlRows 
	   set  epos = case when @oldpos=@pos then len(@line) else @pos -1 end 
		  ,td = substring(@line, @oldpos, case when (@pos -1 - @oldpos) < 0 then len(@line) else @pos - @oldpos end) 
	   where pos = @oldpos

	   set @counter = @counter + 1
    end

	---------------------------------------------------------------------
	-- Decode and cleanup the td htmlrows 
	---------------------------------------------------------------------

    -- ID Correction for sql7, because it has no File version column, all ID's need to shift one place
    if @SqlVersion = '7' update @htmlRows set ID = ID + 1 where ID > 3

    -- Check for intersting flags (Latest SP & CU, RTM and New flags)
    if exists (select td from @htmlRows where td like '%Latest&nbsp;CU%')   insert into @htmlRows Values ((select max(ID) from @htmlRows) + 1, 10000, 0, 'Latest CU')
	if exists (select td from @htmlRows where td like '%Latest&nbsp;SP%')   insert into @htmlRows Values ((select max(ID) from @htmlRows) + 1, 20000, 0, 'Latest SP')
	if exists (select td from @htmlRows where td like '%<td class=rtm>%')   insert into @htmlRows Values ((select max(ID) from @htmlRows) + 1, 40000, 0, 'RTM')
	if exists (select td from @htmlRows where td like '%*new%')				insert into @htmlRows Values ((select max(ID) from @htmlRows) + 1, 30000, 0, '*new') 

    -- remove the unneeded html tag and class crap
    update @htmlRows set td = replace(td, '<td class=sp>', '')
    update @htmlRows set td = replace(td, '<td class=cu>', '')
    update @htmlRows set td = replace(td, '<td class=h>', '')
    update @htmlRows set td = replace(td, '<td>', '')
    update @htmlRows set td = replace(td, '</td>', '')
    update @htmlRows set td = replace(td, '<td class=rtm>', '')
    update @htmlRows set td = replace(td, '<strong>', '')
    update @htmlRows set td = replace(td, '</strong>', '')
    update @htmlRows set td = replace(td, '&nbsp; <span class=lcu>Latest&nbsp;SP</span>', '')
    update @htmlRows set td = replace(td, '&nbsp; <span class=lcu>Latest&nbsp;CU</span>', '')
    update @htmlRows set td = replace(td, '<font color="#FF0000" size="1"> *new</font>', '')
    update @htmlRows set td = replace(td, '&quot;', '"') -- JSON does *not* like &quot;
    


	----Debug point------
    --select @line
    --select * from @htmlRows

	--------------------------------------------------------------------------------
	-- Extract the build, fileversion, KB, url etc and place them in their columns 
	--------------------------------------------------------------------------------

	-- Build
    UPDATE @out SET build = (select td from @htmlRows where ID = 1) WHERE CURRENT OF curOut

    -- ProductVersion
    UPDATE @out SET ProductVersion = (select td from @htmlRows where ID = 2) WHERE CURRENT OF curOut -- I reused the hidden column on the website for ProductVersion matching (after corrections... lot's of em....)

	--Fileversion
    if @SqlVersion <> '7' 
    UPDATE @out SET fileversion = (select td from @htmlRows where ID = 3) WHERE CURRENT OF curOut  

    UPDATE @out SET kb = (select td from @htmlRows where ID = 5) WHERE CURRENT OF curOut  

    set @l = (select td from @htmlRows where ID = 6)
    
	-- Description and url (if any)
    if left(@l, 8) = '<a href='
    begin
	   UPDATE @out SET description = (select substring(@l, charindex('>', @l) +1 , charindex('<', @l, charindex('>', @l)) - charindex('>', @l) -1)) WHERE CURRENT OF curOut  
	   UPDATE @out SET url = substring(@l, charindex('"', @l) + 1, charindex('"', @l, charindex('"', @l)+1) - charindex('"', @l) - 1) WHERE CURRENT OF curOut  
    end
    else
    begin
	   UPDATE @out SET description = @l WHERE CURRENT OF curOut  
	   UPDATE @out SET url = '' WHERE CURRENT OF curOut  
    end
    
	-- And the rest....
    UPDATE @out SET releasedate = (select td from @htmlRows where ID = 7) WHERE CURRENT OF curOut 
    UPDATE @out SET latest_sp = case when exists (select td from @htmlRows where pos = 20000) then 1 else 0 end WHERE CURRENT OF curOut
    UPDATE @out SET latest_cu = case when exists (select td from @htmlRows where pos = 10000) then 1 else 0 end WHERE CURRENT OF curOut
    UPDATE @out SET rtm = case when exists (select td from @htmlRows where pos = 40000) then 1 else 0 end WHERE CURRENT OF curOut
    UPDATE @out SET new  = case when exists (select td from @htmlRows where pos = 30000) then 1 else 0 end WHERE CURRENT OF curOut
    
	-- Cleqanup for the next loop
	delete from @htmlRows 

    FETCH NEXT FROM curOut INTO @ID, @LongSqlVersion, @SqlVersion, @htmlID, @line, @ProductVersion, @build, @fileversion, @KB, @description, @url, @releasedate, @latest_sp, @latest_cu, @rtm, @new 
END   

CLOSE curOut   
DEALLOCATE curOut

---------------------------------------------------------------------------------------------------------------------------------------------------
-- ProductVersion fixes, so you can use SERVERPROPERTY('ProductVersion') to match your SQL instance build to sqlserverbuilds.blogspot.com
---------------------------------------------------------------------------------------------------------------------------------------------------
--2017--
Update @out SET ProductVersion = build where SqlVersion = '2017' -- the minor version does not report a leading 0

--2016--
Update @out SET ProductVersion = build where SqlVersion = '2016' -- the minor version does not report a leading 0

--2014--
set @ID = (select ID from @out where ProductVersion = '12.0.5537 or 12.0.5538')
insert into @out select LongSqlVersion, SqlVersion, htmlID, line, '12.00.5538' ,build, fileversion, kb,description, url, releasedate, latest_sp, latest_cu, rtm, new FROM @out where ID = @ID
Update @out SET ProductVersion = '12.00.5537' where ID = @ID
Update @out SET ProductVersion = ProductVersion + '.0' where SqlVersion = '2014' and build <> '11.00.9120' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 
set @ID = (select ID from @out where ProductVersion = '12.0.4100.0') --2014 RTM SP1 can have a release value of 1
Update @out SET ProductVersion = '12.0.4100.1' where ID = @ID

--2012--
delete from @out where fileversion = '2011.110.9000.5' -- Extremely rare version with a non-standard build the makes sorting a pain.... i vote to drop it :)
Update @out SET ProductVersion = ProductVersion + '.0' where SqlVersion = '2012' or build = '11.00.9120' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 

--2008r2--
Update @out SET ProductVersion = build + '.0' where SqlVersion = '2008r2' -- r2 was missing in the hidden column on the website, attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 
set @ID = (select ID from @out where ProductVersion = '10.50.6000.0') --r2 SP3 can have a release of 34
Update @out SET ProductVersion = '10.50.6000.34' where ID = @ID
set @ID = (select ID from @out where ProductVersion = '10.50.1600.0') --r2 RTM SP1 can have a release of 1
Update @out SET ProductVersion = '10.50.1600.1' where ID = @ID

--2008--
Update @out SET ProductVersion = ProductVersion + '.0' where SqlVersion = '2008' -- the minor version does not report a leading 0, attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 

--2005--
Update @out SET ProductVersion = build + '.00' where SqlVersion = '2005' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 
Update @out SET latest_cu = 1 where fileversion = '2005.90.5266.0' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 

--2000--
Update @out SET ProductVersion = build + '.0' where SqlVersion = '2000' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 

--7--
Update @out SET ProductVersion = build + '.0' where SqlVersion = '7' -- attached .0 for consistent matching with using SERVERPROPERTY('ProductVersion') 


--------------------------------------------------------------------------------
-- Phase 2 : save @out into SQLBuildListImport and update SQLBuildList 
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.SQLBuildListImport', 'U') IS NOT NULL DROP TABLE dbo.SQLBuildListImport; 

-- Used for the alert email
declare @mailbody varchar(1000) = 'See http://sqlbuilds.ekelmans.com/ for details' 
						    
--------------------------------------------------------------------------------
-- Extraction and corrections complete, save into the SQLBuildListImport
--------------------------------------------------------------------------------
select	*
INTO	[dbo].[SQLBuildListImport]
FROM	@out
ORDER BY htmlID

--------------------------------------------------------------------------------
-- add computed coumns for easy sorting 
--------------------------------------------------------------------------------
ALTER TABLE dbo.SQLBuildListImport ADD
	Major     AS (CONVERT([int],case when parsename([build],(4))>=(13) then parsename([build],(4)) else parsename([build],(3)) end)),
	Minor     AS (CONVERT([int],case when parsename([build],(4))>=(13) then parsename([build],(3)) else parsename([build],(2)) end)),
	BuildNr   AS (CONVERT([int],case when parsename([build],(4))>=(13) then parsename([build],(2)) else parsename([build],(1)) end)),
	Revision  AS (CONVERT([int],case when parsename([build],(4))>=(13) then parsename([build],(1))                             end))

--------------------------------------------------------------------------------
-- Save new build records in SQLBuildList
--------------------------------------------------------------------------------
INSERT INTO [dbo].[SQLBuildList]
           ([Version]
		 ,l.[ProductVersion]
           ,[Build]
           ,[FileVersion]
           ,[KBDescription]
		 ,l.[URL]
           ,[ReleaseDate]
           ,[SP]
           ,[CU]
           ,[HF]
           ,[RTM]
           ,[CTP]
		 ,[LatestSP]
		 ,[LatestCU]
		 ,[New]
           ,[Comment])
SELECT upper([SqlVersion])
	 ,i.[ProductVersion]
     ,i.[build]
     ,i.[fileversion]
     ,i.[description]
	 ,i.[url]
     ,i.[releasedate]
	 ,0 as SP
	 ,0 as CU
	 ,0 as HF
	 ,i.[rtm]
	 ,0 as CTP
	 ,latest_sp
	 ,latest_cu
	 ,i.[new]
	 ,' auto add' as Cmt
FROM	[dbo].[SQLBuildListImport] i
	left join dbo.SQLBuildList l on i.build = l.Build 
where l.ID is null
ORDER BY htmlID 


--------------------------------------------------------------------------------
-- Send email if new records are found
--------------------------------------------------------------------------------
if @@ROWCOUNT > 0
	execute msdb.dbo.sp_send_dbmail	
		 @profile_name = '<your own profile>'
		,@recipients = 'Your email'
		,@subject = 'New patches on http://sqlserverbuilds.blogspot.com detected'
		,@body = @mailbody
		,@body_format = 'HTML' -- or TEXT
		,@importance = 'Normal' --Low Normal High
		,@sensitivity = 'Normal' --Normal Personal Private Confidential


--------------------------------------------------------------------------------
-- Update info (Because it could change)
--------------------------------------------------------------------------------
update	[dbo].[SQLBuildList]
set		 [ProductVersion] = i.[ProductVersion]
		,[Version] = UPPER([Version])
		,[URL] = i.[url]
		,[LatestSP] = i.[latest_sp]
		,[LatestCU] = i.[latest_cu]
		,[New] = i.[new]
FROM	[dbo].[SQLBuildListImport] i
		left join [dbo].[SQLBuildList] l 
			on i.build = l.Build 

--------------------------------------------------------------------------------
-- Update flags SP, CU, HF and CTP flags (extra search fields)
--------------------------------------------------------------------------------
update  dbo.SQLBuildList
set	   SP = 1 
where   UPPER(KBDescription) like UPPER('%Service Pack 10 (SP10)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 9 (SP9)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 8 (SP7)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 7 (SP7)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 6 (SP6)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 5 (SP5)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 4 (SP4)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 3 (SP3)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 2 (SP2)')
or	   UPPER(KBDescription) like UPPER('%Service Pack 1 (SP1)')

update  dbo.SQLBuildList
set	   CU = 1 
where   UPPER(KBDescription) like UPPER('%Cumulative update 20 (CU20)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 19 (CU19)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 18 (CU18)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 17 (CU17)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 16 (CU16)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 15 (CU15)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 14 (CU14)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 13 (CU13)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 12 (CU12)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 11 (CU11)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 10 (CU10)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 9 (CU9)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 8 (CU8)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 7 (CU7)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 6 (CU6)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 5 (CU5)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 4 (CU4)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 3 (CU3)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 2 (CU2)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update 1 (CU1)%')

update  dbo.SQLBuildList
set	   CU = 1 
where   UPPER(KBDescription) like UPPER('%Cumulative update package 20 (CU20)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 19 (CU19)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 18 (CU18)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 17 (CU17)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 16 (CU16)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 15 (CU15)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 14 (CU14)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 13 (CU13)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 12 (CU12)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 11 (CU11)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 10 (CU10)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 9 (CU9)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 8 (CU8)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 7 (CU7)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 6 (CU6)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 5 (CU5)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 4 (CU4)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 3 (CU3)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 2 (CU2)%')
or	   UPPER(KBDescription) like UPPER('%Cumulative update package 1 (CU1)%')

update  dbo.SQLBuildList
set	   HF = 1 
where   UPPER(KBDescription) like UPPER('%Hotfix%')

update  dbo.SQLBuildList
set	   CTP = 1 
where   UPPER(KBDescription) like UPPER('%Community Technology Preview%')

update  dbo.SQLBuildList
set	   CTP = 1 
where   UPPER(KBDescription) like UPPER('%Release Candidate%')

--------------------------------------------------------------------------------
-- Done
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Time to select what you need, or use the table for automated patch checks
--------------------------------------------------------------------------------

---- i.e. the latest sp and cu per sql version
--select  *
--from	   dbo.SQLBuildList	
--where   latestsp = 1 
--or 	   latestcu = 1
--order by major desc
--	   ,minor desc
--	   ,buildnr desc
--	   ,revision desc
