create table #ErrorLog(
	LogDate datetime,
	ProcessInfo varchar(100),
	Text varchar(max)
)

insert into #ErrorLog EXEC sys.xp_readerrorlog


select * from #ErrorLog
where text not like '%Login succeeded for user %'
and text not like '%Login failed for user%'
and text not like '%Database backed up%'
and text not like '%Log was backed up. Database%'
and text not like '%Error: 18456, Severity: 14%'
and text not like '%DBCC CHECKDB %'
and text not like '%DBCC CHECKCATALOG%'
and text not like '%CHECKDB for database%'
and text not like '%Starting up database%'
and ProcessInfo <> 'Server'
order by 1 desc

drop table #ErrorLog

/*
select 
	SUBSTRING([text], CHARINDEX('[', [text]), CHARINDEX(']', [text])) as Cliente ,
	[Text], 
	count(*) as Quantidade 
from #ErrorLog
where text like '%Login failed%' --*
or text like '%Logon failed%' --*
or text like '%The account is disabled.%' --*
and ProcessInfo <> 'Server'
group by Text
order by 3 desc
*/