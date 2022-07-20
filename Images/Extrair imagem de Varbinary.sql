/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 10
       [id]
      ,[stream]
      ,[thumb_stream]
      ,[file_name]
      ,[file_extension]
  FROM [PastaDigital].[dbo].[tb_pastadigital_file];
  
  
ALTER PROCEDURE dbo.uspdba_ExportImage (
    @ImageId INT
   ,@ImageFolderPath NVARCHAR(1000)
   ,@Filename NVARCHAR(1000)
   )
AS
BEGIN
   DECLARE @ImageData VARBINARY (max);
   DECLARE @Path2OutFile NVARCHAR (2000);
   DECLARE @Obj INT
 
   SET NOCOUNT ON
 
   SELECT @ImageData = (
         SELECT convert (VARBINARY (max), stream, 1)
         FROM tb_pastadigital_file
         WHERE id = @ImageId
         );
 
   SET @Path2OutFile = @ImageFolderPath + '\' + @Filename
    BEGIN TRY
     EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT;
     EXEC sp_OASetProperty @Obj ,'Type',1;
     EXEC sp_OAMethod @Obj,'Open';
     EXEC sp_OAMethod @Obj,'Write', NULL, @ImageData;
     EXEC sp_OAMethod @Obj,'SaveToFile', NULL, @Path2OutFile, 2;
     EXEC sp_OAMethod @Obj,'Close';
     EXEC sp_OADestroy @Obj;
    END TRY
    
 BEGIN CATCH
  EXEC sp_OADestroy @Obj;
 END CATCH
 
   SET NOCOUNT OFF
END
GO

exec dbo.uspdba_ExportImage 27725,'C:\temp\','33568519852$RG$4$.jpg' 