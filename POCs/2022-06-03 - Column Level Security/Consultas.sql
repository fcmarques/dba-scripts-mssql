/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      ,[DS]
      ,[COL_OK]
      ,[DT]
  FROM [SecurityDemo].[dbo].[TB_DENNY_COLUMN_ACCESS]
GO

SELECT *, CONVERT(varchar, DecryptByKey([COL_ENCRIPT])) 
  FROM [TB_COLUMN_LEVEL_ENCRIPTATION]

SELECT * 
  FROM TB_DYNAMIC_DATA_MASKING