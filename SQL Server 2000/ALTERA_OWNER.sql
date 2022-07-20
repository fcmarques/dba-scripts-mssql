DECLARE @NM_TABELA VARCHAR(40)
DECLARE @NM_TABELA2 VARCHAR(100)
DECLARE @NM_USUARIO_ANTIGO VARCHAR(100)
DECLARE @NM_USUARIO_NOVO VARCHAR(100)

SET @NM_USUARIO_ANTIGO = 'AnflaHospitalar'
SET @NM_USUARIO_NOVO = 'dbo'

DECLARE CUR_TABELAS CURSOR FOR

    SELECT OBJ.NAME FROM SYSOBJECTS OBJ
    
    JOIN SYSUSERS USR
    	ON OBJ.UID = USR.UID
    
    WHERE OBJ.XTYPE = 'U'
    	AND USR.NAME = @NM_USUARIO_ANTIGO

OPEN CUR_TABELAS

FETCH NEXT FROM CUR_TABELAS
INTO @NM_TABELA

WHILE @@FETCH_STATUS = 0
    BEGIN
    	SET @NM_TABELA2 = @NM_USUARIO_ANTIGO + '.' + @NM_TABELA
    	EXEC SP_CHANGEOBJECTOWNER @NM_TABELA2, @NM_USUARIO_NOVO
        FETCH NEXT FROM CUR_TABELAS
    	INTO @NM_TABELA

END

CLOSE CUR_TABELAS
DEALLOCATE CUR_TABELAS