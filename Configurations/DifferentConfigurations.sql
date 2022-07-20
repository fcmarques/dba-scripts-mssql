<<<<<<< HEAD
SELECT ccm.configuration_id, ccm.name, ccm.value_in_use, itv.value_in_use
FROM sys.configurations ccm
 join GISD0013SQL.master.sys.configurations itv 
on ccm.configuration_id = itv.configuration_id
where ccm.value_in_use <> itv.value_in_use
order by 2;
=======
SELECT ccm.configuration_id, ccm.name, ccm.value_in_use, itv.value_in_use
FROM sys.configurations ccm
 join GISD0013SQL.master.sys.configurations itv 
on ccm.configuration_id = itv.configuration_id
where ccm.value_in_use <> itv.value_in_use
order by 2;
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
