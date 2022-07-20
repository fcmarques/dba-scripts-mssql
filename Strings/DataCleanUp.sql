IF OBJECT_ID (N'dbo.DataCleanUp', N'FN') IS NOT NULL 
    DROP FUNCTION dbo.DataCleanUp; 
GO 
CREATE FUNCTION [dbo].[DataCleanUp](@Data VARCHAR(MAX),@InValidData VARCHAR(100)) 
RETURNS VARCHAR(MAX) 
AS 
BEGIN 
 
DECLARE @CleanUpData VARCHAR(MAX) 
SET @CleanUpData = ' ' + @Data + ' ' 
 
WHILE PATINDEX(@InValidData,@CleanUpData)>0  
BEGIN 
SET @CleanUpData = STUFF(@CleanUpData,PATINDEX(@InValidData,@CleanUpData),1,'') 
END 
 
RETURN LTRIM(RTRIM(@CleanUpData)) 
 
END 