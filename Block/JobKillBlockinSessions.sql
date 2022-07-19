<<<<<<< HEAD
/*
    Ref: https://www.mssqltips.com/sqlservertip/3285/detect-and-automatically-kill-low-priority-blocking-sessions-in-sql-server/
    Assign a "label" to the session for identification purposes
    Have a monitoring session to monitor sessions and if blocking exists check whether the blocker has that special "label", if so, 
    we will kill the blocker session to resolve blocking.
    
    From a technical perspective, the solution has two components:

    For a session considered low priority, at the beginning of the script insert a line as follows:
    
    set context_info 0xdba911 -- arbitrary, and can be any value you like

    Create a monitoring SQL Server Agent Job that is scheduled to run every X minutes (X can be 1 or any number suitable to your requirement).  
    The job checks whether a blocking issue exists, if so, whether the blocker has the label of low priority and if it does it will kill that process. 
    The job's workload to check blocked processes is very small as it only queries two DMVs. 
*/

-- find blocking sessions with special context_info and kill the sessions
set nocount on;
set deadlock_priority low;
declare @sqlcmd varchar(max);
declare @debug bit; -- 1=print out kill command, 0=execute kill command

set @debug = 1; -- 1=print, 0=exec
set @sqlcmd='';

; with cte (Session_id, Context_info) as
(
select r1.session_id, r1.context_info from sys.dm_exec_requests r1 with (nolock)
inner join sys.dm_exec_requests r2 with (nolock)
on r1.session_id = r2.blocking_session_id 
where r1.session_id > 50
and r1.session_id <> @@spid
union 
select s.session_id, s.context_info from sys.dm_exec_sessions s with (nolock)
inner join sys.dm_exec_requests r with (nolock)
on s.session_id = r.blocking_session_id
and r.session_id <> @@spid
)
select @sqlcmd = @sqlcmd + 'kill ' + cast(session_id as varchar) +';' + char(0x0d) + char(0x0a) from cte
where context_info = 0xdba911; -- 0xdba911 for labelling low priority sessions
if @debug = 1
 print @sqlcmd;
else
=======
/*
    Ref: https://www.mssqltips.com/sqlservertip/3285/detect-and-automatically-kill-low-priority-blocking-sessions-in-sql-server/
    Assign a "label" to the session for identification purposes
    Have a monitoring session to monitor sessions and if blocking exists check whether the blocker has that special "label", if so, 
    we will kill the blocker session to resolve blocking.
    
    From a technical perspective, the solution has two components:

    For a session considered low priority, at the beginning of the script insert a line as follows:
    
    set context_info 0xdba911 -- arbitrary, and can be any value you like

    Create a monitoring SQL Server Agent Job that is scheduled to run every X minutes (X can be 1 or any number suitable to your requirement).  
    The job checks whether a blocking issue exists, if so, whether the blocker has the label of low priority and if it does it will kill that process. 
    The job's workload to check blocked processes is very small as it only queries two DMVs. 
*/

-- find blocking sessions with special context_info and kill the sessions
set nocount on;
set deadlock_priority low;
declare @sqlcmd varchar(max);
declare @debug bit; -- 1=print out kill command, 0=execute kill command

set @debug = 1; -- 1=print, 0=exec
set @sqlcmd='';

; with cte (Session_id, Context_info) as
(
select r1.session_id, r1.context_info from sys.dm_exec_requests r1 with (nolock)
inner join sys.dm_exec_requests r2 with (nolock)
on r1.session_id = r2.blocking_session_id 
where r1.session_id > 50
and r1.session_id <> @@spid
union 
select s.session_id, s.context_info from sys.dm_exec_sessions s with (nolock)
inner join sys.dm_exec_requests r with (nolock)
on s.session_id = r.blocking_session_id
and r.session_id <> @@spid
)
select @sqlcmd = @sqlcmd + 'kill ' + cast(session_id as varchar) +';' + char(0x0d) + char(0x0a) from cte
where context_info = 0xdba911; -- 0xdba911 for labelling low priority sessions
if @debug = 1
 print @sqlcmd;
else
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
 exec (@sqlcmd);