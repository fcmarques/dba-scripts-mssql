<<<<<<< HEAD
SELECT q.PlanCount,
q.DistinctPlanCount,
qs.query_hash,
st.text AS QueryText,
qp.query_plan AS QueryPlan
FROM ( SELECT query_hash,
COUNT(DISTINCT(query_hash)) AS DistinctPlanCount,
COUNT(query_hash) AS PlanCount

FROM sys.dm_exec_query_stats
GROUP BY query_hash
) AS q
JOIN sys.dm_exec_query_stats qs ON q.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE PlanCount > 1
=======
SELECT q.PlanCount,
q.DistinctPlanCount,
qs.query_hash,
st.text AS QueryText,
qp.query_plan AS QueryPlan
FROM ( SELECT query_hash,
COUNT(DISTINCT(query_hash)) AS DistinctPlanCount,
COUNT(query_hash) AS PlanCount

FROM sys.dm_exec_query_stats
GROUP BY query_hash
) AS q
JOIN sys.dm_exec_query_stats qs ON q.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE PlanCount > 1
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
ORDER BY q.PlanCount DESC, q.query_hash;