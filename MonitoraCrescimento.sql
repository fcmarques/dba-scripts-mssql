USE [dbalog]
GO
/****** Object:  StoredProcedure [dbo].[monitora_sizedb]    Script Date: 05/01/2015 10:09:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[monitora_sizedb]                

as begin                

DECLARE @SERVIDOR NVARCHAR(100)                
  ,@cmd nvarchar (max)                
  ,@script nvarchar (max)                
  ,@erro nvarchar(max)                
  ,@data date = convert(date,getdate())                
   

set @cmd='set fmtonly off
		set nocount on
		declare @base nvarchar(max),
		@cmd nvarchar(max),
		@script nvarchar(max)

		create table ##dbsize (banco nvarchar(300),dbsize bigint, dbspacefree bigint, servidor nvarchar(300))

set @script =''''insert into ##dbsize (banco,dbsize,dbspacefree,servidor) SELECT db_name(),sum(size/128), sum(size/128-((CAST(FILEPROPERTY(name,''''''''SpaceUsed'''''''')as int)/128))),@@servername	FROM sys.database_files	where type = 0''''  


DECLARE cursor_n1 CURSOR FOR                
select name from sys.databases where database_id > 4 and state =0

OPEN cursor_n1                
	 FETCH NEXT FROM cursor_n1 INTO @base                
     WHILE @@FETCH_STATUS = 0                

	 begin
		set @cmd = ''''use ''''+@base +'''' ''''+ @script
	
		 exec sp_executesql   @cmd 
	
	 FETCH NEXT FROM cursor_n1 INTO @base
end
select banco,dbsize,dbspacefree,servidor from ##dbsize
CLOSE cursor_n1                
DEALLOCATE cursor_n1
drop table ##dbsize
'''  

DECLARE cursor_n1 CURSOR FOR                

select ltrim(srvname) from sysservers where providername  = 'SQLOLEDB'

OPEN cursor_n1                

 FETCH NEXT FROM cursor_n1 INTO @SERVIDOR                

   WHILE @@FETCH_STATUS = 0                

   BEGIN                

    BEGIN TRY                

     SET @script = 'insert into TARD_MNRR_CSMO (DS_NOME_BASE,DS_TMHO_OCDO,DS_TMHO_LVRE,DS_SRDR_ANSE) (select * from openquery (['+@servidor+'],'''+@cmd+'))'                

    -- EXEC SP_EXECUTESQL @script                
	 print @script
	 
    END TRY                

    BEGIN CATCH                

     --SET @erro ='INSERT INTO BACKUPS ([DATABASE],[TYPE],DATA) VALUES ('''+@SERVIDOR+''',''E'','''+CONVERT(VARCHAR(10),GETDATE(),20)+''')'                

     --EXEC SP_EXECUTESQL @erro                

     --PRINT @SERVIDOR    

    END CATCH                

    FETCH NEXT FROM cursor_n1 INTO @SERVIDOR                

END                

CLOSE cursor_n1                

DEALLOCATE cursor_n1                
end       
