
sp_spaceused

select * from 


sp_who

select spid , ecid, status,loginame,hostname ,blk=convert(char(5),blocked),dbname = case
when dbid = 0 then 'NA'
when dbid <> 0 then db_name(dbid)
end
,cmd
select * from master.dbo.sysprocesses

sp_helpfile db_padrao_Log

