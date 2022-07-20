DECLARE @destination_table NVARCHAR(2000)
	,@dSQL NVARCHAR(4000);

SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112);
SET @dSQL = N'SELECT collection_time, * FROM dbo.' + QUOTENAME(@destination_table) + N' order by 1 desc';

PRINT @dSQL

EXEC sp_executesql @dSQL
