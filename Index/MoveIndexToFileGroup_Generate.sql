SELECT 'EXEC MoveIndexToFileGroup '''
    +TABLE_CATALOG+''','''
    +TABLE_SCHEMA+''','''
    +TABLE_NAME+''',NULL,''the target file group'';'
    +char(13)+char(10)
    +'GO'+char(13)+char(10)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;