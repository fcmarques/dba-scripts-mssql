-- Criação da tabela de testes do Dynamic Data Masking
-- Máscaras criadas nas colunas "CPF" e "Nome" na criação na tabela
IF (OBJECT_ID('dbo.TB_DYNAMIC_DATA_MASKING') IS NOT NULL) DROP TABLE dbo.TB_DYNAMIC_DATA_MASKING
CREATE TABLE dbo.TB_DYNAMIC_DATA_MASKING (
    CPF VARCHAR(11) MASKED WITH(FUNCTION = 'partial(0, "XXXXXXXXX", 2)'),
    Nome VARCHAR(60) MASKED WITH(FUNCTION = 'default()'),
    Cargo VARCHAR(40),
    Data_Nascimento DATETIME,
    Email VARCHAR(100),
    Email_Corporativo VARCHAR(100),
    Salario NUMERIC(15, 2),
    Numero_Cartao VARCHAR(16),
    Peso INT,
    Altura FLOAT,
    Estado_Civil SMALLINT,
    Genero BIT
)

-- Inseração de registro na tabela de testes
INSERT INTO dbo.TB_DYNAMIC_DATA_MASKING
VALUES
(
    '12345678909', -- CPF - varchar(11)
    'Joãozinho da Silva', -- Nome - varchar(60)
    'Analista de Sistemas', -- Cargo - varchar(40)
    '1987-05-28', -- Data_Nascimento - datetime
    'joaozinho.silva@yahoo.com.br', -- Email - varchar(100)
    'joaozinho.silva@suaempresa.com', -- Email_Corporativo - varchar(100)
    12345.67, -- Salario - numeric(15, 2)
    '1234567890123456', -- Numero_Cartao - varchar(16)
    85, -- Peso - int
    1.81, -- Altura - float
    1, -- Estado_Civil - smallint
    1 -- Genero - bit
)

SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
GO

-- Vamos criar um usuário para conseguirmos visualizar os dados mascarados
-- Lembre-se: Usuários com permissão db_owner ou sysadmin SEMPRE vão ver os dados sem máscara

    
GRANT SELECT ON dbo.TB_DYNAMIC_DATA_MASKING TO [UsrSecurityDemo]


-- Visualizando os dados mascarados (Como se fosse o usuário TB_DYNAMIC_DATA_MASKING, que acabamos de criar)
EXECUTE AS USER = 'TB_DYNAMIC_DATA_MASKING'
GO
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
GO
REVERT -- Reverte as permissões para o seu usuário
GO


-- Vamos criar mais algumas máscaras na tabela
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Cargo ADD MASKED WITH(FUNCTION = 'partial(4, "XXXX", 4)')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Data_Nascimento ADD MASKED WITH(FUNCTION = 'default()')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Email ADD MASKED WITH(FUNCTION = 'email()')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Email_Corporativo ADD MASKED WITH(FUNCTION = 'email()')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Salario ADD MASKED WITH(FUNCTION = 'random(0.5, 0.99)')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Numero_Cartao ADD MASKED WITH(FUNCTION = 'partial(4, "********", 4)')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Peso ADD MASKED WITH(FUNCTION = 'random(70, 120)')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Altura ADD MASKED WITH(FUNCTION = 'default()')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Estado_Civil ADD MASKED WITH(FUNCTION = 'default()')
ALTER TABLE dbo.TB_DYNAMIC_DATA_MASKING ALTER COLUMN Genero ADD MASKED WITH(FUNCTION = 'default()')


-- Visualizando os dados mascarados
EXECUTE AS USER = 'TB_DYNAMIC_DATA_MASKING'
GO
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
SELECT * FROM dbo.TB_DYNAMIC_DATA_MASKING
REVERT