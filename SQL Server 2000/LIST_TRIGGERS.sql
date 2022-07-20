select object_name(id) as TABLE_NAME, object_name(deltrig) AS DEL_TRIGGER,
object_name(instrig) AS INS_TRIGGER, object_name(updtrig) AS UPD_TRIGGER
from sysobjects
where xtype ='U'
and
(deltrig > 0 or instrig > 0 or updtrig > 0)


select 
"Table"=P.Name,
"Trigger Name"=O.name, 
"Trigger Date"=O.refdate,
"Defn"=CASE C.encrypted WHEN 0 THEN C.text ELSE '<< ENCRYPTED >>' END
from 
syscomments C 
INNER JOIN sysobjects O ON (C.id = O.id)
INNER JOIN sysobjects P ON (O.parent_obj = P.id)
where 
O.xtype = 'TR'


SELECT trigger_name = name, trigger_owner = USER_NAME(uid), table_name = OBJECT_NAME(parent_obj),
  isupdate = OBJECTPROPERTY( id, 'ExecIsUpdateTrigger'), isdelete = OBJECTPROPERTY( id, 'ExecIsDeleteTrigger'),
  isinsert = OBJECTPROPERTY( id, 'ExecIsInsertTrigger'), isafter = OBJECTPROPERTY( id, 'ExecIsAfterTrigger'),
  isinsteadof = OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger'),
  status = CASE OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') WHEN 1 THEN 'Disabled' ELSE 'Enabled' END
FROM sysobjects
WHERE type = 'TR'
