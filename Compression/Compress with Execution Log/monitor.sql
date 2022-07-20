<<<<<<< HEAD
/****** Indexes  ******/

SELECT [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_indexes]
  where --[ObjectName] = 'SE50109'
  StartTime is null
  --and StartTime > '2021-05-10 12:59:35.640'
  order by StartTime desc;

SELECT TOP 1000 *, DATEDIFF(minute,StartTime, EndTime) as Delta
  FROM [DBDBA].[dbo].[log_compress_indexes]
 WHERE DATEDIFF(minute,StartTime, EndTime) > 0
   AND TableName = 'SF2010'
ORDER BY 8 DESC;
  
/****** Tables  ******/

SELECT [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_tables]
  where 1=1
    --AND[ObjectName] = 'SF2010'
    --AND StartTime is not null
    and EndTime is null
  --and StartTime > '2021-05-10 12:59:35.640'
  order by StartTime desc;

SELECT TOP 1000 *, DATEDIFF(minute,StartTime, EndTime) as Delta
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE DATEDIFF(minute,StartTime, EndTime) > 0
   --AND TableName = 'SF2010'
ORDER BY 8 DESC;

/****** Tables  ******/

DECLARE @TotalMinutesIndexes INT
DECLARE @TotalMinutesTables INT

SELECT @TotalMinutesIndexes = SUM(DATEDIFF(MINUTE,StartTime, EndTime))
  FROM [DBDBA].[dbo].[log_compress_indexes]
 WHERE [EndTime] IS NOT NULL
   AND DATEDIFF(ss,StartTime, EndTime) > 0;

SELECT @TotalMinutesTables = SUM(DATEDIFF(MINUTE,StartTime, EndTime))
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE [EndTime] IS NOT NULL
   AND DATEDIFF(ss,StartTime, EndTime) > 0;

SELECT * 
FROM (VALUES
	   ('Indexes', CAST((@TotalMinutesIndexes - (@TotalMinutesIndexes % 60)) / 60 as varchar(5)) /* Hours */ + ':' + RIGHT('00' + CAST(@TotalMinutesIndexes % 60 as varchar(2))  /* minutes */ , 2)),
	   ('Tables', CAST((@TotalMinutesTables - (@TotalMinutesTables % 60)) / 60 as varchar(5)) /* Hours */ + ':' + RIGHT('00' + CAST(@TotalMinutesTables % 60 as varchar(2))  /* minutes */ , 2))
=======
/****** Indexes  ******/

SELECT [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_indexes]
  where --[ObjectName] = 'SE50109'
  StartTime is null
  --and StartTime > '2021-05-10 12:59:35.640'
  order by StartTime desc;

SELECT TOP 1000 *, DATEDIFF(minute,StartTime, EndTime) as Delta
  FROM [DBDBA].[dbo].[log_compress_indexes]
 WHERE DATEDIFF(minute,StartTime, EndTime) > 0
   AND TableName = 'SF2010'
ORDER BY 8 DESC;
  
/****** Tables  ******/

SELECT [ObjectName]
      ,[SchemaName]
      ,[TableName]
      ,[ObjectType]
      ,[Command]
      ,[StartTime]
      ,[EndTime]
  FROM [DBDBA].[dbo].[log_compress_tables]
  where 1=1
    --AND[ObjectName] = 'SF2010'
    --AND StartTime is not null
    and EndTime is null
  --and StartTime > '2021-05-10 12:59:35.640'
  order by StartTime desc;

SELECT TOP 1000 *, DATEDIFF(minute,StartTime, EndTime) as Delta
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE DATEDIFF(minute,StartTime, EndTime) > 0
   --AND TableName = 'SF2010'
ORDER BY 8 DESC;

/****** Tables  ******/

DECLARE @TotalMinutesIndexes INT
DECLARE @TotalMinutesTables INT

SELECT @TotalMinutesIndexes = SUM(DATEDIFF(MINUTE,StartTime, EndTime))
  FROM [DBDBA].[dbo].[log_compress_indexes]
 WHERE [EndTime] IS NOT NULL
   AND DATEDIFF(ss,StartTime, EndTime) > 0;

SELECT @TotalMinutesTables = SUM(DATEDIFF(MINUTE,StartTime, EndTime))
  FROM [DBDBA].[dbo].[log_compress_tables]
 WHERE [EndTime] IS NOT NULL
   AND DATEDIFF(ss,StartTime, EndTime) > 0;

SELECT * 
FROM (VALUES
	   ('Indexes', CAST((@TotalMinutesIndexes - (@TotalMinutesIndexes % 60)) / 60 as varchar(5)) /* Hours */ + ':' + RIGHT('00' + CAST(@TotalMinutesIndexes % 60 as varchar(2))  /* minutes */ , 2)),
	   ('Tables', CAST((@TotalMinutesTables - (@TotalMinutesTables % 60)) / 60 as varchar(5)) /* Hours */ + ':' + RIGHT('00' + CAST(@TotalMinutesTables % 60 as varchar(2))  /* minutes */ , 2))
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
     ) AS q ([ObjectType],[Total de Horas]);