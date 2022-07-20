use Riachuelo
go
SELECT [device_name], [server_device_id], [product], [edition], [version_number], [user_count], [device_count] 
FROM [dbo].[GetUsageTrackerSQLServerSummary_UI]('en') 
where edition ='Standard'
ORDER BY device_name