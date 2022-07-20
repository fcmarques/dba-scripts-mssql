--Simulate a blocking session first:

/* 
Open 2 session windows, either in SQL Plus or any other cilent tool
you may be using.
In session 1 create a table and insert some data
*/

create table test_lock (a varchar2(2), bb varchar2(2));
insert into test_lock values ('i','1');
insert into test_lock values ('ii', '2');
select * from test_lock;
commit;

/* Before starting the simulation, obtain the unique session ID's
for both sessions by using the following statement; */

select distinct sid from v$mystat;

--Obtain an exclusive lock in session 1 as follows;

select * from test_lock for update;



--Now, in session 2, run these queries to identify blocking sessions;

update test_lock set a='i' where bb='1';

/* This statement will simply hang, since session 1 holds an exclusive lock on all rows within the table. Do not issue a rollback or commit;

Now query V$LOCK in session 1 using the following 3 statements;
 */
 
set pagesize 3000
set linesize 1000
select * from v$lock;

select l1.sid, ' IS BLOCKING ', l2.sid, l1.lmode, l2.request
from   v$lock l1, v$lock l2
where   l1.block    = 1
and     l2.request  > 0
and     l1.id1      =l2.id1
and    l1.id2       =l2.id2;

select    s1.username
       || '@'
       || s1.machine
       || ' ( SID='
       || s1.sid
       || ' )  is blocking '
       || s2.username
       || '@'
       || s2.machine
       || ' ( SID='
       || s2.sid
       || ' ) ' AS blocking_status
from  v$lock    l1
     ,v$session s1
     ,v$lock    l2
     ,v$session s2
where s1.sid    = l1.sid
and   s2.sid    = l2.sid
and   l1.BLOCK  = 1
and   l2.request> 0
and   l1.id1    = l2.id1
and   l2.id2    = l2.id2;

/* Finally, use the next few statements to identify the object ID and
blocked row information.
Replace the session id in the where clause with the
waiting session id, session 2. */

select row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#
from v$session
where sid=&sid;


/* Replace the SID in the where clause with that of session 2
to obtain the Object name and ROWID */

select do.object_name
      ,row_wait_obj#
      ,row_wait_file#
      ,row_wait_block#
      ,row_wait_row#
      ,dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#
                                   ,ROW_WAIT_FILE#
                                   ,ROW_WAIT_BLOCK#
                                   ,ROW_WAIT_ROW# )
from   v$session       s
      ,dba_objects     do
where  sid             = &sid -- this is the SID from session2
and    s.ROW_WAIT_OBJ# = do.OBJECT_ID;



/* Replace the ROWID from the previous result set to obtain the
actual row data */

select *
from test_lock
where rowid='AAAVnHAAQAAAp0tAAA';

