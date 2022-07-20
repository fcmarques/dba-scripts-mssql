use db_mercury_san

SELECT USER_NAME( OBJECTPROPERTY( i.id, 'OwnerID' ) )
                AS OwnerName,
       OBJECT_NAME( i.id ) AS TableName, 
       i.name AS IndexName
  FROM sysindexes AS i
WHERE OBJECTPROPERTY( i.id, 'IsMSShipped' ) = 0 
order by TableName

SELECT USER_NAME( OBJECTPROPERTY( i.id, 'OwnerID' ) )
                AS OwnerName,
       OBJECT_NAME( i.id ) AS TableName,
       i.name AS IndexName
   FROM sysindexes AS i
   WHERE OBJECTPROPERTY( i.id, 'IsMSShipped' ) = 0 And
       1 NOT IN ( INDEXPROPERTY( i.id , i.name , 'IsStatistics'     ) ,
              INDEXPROPERTY( i.id , i.name , 'IsAutoStatistics' ) ,
              INDEXPROPERTY( i.id , i.name , 'IsHypothetical'   ) ) And
         i.indid BETWEEN 1 And 250


SELECT USER_NAME( OBJECTPROPERTY( i.id, 'OwnerID' ) ) 
                AS OwnerName,
     OBJECT_NAME( i.id ) AS TableName,
	 i.name AS IndexName,
      CASE INDEXPROPERTY( i.id , i.name , 'IsClustered')
             WHEN 1 THEN 'YES'
             ELSE 'NO'
      END AS IsClustered,
      CASE INDEXPROPERTY( i.id , i.name , 'IsUnique'    )
	        WHEN 1 THEN 'YES'
            ELSE 'NO'
      END AS IsUnique,
      STATS_DATE( i.id , i.indid ) AS LastUpdatedDate
  FROM sysindexes AS i
WHERE OBJECTPROPERTY( i.id, 'IsMSShipped' ) = 0 And
      1 NOT IN ( INDEXPROPERTY( i.id , i.name , 'IsStatistics'   ) ,
          INDEXPROPERTY( i.id , i.name , 'IsAutoStatistics' ) ,
          INDEXPROPERTY( i.id , i.name , 'IsHypothetical'   ) ) And
      i.indid BETWEEN 1 And 250
ORDER BY OwnerName, TableName, IndexName
