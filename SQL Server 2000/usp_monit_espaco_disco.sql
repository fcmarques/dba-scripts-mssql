USE Master
GO
CREATE PROCEDURE usp_monit_disco
AS
SET NOCOUNT ON

CREATE TABLE #dbspace (
name sysname,
caminho varchar(200),
tamanho varchar(10),
drive Varchar(30))

CREATE TABLE [#espacodisco] (
Drive varchar (10) ,
[Tamanho (MB)] Int,
[Usado (MB)] Int,
[Livre (MB)] Int,
[Livre (%)] Varchar(100),
[Usado (%)] Varchar(100),
[Ocupado SQL (MB)] Int,
[Data] smalldatetime)

Exec SP_MSForEachDB 'Use ? Insert into #dbspace Select Convert(Varchar(25),DB_Name())''Database'',Convert(Varchar(60),FileName),Convert(Varchar(8),Size/128)''Size in MB'',Convert(Varchar(30),Name) from SysFiles'

DECLARE @hr int,@fso int,@mbtotal int,
@TotalSpace int,@MBFree int,
@Percentage int,@SQLDriveSize int,
@size float
DECLARE @drive Varchar(1),@fso_Method varchar(255)

SET @mbTotal = 0
EXEC @hr = master.dbo.sp_OACreate 'Scripting.FilesystemObject', @fso OUTPUT

CREATE TABLE #space (drive char(1), mbfree int)
INSERT INTO #space EXEC master.dbo.xp_fixeddrives
Declare CheckDrives Cursor For Select drive,MBfree From #space
Open CheckDrives
Fetch Next from CheckDrives into @Drive,@MBFree
WHILE(@@FETCH_STATUS=0)
BEGIN
SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
SELECT @SQLDriveSize=sum(Convert(Int,tamanho)) from #dbspace where Substring(caminho,1,1)=@drive
EXEC @hr = sp_OAMethod @fso, @fso_method, @size OUTPUT
SET @mbtotal = @mbtotal + @size / (1024 * 1024)
INSERT INTO #espacodisco VALUES(@Drive+':',@MBTotal,@MBTotal-@MBFree,@MBFree,
Convert(Varchar,100 * round(@MBFree,2) / round(@MBTotal,2))+'%',
Convert(Varchar,100 - 100 * round(@MBFree,2) / round(@MBTotal,2))+'%',@SQLDriveSize, getdate())

FETCH NEXT FROM CheckDrives INTO @drive,@mbFree
END
CLOSE CheckDrives
DEALLOCATE CheckDrives

SELECT * FROM #espacodisco
DROP TABLE #dbspace
DROP TABLE #space
DROP TABLE #espacodisco
GO


-------------------------------------------

/*
sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO
sp_configure 'show advanced options', 0
RECONFIGURE
GO

exec usp_monit_disco
*/