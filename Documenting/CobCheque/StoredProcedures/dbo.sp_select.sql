SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE DBO.sp_select (    
	@table NVARCHAR(500) ,
	@num_linhas int = NULL
)    
AS    
DECLARE @SQLString NVARCHAR(500)    
    
SET @SQLString = N'SELECT '

IF @num_linhas IS NOT NULL
	SET @SQLString = @SQLString + N' TOP ' + CAST(@num_linhas AS CHAR)

SET @SQLString = @SQLString + N' * FROM ' + @table + CHAR(13)  + ' (nolock)'  
    
EXEC sp_executesql @SQLString




GO
