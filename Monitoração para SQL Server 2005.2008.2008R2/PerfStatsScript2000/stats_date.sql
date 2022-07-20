-- 7.0 and 2000 only

-- Check auto update/auto create stats settings for all db's, return date 
-- stats were last updated, % of rows in the table that have modified since 
-- the last stats update, whether the stats were manually created, auto 
-- created, or exist as part of an index, etc. 

DECLARE @dbname varchar(31)
DECLARE @cmd varchar(255)
DECLARE db_cursor CURSOR FOR
SELECT name FROM master.dbo.sysdatabases
FOR READ ONLY
IF 0 = @@ERROR
BEGIN
  OPEN db_cursor
  IF 0 = @@ERROR
  BEGIN
    FETCH db_cursor INTO @dbname
    WHILE @@FETCH_STATUS <> -1 AND 0 = @@ERROR
    BEGIN
      PRINT ''
      SELECT @cmd = '==== sp_dboption '+ @dbname 
      PRINT @cmd
      SELECT @cmd = 'exec master.dbo.sp_dboption ''' + @dbname + ''''
      EXEC(@cmd)
      FETCH db_cursor INTO @dbname
    END
    CLOSE db_cursor
  END
  DEALLOCATE db_cursor
END
GO



-- Get stats_date for all db's
EXEC master..sp_MSforeachdb @command1 = '
PRINT ''''
PRINT ''-- STATS_DATE and rowmodctr for [?].sysindexes --''', 
  @command2 = '
use [?]
select db_id() as dbid, 
  case 
    when indid IN (0, 1) then convert (char (12), rows)
    else (select rows from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1)) -- ''-''
  end as rowcnt, 
  case 
    when indid IN (0, 1) then rowmodctr
    else convert (bigint, rowmodctr) + (select rowmodctr from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))
  end as row_mods, 
  case rows when 0 then 0 else convert (bigint, 
    case 
      when indid IN (0, 1) then convert (bigint, rowmodctr)
      else rowmodctr + (select convert (bigint, rowmodctr) from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))
    end / convert (numeric (20,2), (select case convert (bigint, rows) when 0 then 0.01 else rows end from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))) * 100) 
  end as pct_mod, 
  convert (nvarchar, u.name + ''.'' + o.name) as objname, 
  case when i.status&0x800040=0x800040 then ''AUTOSTATS''
    when i.status&0x40=0x40 and i.status&0x800000=0 then ''STATS''
    else ''INDEX'' end as type, 
  convert (nvarchar, i.name) as idxname, i.indid, 
  stats_date (o.id, i.indid) as stats_updated, 
  case i.status & 0x1000000 when 0 then ''no'' else ''*YES*'' end as norecompute, 
  o.id as objid , rowcnt, i.status 
from [?].dbo.sysobjects o, [?].dbo.sysindexes i, [?].dbo.sysusers u 
where o.id = i.id and o.uid = u.uid and i.indid between 1 and 254 and o.type = ''U''
order by convert (nvarchar, u.name + ''.'' + o.name), indid, pct_mod desc
'

/*
-- BD 2003/08/18 - Prev version: didn't account for different meanings of the [rows] and [rowmodctr] 
-- for indid not in (0,1). 
EXEC master..sp_MSforeachdb @command1 = 'PRINT ''==== STATS_DATE and rowmodctr for [?].sysindexes''', 
  @command2 = '
use [?]
select 
  case 
    when indid IN (0, 1) then convert (char (12), rows)
    else ''-''
  end as rowcnt, 
  case 
    when indid IN (0, 1) then rowmodctr
    else rowmodctr + (select rowmodctr from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))
  end as row_mods, 
  case rows when 0 then 0 else convert (int, 
    case 
      when indid IN (0, 1) then rowmodctr
      else rowmodctr + (select rowmodctr from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))
    end /convert (numeric (20,2), (select rows from [?].dbo.sysindexes i2 where i2.id =  i.id and i2.indid in (0,1))) * 100) 
  end as pct_mod, 
  convert (nvarchar, u.name + ''.'' + o.name) as objname, 
  case when i.status&0x800040=0x800040 then ''AUTOSTATS''
    when i.status&0x40=0x40 and i.status&0x800000=0 then ''STATS''
    else ''INDEX'' end as type, 
  convert (nvarchar, i.name) as idxname, i.indid, 
  stats_date (o.id, i.indid) as stats_updated, 
  case i.status & 0x1000000 when 0 then ''no'' else ''*YES*'' end as norecompute, 
  o.id as objid , rowcnt, i.status 
from [?].dbo.sysobjects o, [?].dbo.sysindexes i, [?].dbo.sysusers u 
where o.id = i.id and o.uid = u.uid and i.indid between 0 and 254 and o.type = ''U''
order by convert (nvarchar, u.name + ''.'' + o.name), indid, pct_mod desc
'
*/


-- BD 2006/06/05 - Bracket db name placeholder (? --> [?]) for sp_MSforeachdb
