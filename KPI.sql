use dbalog
go
select sum(DS_TMHO_OCDO)/1024, DS_SRDR_ANSE,  DT_CDRO_MNRR_CSMO
 select * 
 from TARD_MNRR_CSMO
 where datepart(year, dt_cdro_mnrr_csmo)='2014'
 order by DS_NOME_BASE

 where DS_NOME_BASE='R3p'
group by DS_SRDR_ANSE,DT_CDRO_MNRR_CSMO

select * from TARD_MNRR_CSMO



--select servidor, sum(capacidade), sum(capacidade)-sum(freespace), sum(freespace) from discmon
--where data = '2015-02-28'
--group by servidor
--order by 1

