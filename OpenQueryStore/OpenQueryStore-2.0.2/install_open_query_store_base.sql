/*********************************************************************************************
Open Query Store
Install table and view infrastructure for Open Query Store
v0.4 - August 2017

Copyright:
William Durkin (@sql_williamd) / Enrico van de Laar (@evdlaar)

https://github.com/OpenQueryStore/OpenQueryStore

License:
	This script is free to download and use for personal, educational, and internal
	corporate purposes, provided that this header is preserved. Redistribution or sale
	of this script, in whole or in part, is prohibited without the author's express
	written consent.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
	OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**********************************************************************************************/

USE [{DatabaseWhereOQSIsRunning}]
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;
GO

-- Create the OQS Schema
IF NOT EXISTS ( SELECT * FROM [sys].[schemas] AS [S] WHERE [S].[name] = 'oqs' )
    BEGIN
        EXEC ( 'CREATE SCHEMA oqs' );
    END;
GO

-- Metadata to control OQS
CREATE TABLE [oqs].[collection_metadata]
    (
        [command]             nvarchar (2000),         -- The command that should be executed by Service Broker
        [collection_interval] bigint         NOT NULL, -- The interval for looped processing (in seconds)
        [oqs_mode]            nvarchar (20)  NOT NULL, -- The mode that OQS should run in. May only be "classic" or "centralized" 
        [oqs_classic_db]      nvarchar (128) NOT NULL, -- The database where OQS resides in classic mode (must be filled when classic mode is chosen, ignored by centralized mode)
        CONSTRAINT [chk_oqs_mode] CHECK ( [oqs_mode] IN ( N'classic', N'centralized' )),
        [collection_active]   bit            NOT NULL  -- Should OQS be collecting data or not
    );
GO

INSERT INTO [oqs].[collection_metadata] (   [command],
                                            [collection_interval],
                                            [oqs_mode],
                                            [oqs_classic_db],
                                            [collection_active]
                                        )
VALUES ( N'EXEC [oqs].[gather_statistics] @logmode=1', 60 , '{OQSMode}','{DatabaseWhereOQSIsRunning}',0);
GO

CREATE TABLE [oqs].[activity_log]
    (
        [log_id]        [int]           IDENTITY (1, 1) NOT NULL,
        [log_run_id]    [int]           NULL,
        [log_timestamp] [datetime]      NULL,
        [log_message]   [varchar] (250) NULL,
        CONSTRAINT [pk_log_id]
            PRIMARY KEY CLUSTERED ( [log_id] ASC )
    ) ON [PRIMARY];
GO

CREATE TABLE [oqs].[monitored_databases]
    (
        [database_name] [nvarchar] (128) NOT NULL,
        CONSTRAINT [pk_monitored_databases]
            PRIMARY KEY CLUSTERED ( [database_name] ASC )
    ) ON [PRIMARY];
GO

CREATE TABLE [oqs].[intervals]
    (
        [interval_id]    [int]      IDENTITY (1, 1) NOT NULL,
        [interval_start] [datetime] NULL,
        [interval_end]   [datetime] NULL,
        CONSTRAINT [pk_intervals]
            PRIMARY KEY CLUSTERED ( [interval_id] ASC )
    ) ON [PRIMARY];
GO

CREATE TABLE [oqs].[plan_dbid]
    (
        [plan_handle] [varbinary] (64) NOT NULL,
        [dbid]        [int]            NOT NULL,
        CONSTRAINT [pk_plan_dbid]
            PRIMARY KEY CLUSTERED ( [plan_handle] ASC, [dbid] ASC )
    ) ON [PRIMARY];
GO

