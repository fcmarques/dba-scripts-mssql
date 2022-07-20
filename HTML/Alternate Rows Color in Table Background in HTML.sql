DECLARE @TableRows VARCHAR(MAX)
SET @TableRows = '<table border="1" width="100%">' +
'<tr bgcolor="black" style="font-weight:bold;color:white">
<td>Title</td><td>FirstName</td><td>LastName</td>
</tr>'
SELECT
@TableRows = @TableRows+'<tr ' + 'bgcolor='
+ IIF( ROW_NUMBER() OVER (ORDER BY database_id DESC) % 2 = 0 , 'lightgrey' , 'white' ) +'>'
+'<td>' + CAST (database_id AS VARCHAR(100)) + '</td>'
+ '<td>' + CAST (name AS VARCHAR(100)) + '</td>'
+ '<td>' + CAST (create_date AS VARCHAR(100)) + '</td>'
+ '</tr>'
FROM sys.databases
WHERE database_id > 4
ORDER BY database_id
SELECT @TableRows + '</table>' AS SaveThisFileAsHTML