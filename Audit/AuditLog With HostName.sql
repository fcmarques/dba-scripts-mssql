<<<<<<< HEAD
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLog')
   DROP TABLE dbo.AuditLog
GO

CREATE TABLE dbo.AuditLog(
    event_time DATETIME2(7) NOT NULL,
    sequence_number INT NOT NULL,
    action_id VARCHAR(4) NOT NULL DEFAULT '',
    succeeded BIT NOT NULL,
    permission_bitmask VARBINARY(16) NOT NULL,
    is_column_permission BIT NOT NULL,
    session_id SMALLINT NOT NULL,
    server_principal_id INT NOT NULL,
    database_principal_id INT NOT NULL,
    target_server_principal_id INT NOT NULL,
    target_database_principal_id INT NOT NULL,
    object_id INT NOT NULL,
    class_type VARCHAR(2) NULL,
    session_server_principal_name NVARCHAR(128) NULL,
    server_principal_name NVARCHAR(128) NULL,
    server_principal_sid VARBINARY(85) NULL,
    database_principal_name NVARCHAR(128) NULL,
    target_server_principal_name NVARCHAR(128) NULL,
    target_server_principal_sid VARBINARY(85) NULL,
    target_database_principal_name NVARCHAR(128) NULL,
    server_instance_name NVARCHAR(128) NULL,
    database_name NVARCHAR(128) NULL,
    schema_name NVARCHAR(128) NULL,
    object_name NVARCHAR(128) NULL,
    statement NVARCHAR(4000) NULL,
    additional_information XML NULL,
    file_name NVARCHAR(260) NOT NULL,
    audit_file_offset BIGINT NOT NULL,
    user_defined_event_id SMALLINT NOT NULL,
    user_defined_information NVARCHAR(4000) NULL,
    audit_schema_version INT NOT NULL,
    sequence_group_id VARBINARY(85) NOT NULL,
    transaction_id BIGINT NOT NULL,
    host_name NVARCHAR(255) NULL,
    related_login_event_time DATETIME2(7) NULL
    CONSTRAINT PKAuditLog PRIMARY KEY CLUSTERED (event_time, action_id, session_id, sequence_group_id, sequence_number)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

TRUNCATE TABLE AuditLog;

INSERT  dbo.AuditLog
        ( event_time ,
          sequence_number ,
          action_id ,
          succeeded ,
          permission_bitmask ,
          is_column_permission ,
          session_id ,
          server_principal_id ,
          database_principal_id ,
          target_server_principal_id ,
          target_database_principal_id ,
          object_id ,
          class_type ,
          session_server_principal_name ,
          server_principal_name ,
          server_principal_sid ,
          database_principal_name ,
          target_server_principal_name ,
          target_server_principal_sid ,
          target_database_principal_name ,
          server_instance_name ,
          database_name ,
          schema_name ,
          object_name ,
          statement ,
          additional_information ,
          file_name ,
          audit_file_offset ,
          user_defined_event_id ,
          user_defined_information ,
          audit_schema_version ,
          sequence_group_id ,
          transaction_id 
         )
        SELECT  fgaf.event_time ,
                fgaf.sequence_number ,
                fgaf.action_id ,
                fgaf.succeeded ,
                fgaf.permission_bitmask ,
                fgaf.is_column_permission ,
                fgaf.session_id ,
                fgaf.server_principal_id ,
                fgaf.database_principal_id ,
                fgaf.target_server_principal_id ,
                fgaf.target_database_principal_id ,
                fgaf.object_id ,
                fgaf.class_type ,
                fgaf.session_server_principal_name ,
                fgaf.server_principal_name ,
                fgaf.server_principal_sid ,
                fgaf.database_principal_name ,
                fgaf.target_server_principal_name ,
                fgaf.target_server_principal_sid ,
                fgaf.target_database_principal_name ,
                fgaf.server_instance_name ,
                fgaf.database_name ,
                fgaf.schema_name ,
                fgaf.object_name ,
                fgaf.statement ,
                fgaf.additional_information ,
                fgaf.file_name ,
                fgaf.audit_file_offset ,
                fgaf.user_defined_event_id ,
                fgaf.user_defined_information ,
                fgaf.audit_schema_version ,
                fgaf.sequence_group_id ,
                fgaf.transaction_id
        FROM    sys.fn_get_audit_file('c:\ESD\PMAudit*', DEFAULT, DEFAULT) AS fgaf
        WHERE   NOT EXISTS ( SELECT 1
                             FROM   dbo.AuditLog al
                             WHERE  al.event_time = fgaf.event_time
                                    AND al.action_id = fgaf.action_id
                                    AND al.session_id = fgaf.session_id
                                    AND al.sequence_group_id = fgaf.sequence_group_id )
                AND fgaf.action_id <> 'AUSC';
GO



CREATE PROCEDURE dbo.AuditLog_Insert
AS

CREATE TABLE #Logins
    (
      event_time DATETIME2(7) NOT NULL ,
      session_id SMALLINT NOT NULL ,
      server_principal_name NVARCHAR(128) NOT NULL ,
      sequence_group_id VARBINARY(85) NOT NULL, 
      host_name NVARCHAR(50) NULL ,
      session_seq BIGINT NOT NULL ,
      CONSTRAINT PKLogins PRIMARY KEY CLUSTERED (event_time, session_id, server_principal_name, sequence_group_id)
    )

;WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data' AS ns)
INSERT #Logins
        ( event_time ,
          session_id ,
          server_principal_name ,
          sequence_group_id ,
          host_name ,
          session_seq --Required as its possible to get duplicate event_time + session_id + server_principle_name combinations
        )
SELECT   a.event_time ,
         a.session_id ,
         a.server_principal_name ,
         sequence_group_id ,
         t.c.value ('ns:address[1]', 'varchar(50)') AS host_name,
         ROW_NUMBER() OVER ( PARTITION BY a.event_time,
                                            a.session_id,
                                            a.server_principal_name, t.c.value ('ns:address[1]', 'varchar(50)')  ORDER BY a.event_time DESC ) AS session_seq
FROM     dbo.AuditLog a
OUTER APPLY a.additional_information.nodes('//ns:action_info') AS t(c)
WHERE a.action_id = 'LGIS'

--Update the Select records with the host_name from login detail records .. using max event_time for that session
UPDATE  al
SET     al.host_name = l.host_name,
        al.related_login_event_time = l.event_time
FROM    dbo.AuditLog AS al
        JOIN #Logins l ON l.session_id = al.session_id
                       AND l.server_principal_name = al.server_principal_name
                       AND l.event_time = ( SELECT MAX(l2.event_time)
                                            FROM   #Logins AS l2
                                            WHERE  l2.event_time < al.event_time
                                            AND    l2.session_id = al.session_id
                                            AND    l2.server_principal_name = al.server_principal_name)

WHERE   al.action_id = 'SL'
        AND l.session_seq = 1 --It is possible to have duplicates because of horrible way SSMS operates
        AND al.host_name IS NULL -- Dont update records that have already been populated


--Remove unwanted login records from the Audit Log ... leaving only those related to select records.  Otherwise we are left with many duplicated login records.                 ;
DELETE  al
FROM    AuditLog al
WHERE   al.action_id = 'LGIS'
        AND NOT EXISTS ( SELECT 1
                         FROM   dbo.AuditLog al1
                         WHERE  al1.action_id = 'SL'
                                AND al1.related_login_event_time = al.event_time )


=======
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AuditLog')
   DROP TABLE dbo.AuditLog
GO

CREATE TABLE dbo.AuditLog(
    event_time DATETIME2(7) NOT NULL,
    sequence_number INT NOT NULL,
    action_id VARCHAR(4) NOT NULL DEFAULT '',
    succeeded BIT NOT NULL,
    permission_bitmask VARBINARY(16) NOT NULL,
    is_column_permission BIT NOT NULL,
    session_id SMALLINT NOT NULL,
    server_principal_id INT NOT NULL,
    database_principal_id INT NOT NULL,
    target_server_principal_id INT NOT NULL,
    target_database_principal_id INT NOT NULL,
    object_id INT NOT NULL,
    class_type VARCHAR(2) NULL,
    session_server_principal_name NVARCHAR(128) NULL,
    server_principal_name NVARCHAR(128) NULL,
    server_principal_sid VARBINARY(85) NULL,
    database_principal_name NVARCHAR(128) NULL,
    target_server_principal_name NVARCHAR(128) NULL,
    target_server_principal_sid VARBINARY(85) NULL,
    target_database_principal_name NVARCHAR(128) NULL,
    server_instance_name NVARCHAR(128) NULL,
    database_name NVARCHAR(128) NULL,
    schema_name NVARCHAR(128) NULL,
    object_name NVARCHAR(128) NULL,
    statement NVARCHAR(4000) NULL,
    additional_information XML NULL,
    file_name NVARCHAR(260) NOT NULL,
    audit_file_offset BIGINT NOT NULL,
    user_defined_event_id SMALLINT NOT NULL,
    user_defined_information NVARCHAR(4000) NULL,
    audit_schema_version INT NOT NULL,
    sequence_group_id VARBINARY(85) NOT NULL,
    transaction_id BIGINT NOT NULL,
    host_name NVARCHAR(255) NULL,
    related_login_event_time DATETIME2(7) NULL
    CONSTRAINT PKAuditLog PRIMARY KEY CLUSTERED (event_time, action_id, session_id, sequence_group_id, sequence_number)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

TRUNCATE TABLE AuditLog;

INSERT  dbo.AuditLog
        ( event_time ,
          sequence_number ,
          action_id ,
          succeeded ,
          permission_bitmask ,
          is_column_permission ,
          session_id ,
          server_principal_id ,
          database_principal_id ,
          target_server_principal_id ,
          target_database_principal_id ,
          object_id ,
          class_type ,
          session_server_principal_name ,
          server_principal_name ,
          server_principal_sid ,
          database_principal_name ,
          target_server_principal_name ,
          target_server_principal_sid ,
          target_database_principal_name ,
          server_instance_name ,
          database_name ,
          schema_name ,
          object_name ,
          statement ,
          additional_information ,
          file_name ,
          audit_file_offset ,
          user_defined_event_id ,
          user_defined_information ,
          audit_schema_version ,
          sequence_group_id ,
          transaction_id 
         )
        SELECT  fgaf.event_time ,
                fgaf.sequence_number ,
                fgaf.action_id ,
                fgaf.succeeded ,
                fgaf.permission_bitmask ,
                fgaf.is_column_permission ,
                fgaf.session_id ,
                fgaf.server_principal_id ,
                fgaf.database_principal_id ,
                fgaf.target_server_principal_id ,
                fgaf.target_database_principal_id ,
                fgaf.object_id ,
                fgaf.class_type ,
                fgaf.session_server_principal_name ,
                fgaf.server_principal_name ,
                fgaf.server_principal_sid ,
                fgaf.database_principal_name ,
                fgaf.target_server_principal_name ,
                fgaf.target_server_principal_sid ,
                fgaf.target_database_principal_name ,
                fgaf.server_instance_name ,
                fgaf.database_name ,
                fgaf.schema_name ,
                fgaf.object_name ,
                fgaf.statement ,
                fgaf.additional_information ,
                fgaf.file_name ,
                fgaf.audit_file_offset ,
                fgaf.user_defined_event_id ,
                fgaf.user_defined_information ,
                fgaf.audit_schema_version ,
                fgaf.sequence_group_id ,
                fgaf.transaction_id
        FROM    sys.fn_get_audit_file('c:\ESD\PMAudit*', DEFAULT, DEFAULT) AS fgaf
        WHERE   NOT EXISTS ( SELECT 1
                             FROM   dbo.AuditLog al
                             WHERE  al.event_time = fgaf.event_time
                                    AND al.action_id = fgaf.action_id
                                    AND al.session_id = fgaf.session_id
                                    AND al.sequence_group_id = fgaf.sequence_group_id )
                AND fgaf.action_id <> 'AUSC';
GO



CREATE PROCEDURE dbo.AuditLog_Insert
AS

CREATE TABLE #Logins
    (
      event_time DATETIME2(7) NOT NULL ,
      session_id SMALLINT NOT NULL ,
      server_principal_name NVARCHAR(128) NOT NULL ,
      sequence_group_id VARBINARY(85) NOT NULL, 
      host_name NVARCHAR(50) NULL ,
      session_seq BIGINT NOT NULL ,
      CONSTRAINT PKLogins PRIMARY KEY CLUSTERED (event_time, session_id, server_principal_name, sequence_group_id)
    )

;WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data' AS ns)
INSERT #Logins
        ( event_time ,
          session_id ,
          server_principal_name ,
          sequence_group_id ,
          host_name ,
          session_seq --Required as its possible to get duplicate event_time + session_id + server_principle_name combinations
        )
SELECT   a.event_time ,
         a.session_id ,
         a.server_principal_name ,
         sequence_group_id ,
         t.c.value ('ns:address[1]', 'varchar(50)') AS host_name,
         ROW_NUMBER() OVER ( PARTITION BY a.event_time,
                                            a.session_id,
                                            a.server_principal_name, t.c.value ('ns:address[1]', 'varchar(50)')  ORDER BY a.event_time DESC ) AS session_seq
FROM     dbo.AuditLog a
OUTER APPLY a.additional_information.nodes('//ns:action_info') AS t(c)
WHERE a.action_id = 'LGIS'

--Update the Select records with the host_name from login detail records .. using max event_time for that session
UPDATE  al
SET     al.host_name = l.host_name,
        al.related_login_event_time = l.event_time
FROM    dbo.AuditLog AS al
        JOIN #Logins l ON l.session_id = al.session_id
                       AND l.server_principal_name = al.server_principal_name
                       AND l.event_time = ( SELECT MAX(l2.event_time)
                                            FROM   #Logins AS l2
                                            WHERE  l2.event_time < al.event_time
                                            AND    l2.session_id = al.session_id
                                            AND    l2.server_principal_name = al.server_principal_name)

WHERE   al.action_id = 'SL'
        AND l.session_seq = 1 --It is possible to have duplicates because of horrible way SSMS operates
        AND al.host_name IS NULL -- Dont update records that have already been populated


--Remove unwanted login records from the Audit Log ... leaving only those related to select records.  Otherwise we are left with many duplicated login records.                 ;
DELETE  al
FROM    AuditLog al
WHERE   al.action_id = 'LGIS'
        AND NOT EXISTS ( SELECT 1
                         FROM   dbo.AuditLog al1
                         WHERE  al1.action_id = 'SL'
                                AND al1.related_login_event_time = al.event_time )


>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
GO