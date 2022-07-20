use AUTCOM
go
SELECT file_id,name ,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB
FROM sys.database_files
where physical_name like '%AUTC_DATA8%'

SELECT file_id, name
FROM sys.database_files;
GO
DBCC SHRINKFILE (32, TRUNCATEONLY);

select 194560000/1024
===================================================================
use autcom
go
declare @size int
		,@ctrl int
		,@id int
set @ctrl = 1
set @id=5


while (@ctrl<=5)			
	begin
	set @size = (select ((size*8)/1024)-1024
			from sys.database_files
			where file_id = @id)
		
		DBCC SHRINKFILE (@id,@size)
		set @ctrl=@ctrl+1
		print @size
	end
	========================================================================================
	/*
listar todos os data files e calcular o espaço livre
calcular espaço utilizado + 20%
criar um loop para limpar a cada 1 gb
	o loop deve limpar 1 gb pçor vez e alternar entre os arquivo ou fazer todo o arquivo
*/	
use AUTCOM_hist
go
declare @size int
		,@ctrl int
		,@id int
		,@ax int

DECLARE cursor_n1 CURSOR FOR
	SELECT [file_id], size/128-((CAST(FILEPROPERTY(name,'SpaceUsed')as int)/128)) as freespace
	FROM sys.database_files
	where type=0
	
OPEN cursor_n1
FETCH NEXT FROM cursor_n1 INTO @id, @size
WHILE @@FETCH_STATUS = 0
	BEGIN
	set @ax=0
			while (@ax <= 5)
				begin
					if (@size >= 10240)
						begin
							set @size = (select ((size*8)/1024)-1024
							from sys.database_files
							where file_id = @id)
		
							DBCC SHRINKFILE (@id,@size)
							
						end
						else set @ax=6
					
					set @ax=@ax+1
				end			
	
	FETCH NEXT FROM cursor_n1 INTO @id, @size
	END

CLOSE cursor_n1
DEALLOCATE cursor_n1
=======================================================
/* (inserted by Ignite)
Character Range: 1281 to 1314
Waiting on statement: 

DBCC SHRINKFILE (@id,@size)

*/
declare  
@size int  
, 
@ctrl int  
, 
@id int  
, 
@ax int  
, 
@ax1 int  
, 
@ax2 int  
set @ctrl=1  
--Verificando se a tabela temporaria existe
   
if exists  
   ( 
   SELECT id  
   FROM tempdb..sysobjects  
   WHERE name = '##SrinkFiles' 
   )  
begin  
   DROP table ##SrinkFiles  
   END  
--Criando a tabela temporaria
  
--ajusta o tamanho do arquivo para ficar com 10% do tamanho atual livre
  
CREATE table ##SrinkFiles  
   ( 
      flid int, 
      name varchar(50),  
      alocado int,  
      utilizado int,  
      controle int,  
      inicio datetime,  
      fim datetime 
   )  
INSERT  
INTO ##SrinkFiles  
SELECT [file_id],  
   NAME,  
   (size*8)/1024,  
   convert(int,((FILEPROPERTY(name,'SpaceUsed')*8)/1024)*1.10),  
   0,  
   null,  
   null  
FROM sys.database_files  
WHERE type=0  
DELETE  
FROM ##SrinkFiles  
WHERE alocado-utilizado <= 4096 --ajustanto a variavel de controle para o loop
   
   SET @ax= 
   ( 
   SELECT count (controle)  
   FROM ##SrinkFiles  
   WHERE controle !=1 
   )  
   while (@ax!=0) begin --iniciando o cursor para diminuicao dos datafiles
   
   DECLARE cursor_n1 CURSOR FOR  
SELECT flid, 
   alocado  
FROM ##SrinkFiles  
WHERE CONTROLE!=1 OPEN cursor_n1  
FETCH NEXT  
FROM cursor_n1  
INTO @id,  
   @SIZE WHILE @@FETCH_STATUS = 0 BEGIN  
   SET @SIZE = @size-1024  
UPDATE ##SrinkFiles  
   SET INICIO = GETDATE(),  
   FIM = NULL  
WHERE flid=@ID 
/* BEGIN ACTIVE SECTION (inserted by Ignite) */  
   DBCC SHRINKFILE (@id,@size) 
/* END ACTIVE SECTION (inserted by Ignite) */  
UPDATE ##SrinkFiles  
   SET FIM = GETDATE()  
WHERE flid=@ID  
UPDATE ##SrinkFiles  
   SET alocado= 
   ( 
   SELECT (size*8)/1024  
   FROM SYS.database_files  
   WHERE file_id=@ID 
   )  
WHERE flid=@ID  
   SET @ax1= 
   ( 
   SELECT alocado  
   FROM ##SrinkFiles  
   WHERE flid=@id 
   )  
   SET @ax2= 
   ( 
   SELECT utilizado  
   FROM ##SrinkFiles  
   WHERE flid=@id 
   )  
   IF (@ax1<=@ax2)  
   BEGIN  
      UPDATE ##SrinkFiles  
         SET controle =1  
      WHERE flid=@id  
      END  
   FETCH NEXT FROM cursor_n1 INTO @id,  
   @SIZE  
END  
CLOSE cursor_n1  
DEALLOCATE cursor_n1  
set @ax= 
   ( 
   SELECT count (controle)  
   FROM ##SrinkFiles  
   WHERE controle !=1 
   )  
end  
if