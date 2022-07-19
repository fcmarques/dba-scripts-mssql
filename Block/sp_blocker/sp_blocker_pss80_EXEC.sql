<<<<<<< HEAD
WHILE 1=1
BEGIN
EXEC tempdb.dbo.sp_blocker_pss08 
-- Or for fast mode 
-- EXEC tempdb.dbo.sp_blocker_pss08 @fast=1
-- Or for latch mode 
-- EXEC tempdb.dbo.sp_blocker_pss08 @latch=1
WAITFOR DELAY '00:00:15'
END
=======
WHILE 1=1
BEGIN
EXEC tempdb.dbo.sp_blocker_pss08 
-- Or for fast mode 
-- EXEC tempdb.dbo.sp_blocker_pss08 @fast=1
-- Or for latch mode 
-- EXEC tempdb.dbo.sp_blocker_pss08 @latch=1
WAITFOR DELAY '00:00:15'
END
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO 