SELECT 
    su.name AS 'User'
  , CASE   
      WHEN issqlrole = 1 THEN 'Role'
      WHEN issqluser = 1 THEN 'SQL User'
      WHEN isntuser = 1 THEN 'AD User'
      WHEN isntgroup = 1 THEN 'AD Group'
   END as UserType
  , CASE sp.protecttype
      WHEN 204 THEN 'GRANT w/ GRANT'
      WHEN 205 THEN 'GRANT'
      WHEN 206 THEN 'DENY' END AS 'Permission'
  , CASE sp.action
      WHEN 26 THEN 'REFERENCES'
      WHEN 193 THEN 'SELECT'
      WHEN 195 THEN 'INSERT'
      WHEN 196 THEN 'DELETE'
      WHEN 197 THEN 'UPDATE'
      WHEN 224 THEN 'EXECUTE' END AS 'Action'
  , so.name AS 'Object'
FROM sysprotects sp
  INNER JOIN sysusers su
    ON sp.uid = su.uid
  INNER JOIN sysobjects so
    ON sp.id = so.id
WHERE sp.action IN (26, 193, 195, 196, 197, 224) 
ORDER BY su.name, so.name;


select * from sysusers
where name  = 'Uverlan'