--Use the following DMV query to determine which SQL Server components are consuming the most amount of memory, and observe how this changes over time:

SELECT TYPE, SUM(MULTI_PAGES_KB) FROM
SYS.DM_OS_MEMORY_CLERKS WHERE
MULTI_PAGES_KB != 0 GROUP BY TYPE