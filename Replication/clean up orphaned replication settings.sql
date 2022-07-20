-- Connect Subscriber
:connect TestSubSQL1
use [master]
exec sp_helpreplicationdboption @dbname = N'MyReplDB'
go
use [MyReplDB]
exec sp_subscription_cleanup @publisher = N'TestPubSQL1', @publisher_db = N'MyReplDB', 
@publication = N'MyReplPub'
go
-- Connect Publisher Server
:connect TestPubSQL1
-- Drop Subscription
use [MyReplDB]
exec sp_dropsubscription @publication = N'MyReplPub', @subscriber = N'all', 
@destination_db = N'MyReplDB', @article = N'all'
go
-- Drop publication
exec sp_droppublication @publication = N'MyReplPub'
-- Disable replication db option
exec sp_replicationdboption @dbname = N'MyReplDB', @optname = N'publish', @value = N'false'
GO