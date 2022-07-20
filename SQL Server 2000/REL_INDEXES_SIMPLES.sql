SELECT name AS IndexName
FROM sysindexes
WHERE
indid BETWEEN 1 AND 254 AND
INDEXPROPERTY(id, name, 'IsStatistics') = 0 AND
INDEXPROPERTY(id, name, 'IsHypothetical') = 0
