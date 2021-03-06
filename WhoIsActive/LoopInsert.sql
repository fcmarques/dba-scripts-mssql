DECLARE @destination_table VARCHAR(4000)
	,@msg NVARCHAR(1000);

SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112);

DECLARE @numberOfRuns INT;

SET @numberOfRuns = 10;

WHILE @numberOfRuns > 0
BEGIN
		;

	EXEC dbo.sp_WhoIsActive @get_transaction_info = 1
		,@get_plans = 1
		,@find_block_leaders = 1
		,@DESTINATION_TABLE = @destination_table;

	SET @numberOfRuns = @numberOfRuns - 1;

	IF @numberOfRuns > 0
	BEGIN
		SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Logged info. Waiting...'

		RAISERROR (
				@msg
				,0
				,0
				)
		WITH NOWAIT;

		WAITFOR DELAY '00:00:05'
	END
	ELSE
	BEGIN
		SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Done.'

		RAISERROR (
				@msg
				,0
				,0
				)
		WITH NOWAIT;
	END
END;
GO


