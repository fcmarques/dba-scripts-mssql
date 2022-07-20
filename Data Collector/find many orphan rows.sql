<<<<<<< HEAD
--  find many orphan rows in the snapshots.notable_query_plan or snapshots.notable_query_text tables
SELECT COUNT(*)
FROM snapshots.notable_query_plan AS qp 
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qp.[sql_handle] AND qs.plan_handle = qp.plan_handle 
                AND qs.plan_generation_num = qp.plan_generation_num 
                AND qs.statement_start_offset = qp.statement_start_offset 
                AND qs.statement_end_offset = qp.statement_end_offset 
                AND qs.creation_time = qp.creation_time);
				

SELECT COUNT(*)
FROM snapshots.notable_query_text AS qt
WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
=======
--  find many orphan rows in the snapshots.notable_query_plan or snapshots.notable_query_text tables
SELECT COUNT(*)
FROM snapshots.notable_query_plan AS qp 
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qp.[sql_handle] AND qs.plan_handle = qp.plan_handle 
                AND qs.plan_generation_num = qp.plan_generation_num 
                AND qs.statement_start_offset = qp.statement_start_offset 
                AND qs.statement_end_offset = qp.statement_end_offset 
                AND qs.creation_time = qp.creation_time);
				

SELECT COUNT(*)
FROM snapshots.notable_query_text AS qt
WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
            WHERE qs.[sql_handle] = qt.[sql_handle]);