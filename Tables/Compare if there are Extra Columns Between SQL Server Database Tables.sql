SELECT
  c2.table_name,
  c2.COLUMN_NAME
FROM [INFORMATION_SCHEMA].[COLUMNS] c2
WHERE table_name = 'article3'
  AND c2.COLUMN_NAME NOT IN 
     ( SELECT column_name
       FROM [INFORMATION_SCHEMA].[COLUMNS]
       WHERE table_name = 'article'
     )