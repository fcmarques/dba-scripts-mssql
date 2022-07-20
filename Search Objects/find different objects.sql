--find procs with different code
select 
'
select '''+name+''',t1.name,t1.modify_date,t2.modify_date
 from MemberDBAlibahis.sys.procedures t1
join '+name+'.sys.procedures t2 on t1.name  = t2.name
and  object_definition(t1.object_id) <>  object_definition(t2.object_id)
and t1.name = ''GetRegistrationListNewBO2'';
'
from sys.databases
where name like 'MemberDB%'
order by 1

--find procs with different parameters
select 
'
select '''+name+''',pro.name, max(par.parameter_id) param_qtd
from '+name+'.sys.procedures pro
join '+name+'.sys.parameters par on par.object_id = pro.object_id
where pro.name = ''GetRegistrationListNewBO2''
group by pro.name;
'
from sys.databases
where name like 'MemberDB%'
order by 1