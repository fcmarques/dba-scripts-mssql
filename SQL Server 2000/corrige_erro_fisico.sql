--dbo.SP_RESTORE_DATABASE HOSPITALAR_ONCOCLINICA, 'D:\RESTORE\Oncoclinica_26_07'

insert into PACIENTE_SOCIO_ECONOMICO (PSE_ID, PAC_ID, PSE_DT, USR_ID_ATUA, DT_ATUA)
values (1582, 2677, '01/01/2006 00:00', 698, '01/01/2006 00:00')


ALTER DATABASE HOSPITALAR_CEASC SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CHECKDB( 'db_mercury_val', REPAIR_REBUILD )
--DBCC CHECKDB( 'HOSPITALAR_CEASC', REPAIR_REBUILD )
--DBCC CHECKDB( 'HOSPITALAR_CEASC', REPAIR_ALLOW_DATA_LOSS )
ALTER DATABASE HOSPITALAR_CEASC SET MULTI_USER