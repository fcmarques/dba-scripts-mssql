SELECT s.NAME
	,se.event_name
FROM sys.dm_xe_sessions s
INNER JOIN sys.dm_xe_session_events se ON (s.address = se.event_session_address)
	AND (event_name = 'xml_deadlock_report')
WHERE NAME = 'system_health'