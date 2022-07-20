<<<<<<< HEAD
/*Create a Temp Table to hold the Compression information.*/
Create Table #TestCompression
(ObjectName varchar(200),
SchemaName varchar(200),
indexid int,
partitionNumber int,
size_with_current_compression_setting int,
size_with_requested_compression_setting int,
sample_size_with_current_compression int,
sample_size_with_requested_compression int)

/*Insert estimated data compression info into the Temp table. So, we can query for individual tables on savings. We are using Page Compression here.*/

USE [<<Database Name>>]
GO
Select 'INSERT INTO #TESTCompression
Execute sp_estimate_data_compression_savings ''' +
B.Name+''','''+A.Name+''',NULL,NULL,''PAGE'''
from sys.objects A INNER JOIN
sys.schemas B on A.Schema_id=B.Schema_id
where type = 'U' and A.name not like 'dtproperties'

/*Sum the [Current Compression Size] and [Requested Compression Size], to figure out the compression we are going to get.We can also query for individual tables,to see which one yields better compression.In this example, I am finding only total savings. */
Select
sum(size_with_current_compression_setting) as [AsofNOWSizeInKB],
sum(size_with_requested_compression_setting) as [RequestedSizeinKB]
from #TestCompression

/*Finally, apply the compression. the below script is for Page Compression.Replace page with row, for row compression.*/
USE [<<Database Name>>]
GO
Select
'ALTER TABLE ['+B.Name+'].['+ A.Name
+ '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)'
from sys.objects A INNER JOIN
sys.schemas B on A.Schema_id=B.Schema_id
=======
/*Create a Temp Table to hold the Compression information.*/
Create Table #TestCompression
(ObjectName varchar(200),
SchemaName varchar(200),
indexid int,
partitionNumber int,
size_with_current_compression_setting int,
size_with_requested_compression_setting int,
sample_size_with_current_compression int,
sample_size_with_requested_compression int)

/*Insert estimated data compression info into the Temp table. So, we can query for individual tables on savings. We are using Page Compression here.*/

USE [<<Database Name>>]
GO
Select 'INSERT INTO #TESTCompression
Execute sp_estimate_data_compression_savings ''' +
B.Name+''','''+A.Name+''',NULL,NULL,''PAGE'''
from sys.objects A INNER JOIN
sys.schemas B on A.Schema_id=B.Schema_id
where type = 'U' and A.name not like 'dtproperties'

/*Sum the [Current Compression Size] and [Requested Compression Size], to figure out the compression we are going to get.We can also query for individual tables,to see which one yields better compression.In this example, I am finding only total savings. */
Select
sum(size_with_current_compression_setting) as [AsofNOWSizeInKB],
sum(size_with_requested_compression_setting) as [RequestedSizeinKB]
from #TestCompression

/*Finally, apply the compression. the below script is for Page Compression.Replace page with row, for row compression.*/
USE [<<Database Name>>]
GO
Select
'ALTER TABLE ['+B.Name+'].['+ A.Name
+ '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)'
from sys.objects A INNER JOIN
sys.schemas B on A.Schema_id=B.Schema_id
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
where type = 'U' and A.name not like 'dtproperties'