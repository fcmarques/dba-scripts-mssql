--Changes the owner of the jobs to sa
DECLARE @name_holder VARCHAR(1000)
DECLARE My_Cursor CURSOR
FOR
SELECT [name]  FROM msdb..sysjobs 
OPEN My_Cursor
FETCH NEXT FROM My_Cursor INTO @name_holder
WHILE (@@FETCH_STATUS <> -1)
BEGIN
exec msdb..sp_update_job
        @job_name = @name_holder,
        @owner_login_name = 'sa'
FETCH NEXT FROM My_Cursor INTO @name_holder
END 
CLOSE My_Cursor
DEALLOCATE My_Cursor