CREATE TABLE [oqs].[plans]
    (
        [plan_id]            [int]            IDENTITY (1, 1) NOT NULL,
        [plan_MD5]           [varbinary] (32) NOT NULL,
        [plan_handle]        [varbinary] (64) NULL,
        [plan_firstfound]    [datetime]       NULL,
        [plan_database]      [nvarchar] (150) NULL,
        [plan_refcounts]     [int]            NULL,
        [plan_usecounts]     [int]            NULL,
        [plan_sizeinbytes]   [int]            NULL,
        [plan_type]          [nvarchar] (50)  NULL,
        [plan_objecttype]    [nvarchar] (20)  NULL,
        [plan_executionplan] [xml]            NULL,
        CONSTRAINT [pk_plans]
            PRIMARY KEY CLUSTERED ( [plan_id] ASC )
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

CREATE TABLE [oqs].[queries]
    (
        [query_id]                     [int]            IDENTITY (1, 1) NOT NULL,
        [plan_id]                      [int]            NOT NULL,
        [query_hash]                   [binary] (8)     NULL,
        [query_plan_MD5]               [varbinary] (72) NULL,
        [query_statement_text]         [nvarchar] (MAX) NULL,
        [query_statement_start_offset] [int]            NULL,
        [query_statement_end_offset]   [int]            NULL,
        [query_creation_time]          [datetime]       NULL,
        CONSTRAINT [pk_queries]
            PRIMARY KEY CLUSTERED ( [query_id] ASC )
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

CREATE TABLE [oqs].[query_runtime_stats]
    (
        [query_id]             [int]      NOT NULL,
        [interval_id]          [int]      NOT NULL,
        [creation_time]        [datetime] NOT NULL,
        [last_execution_time]  [datetime] NOT NULL,
        [execution_count]      [bigint]   NOT NULL,
        [total_elapsed_time]   [bigint]   NOT NULL,
        [last_elapsed_time]    [bigint]   NOT NULL,
        [min_elapsed_time]     [bigint]   NOT NULL,
        [max_elapsed_time]     [bigint]   NOT NULL,
        [avg_elapsed_time]     [bigint]   NOT NULL,
        [total_rows]           [bigint]   NOT NULL,
        [last_rows]            [bigint]   NOT NULL,
        [min_rows]             [bigint]   NOT NULL,
        [max_rows]             [bigint]   NOT NULL,
        [avg_rows]             [bigint]   NOT NULL,
        [total_worker_time]    [bigint]   NOT NULL,
        [last_worker_time]     [bigint]   NOT NULL,
        [min_worker_time]      [bigint]   NOT NULL,
        [max_worker_time]      [bigint]   NOT NULL,
        [avg_worker_time]      [bigint]   NOT NULL,
        [total_physical_reads] [bigint]   NOT NULL,
        [last_physical_reads]  [bigint]   NOT NULL,
        [min_physical_reads]   [bigint]   NOT NULL,
        [max_physical_reads]   [bigint]   NOT NULL,
        [avg_physical_reads]   [bigint]   NOT NULL,
        [total_logical_reads]  [bigint]   NOT NULL,
        [last_logical_reads]   [bigint]   NOT NULL,
        [min_logical_reads]    [bigint]   NOT NULL,
        [max_logical_reads]    [bigint]   NOT NULL,
        [avg_logical_reads]    [bigint]   NOT NULL,
        [total_logical_writes] [bigint]   NOT NULL,
        [last_logical_writes]  [bigint]   NOT NULL,
        [min_logical_writes]   [bigint]   NOT NULL,
        [max_logical_writes]   [bigint]   NOT NULL,
        [avg_logical_writes]   [bigint]   NOT NULL,
        CONSTRAINT [pk_query_runtime_stats]
            PRIMARY KEY CLUSTERED ( [query_id] ASC, [interval_id] ASC )
    ) ON [PRIMARY];
GO

CREATE TABLE [oqs].[wait_stats]
    (
        [interval_id]         [int]           NOT NULL,
        [wait_type]           [nvarchar] (60) NOT NULL,
        [waiting_tasks_count] [bigint]        NOT NULL,
        [wait_time_ms]        [bigint]        NOT NULL,
        [max_wait_time_ms]    [bigint]        NOT NULL,
        [signal_wait_time_ms] [bigint]        NOT NULL,
        CONSTRAINT [pk_wait_stats]
            PRIMARY KEY CLUSTERED ( [interval_id] ASC, [wait_type] ASC )
    ) ON [PRIMARY];
GO

-- Create the OQS query_stats view as a version specific abstraction of sys.dm_exec_query_stats
DECLARE @MajorVersion   tinyint,
        @MinorVersion   tinyint,
        @Version        nvarchar (128),
        @ViewDefinition nvarchar (MAX);

SELECT @Version = CAST(SERVERPROPERTY( 'ProductVersion' ) AS nvarchar);

SELECT @MajorVersion = PARSENAME( CONVERT( varchar (32), @Version ), 4 ),
       @MinorVersion = PARSENAME( CONVERT( varchar (32), @Version ), 3 );

SET @ViewDefinition = 'CREATE VIEW [oqs].[query_stats]
AS
SELECT [sql_handle],
       [statement_start_offset],
       [statement_end_offset],
       [plan_generation_num],
       [plan_handle],
       [creation_time],
       [last_execution_time],
       [execution_count],
       [total_worker_time],
       [last_worker_time],
       [min_worker_time],
       [max_worker_time],
       [total_physical_reads],
       [last_physical_reads],
       [min_physical_reads],
       [max_physical_reads],
       [total_logical_writes],
       [last_logical_writes],
       [min_logical_writes],
       [max_logical_writes],
       [total_logical_reads],
       [last_logical_reads],
       [min_logical_reads],
       [max_logical_reads],
       [total_clr_time],
       [last_clr_time],
       [min_clr_time],
       [max_clr_time],
       [total_elapsed_time],
       [last_elapsed_time],
       [min_elapsed_time],
       [max_elapsed_time],' + 
CASE WHEN @MajorVersion = 9 THEN 'CAST(NULL as binary (8)) ' ELSE '' END + '[query_hash],' +											-- query_hash appears in sql 2008
CASE WHEN @MajorVersion = 9 THEN 'CAST(NULL as binary (8)) ' ELSE '' END + '[query_plan_hash],' +										-- query_plan_hash appears in sql 2008
CASE WHEN @MajorVersion = 9 OR ( @MajorVersion = 10 AND @MinorVersion < 50 ) THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_rows],' +	-- total_rows appears in sql 2008r2
CASE WHEN @MajorVersion = 9 OR ( @MajorVersion = 10 AND @MinorVersion < 50 ) THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_rows],' +	-- last_rows appears in sql 2008r2
CASE WHEN @MajorVersion = 9 OR ( @MajorVersion = 10 AND @MinorVersion < 50 ) THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_rows],' +	-- min_rows appears in sql 2008r2
CASE WHEN @MajorVersion = 9 OR ( @MajorVersion = 10 AND @MinorVersion < 50 ) THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_rows],' +	-- max_rows appears in sql 2008r2
CASE WHEN @MajorVersion < 12 THEN 'CAST(NULL as varbinary (64)) ' ELSE '' END + '[statement_sql_handle],' +								-- statement_sql_handle appears in sql 2014
CASE WHEN @MajorVersion < 12 THEN 'CAST(NULL as bigint) ' ELSE '' END + '[statement_context_id],' +										-- statement_context_id appears in sql 2014
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_dop],' +													-- total_dop appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_dop],' +													-- last_dop appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_dop],' +														-- min_dop appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_dop],' +														-- max_dop appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_grant_kb],' +												-- total_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_grant_kb],' +												-- last_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_grant_kb],' +												-- min_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_grant_kb],' +												-- max_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_used_grant_kb],' +											-- total_used_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_used_grant_kb],' +											-- last_used_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_used_grant_kb],' +											-- min_rows appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_used_grant_kb],' +											-- max_used_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_ideal_grant_kb],' +										-- total_ideal_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_ideal_grant_kb],' +											-- last_ideal_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_ideal_grant_kb],' +											-- min_ideal_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_ideal_grant_kb],' +											-- max_ideal_grant_kb appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_reserved_threads],' +										-- total_reserved_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_reserved_threads],' +										-- last_reserved_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_reserved_threads],' +										-- min_reserved_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_reserved_threads],' +										-- max_reserved_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[total_used_threads],' +											-- total_used_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[last_used_threads],' +											-- last_used_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[min_used_threads],' +											-- min_used_threads appears in sql 2016
CASE WHEN @MajorVersion < 13 THEN 'CAST(0 as bigint) ' ELSE '' END + '[max_used_threads]' +												-- max_used_threads appears in sql 2016
' FROM [sys].[dm_exec_query_stats];';

EXEC ( @ViewDefinition );
GO

-- Create the OQS Purge OQS Stored Procedure
CREATE PROCEDURE [oqs].[purge_oqs]
AS
BEGIN
    
    SET NOCOUNT ON

    TRUNCATE TABLE [oqs].[activity_log];
    TRUNCATE TABLE [oqs].[intervals];
    TRUNCATE TABLE [oqs].[plan_dbid];
    TRUNCATE TABLE [oqs].[plans];
    TRUNCATE TABLE [oqs].[queries];
    TRUNCATE TABLE [oqs].[query_runtime_stats];
    TRUNCATE TABLE [oqs].[wait_stats];
END
GO

