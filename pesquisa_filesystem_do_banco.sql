--PESQUISA FILESYSTEM DO BANCO(Foi usada a alternativa de criar a tabela temporária #Path para driblar um bug)

Create table #Path (Name varchar(128), Filename varchar(128))
truncate table #Path
Insert #Path Select Ltrim(Rtrim(sd.name)), Ltrim(Rtrim(sy.filename))
From sysdatabases sd, 
	sysaltfiles sy
where 	sd.dbid = sy.dbid
and	sy.groupid=1

Select 	distinct Left(Rtrim(filename), Datalength(Rtrim(filename)) - Charindex('\',reverse(Rtrim(filename)))) PathDb
From #Path

--Executar o comando abaixo para dropar a tabela #Path depois da consulta
--drop table #Path



--PESQUISA FILESYSTEM DO TRANSACTION LOG

Create table #Path (Name varchar(128), Filename varchar(128))
truncate table #Path
Insert #Path Select Ltrim(Rtrim(sd.name)), Ltrim(Rtrim(sy.filename))
From sysdatabases sd, 
	sysaltfiles sy
where 	sd.dbid = sy.dbid
and	sy.groupid=0

Select 	distinct Left(Rtrim(filename), Datalength(Rtrim(filename)) - Charindex('\',reverse(Rtrim(filename)))) PathDb
From #Path

--Executar o comando abaixo para dropar a tabela #Path depois da consulta
--drop table #Path