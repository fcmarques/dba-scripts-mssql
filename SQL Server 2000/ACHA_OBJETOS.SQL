SELECT 
    LEFT(TAB.name, 35) tabela, LEFT(COL.name, 35) coluna, LEFT(TYP.name, 20) tipo, COL.length tamanho, COL.isnullable 'NULL'
FROM 
    sysobjects TAB, syscolumns COL, systypes TYP
WHERE 
    TAB.id = COL.id
    AND COL.xtype = TYP.xtype
--    AND TAB.name LIKE '%dii_id%'
      AND COL.name LIKE '%dce_id%'
ORDER BY 1, 2
