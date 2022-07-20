exec sp_addlinkedserver 'PETROPOLIS', 'Oracle', 'MSDAORA', 'PETROPOLIS'
go
exec sp_addlinkedsrvlogin 'PETROPOLIS', false, 'sa', 'PETROPOLIS', 'PETROPOLIS'
go