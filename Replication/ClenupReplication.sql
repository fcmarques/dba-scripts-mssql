use [AUTCOM]
go
exec sp_dropsubscription @publication = N'all', @subscriber = N'all', @ignore_distributor=1
go
exec sp_droppublication @Publication='all',@ignore_distributor=1
GO
exec sp_removedbreplication 'both'
go
exec Distribution.dbo.sp_MSremove_published_jobs @server = 'R-DBGEN64', @database = 'SQLREPL'
go
select * from Distribution.dbo.MSpublications
GO
EXEC sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
GO
