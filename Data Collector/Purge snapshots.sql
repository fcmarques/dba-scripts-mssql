<<<<<<< HEAD
-- Purge snapshots.notable_query_plan table 
DECLARE @delete_batch_size bigint;
    DECLARE @rows_affected int;
    SET @delete_batch_size = 500;
    SET @rows_affected = @delete_batch_size;
    WHILE (@rows_affected = @delete_batch_size)
    BEGIN
        DELETE TOP (@delete_batch_size) snapshots.notable_query_plan 
        FROM snapshots.notable_query_plan AS qp 
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qp.[sql_handle] AND qs.plan_handle = qp.plan_handle 
                AND qs.plan_generation_num = qp.plan_generation_num 
                AND qs.statement_start_offset = qp.statement_start_offset 
                AND qs.statement_end_offset = qp.statement_end_offset 
                AND qs.creation_time = qp.creation_time);
        SET @rows_affected = @@ROWCOUNT;
        RAISERROR ('Deleted %d orphaned rows from snapshots.notable_query_plan', 0, 1, @rows_affected) WITH NOWAIT;
    END;

    -- Purge snapshots.notable_query_text table
    SET @rows_affected = @delete_batch_size;
    WHILE (@rows_affected = @delete_batch_size)
    BEGIN
        DELETE TOP (@delete_batch_size) snapshots.notable_query_text 
        FROM snapshots.notable_query_text AS qt
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qt.[sql_handle]);
        SET @rows_affected = @@ROWCOUNT;
        RAISERROR ('Deleted %d orphaned rows from snapshots.notable_query_text', 0, 1, @rows_affected) WITH NOWAIT;
=======
-- Purge snapshots.notable_query_plan table 
DECLARE @delete_batch_size bigint;
    DECLARE @rows_affected int;
    SET @delete_batch_size = 500;
    SET @rows_affected = @delete_batch_size;
    WHILE (@rows_affected = @delete_batch_size)
    BEGIN
        DELETE TOP (@delete_batch_size) snapshots.notable_query_plan 
        FROM snapshots.notable_query_plan AS qp 
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qp.[sql_handle] AND qs.plan_handle = qp.plan_handle 
                AND qs.plan_generation_num = qp.plan_generation_num 
                AND qs.statement_start_offset = qp.statement_start_offset 
                AND qs.statement_end_offset = qp.statement_end_offset 
                AND qs.creation_time = qp.creation_time);
        SET @rows_affected = @@ROWCOUNT;
        RAISERROR ('Deleted %d orphaned rows from snapshots.notable_query_plan', 0, 1, @rows_affected) WITH NOWAIT;
    END;

    -- Purge snapshots.notable_query_text table
    SET @rows_affected = @delete_batch_size;
    WHILE (@rows_affected = @delete_batch_size)
    BEGIN
        DELETE TOP (@delete_batch_size) snapshots.notable_query_text 
        FROM snapshots.notable_query_text AS qt
        WHERE NOT EXISTS (
            SELECT * 
            FROM snapshots.query_stats AS qs
            WHERE qs.[sql_handle] = qt.[sql_handle]);
        SET @rows_affected = @@ROWCOUNT;
        RAISERROR ('Deleted %d orphaned rows from snapshots.notable_query_text', 0, 1, @rows_affected) WITH NOWAIT;
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
    END;