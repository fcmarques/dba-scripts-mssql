--Primeiro vamos declarar tr�s vari�veis: @@edition, @cpu e @maxwthreads.


DECLARE @@edition VARCHAR(50);
DECLARE @cpu VARCHAR(50);
DECLARE @maxwthreads INT;

/*
Vamos agora atribuir os valores as nossas vari�veis, utilizando a fun��o SERVERPROPERTY populo a vari�vel @@edition com informa��es referente a edi��o do SQL Server. Quanto a segunda vari�vel, @cpu, iremos popular ela com o valor obtido de uma query de contagem disparada contra a sys.dm_os_schedulers pegando apenas as cpu�s que est�o vis�veis a inst�ncia, 'VISIBLE ONLINE', quanto a vari�vel @maxwthreads, iremos popular ela com o valor configurado para o par�metro 'Max Worker Threads' nas configura��es da inst�ncia, esta informa��o iremos capturar da sys.configurations.

Atualizado em: 08/04/2014.

*/

SET @@edition = CAST((SELECT SERVERPROPERTY ('edition')) AS VARCHAR)
SET @cpu = CAST((SELECT COUNT(1) FROM sys.dm_os_schedulers WHERE STATUS = 'visible online') AS VARCHAR)
SET @maxwthreads = CAST((SELECT value FROM sys.configurations WHERE name = 'max worker threads') AS VARCHAR)

/*
Caso o 'Max Worker Threads' esteja configurado em seu valor padr�o, zero, a l�gica da tabela ser� aplicada. Caso o valor esteja diferente de zero, ele ser� verificado no intuito de saber se est� dentro do que a Microsoft suporta ou n�o.
*/

IF (@maxwthreads) = 0
       BEGIN
             IF (@@edition) LIKE '%64-bit%'
                    IF (@cpu) <= 4
                    SELECT 512 as max_threads
                    ELSE IF (@cpu) <= 64
                           SELECT (@cpu-4)*16+512 AS max_threads
                           ELSE SELECT (@cpu-4)*32+512 AS max_threads
             ELSE IF (@cpu) <=4
                    SELECT 256 AS max_threads
                    ELSE SELECT (@cpu-4)*8+256 as max_threads
END

ELSE IF (@maxwthreads) > 1024 and (@@edition) NOT LIKE '%64-bit%'
             SELECT 'O valor do Max Worker Threads est� fixado em: ' +CONVERT(VARCHAR(25),@maxwthreads) +'. Este valor est� acima do suportado pela Microsoft nesta plataforma que � de 2048.'
ELSE
             SELECT 'O valor do Max Worker Threads est� fixado em: ' +CONVERT(VARCHAR(25),@maxwthreads) +'.'