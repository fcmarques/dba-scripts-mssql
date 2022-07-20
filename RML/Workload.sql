use PrecisionPerformance
go

--		This is a query plan that will change when the data is truncated from the table
--		So when the Quick Start clone activity is performed the example will show the
--		plan change.
--
--		We use 200000 here like an OPTIMIZE type of action and with the number of
--		rows in table the plan will change on truncation.
--set statistics profile on
select dtEntry, count(*) as [Date Count] from tblTest
	where iID in (select iID from tblTest where iID >= 0 and iID <= 200000)
	group by dtEntry 
	order by dtEntry desc
option (MAXDOP 1, LOOP JOIN, ORDER GROUP, FAST 50)
--set statistics profile off
go