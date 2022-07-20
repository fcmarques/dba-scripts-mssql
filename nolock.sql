use sicc
go
 select db_name() as banco,object_name (id)  as objeto
 from sys.objects as a join sys.syscomments as b on a.object_id = b.id 
where a.type_desc = 'SQL_STORED_PROCEDURE' 
and text not like '%nolock%'
--and text like '%from%'
--and text like '%select%'
and text like '%tb_crm_upd_cartao_bandeira%'
order by 2

sp_helptext 'pr_crm_upd_d'