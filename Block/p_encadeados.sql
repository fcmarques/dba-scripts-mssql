<<<<<<< HEAD
USE [msdb]
GO
/****** Object:  StoredProcedure [dbo].[p_encadeados]    Script Date: 06/24/2014 12:38:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[p_encadeados]
WITH ENCRYPTION
as
begin
-- BLOQUEIOS ENCADEADOS

-- Soma de Bloqueios Total
SELECT blocking_session_id As Sessao, COUNT(session_id) As TotalBloqueios
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0
GROUP BY blocking_session_id
ORDER BY TotalBloqueios DESC

-- Soma de Bloqueios - Mostra cadeia de bloqueios

;WITH Sessoes (Sessao, Bloqueadora) As (
   SELECT Session_Id, Blocking_Session_Id
   FROM sys.dm_exec_requests As R
   WHERE blocking_session_id > 0
   UNION ALL
   SELECT Session_Id, CAST(0 As SMALLINT)
   FROM sys.dm_exec_sessions As S
   WHERE EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Blocking_Session_Id)
   AND NOT EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Session_Id)
),
Bloqueios As (
   SELECT
       CAST(Sessao As VARCHAR(200)) As Cadeia,
       Sessao, Bloqueadora, 1 As Nivel
   FROM Sessoes
   UNION ALL
   SELECT CAST(B.Cadeia + ' -> ' + CAST(S.Sessao As VARCHAR(5)) As VARCHAR(200)),
       S.Sessao, B.Sessao, Nivel + 1
   FROM Bloqueios As B
   INNER JOIN Sessoes As S ON B.Sessao = S.Bloqueadora)
SELECT Cadeia FROM Bloqueios
WHERE Nivel = (SELECT MAX(Nivel) FROM Bloqueios)
ORDER BY Cadeia

-- Soma de Bloqueios - Mostra sessão que tem mais bloqueios indiretos
;WITH Sessoes (Sessao, Bloqueadora) As (
   SELECT Session_Id, Blocking_Session_Id
   FROM sys.dm_exec_requests As R
   WHERE blocking_session_id > 0
   UNION ALL
   SELECT Session_Id, CAST(0 As SMALLINT)
   FROM sys.dm_exec_sessions As S
   WHERE EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Blocking_Session_Id)
   AND NOT EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Session_Id)
),
Bloqueios As (
   SELECT 
       Sessao, Bloqueadora, Sessao As Ref, 1 As Nivel
   FROM Sessoes
   UNION ALL
   SELECT S.Sessao, B.Sessao, B.Ref, Nivel + 1
   FROM Bloqueios As B
   INNER JOIN Sessoes As S ON B.Sessao = S.Bloqueadora)
SELECT Ref As Sessao,
   COUNT(DISTINCT R.Session_Id) As BloqueiosDiretos,
   COUNT(DISTINCT B.Sessao) - 1 As BloqueiosTotal,
   COUNT(DISTINCT B.Sessao) - COUNT(DISTINCT R.Session_Id) - 1 As BloqueiosIndiretos
FROM Bloqueios As B
   INNER JOIN sys.dm_exec_requests As R
       ON B.Ref = R.blocking_session_id
GROUP BY Ref
=======
USE [msdb]
GO
/****** Object:  StoredProcedure [dbo].[p_encadeados]    Script Date: 06/24/2014 12:38:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[p_encadeados]
WITH ENCRYPTION
as
begin
-- BLOQUEIOS ENCADEADOS

-- Soma de Bloqueios Total
SELECT blocking_session_id As Sessao, COUNT(session_id) As TotalBloqueios
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0
GROUP BY blocking_session_id
ORDER BY TotalBloqueios DESC

-- Soma de Bloqueios - Mostra cadeia de bloqueios

;WITH Sessoes (Sessao, Bloqueadora) As (
   SELECT Session_Id, Blocking_Session_Id
   FROM sys.dm_exec_requests As R
   WHERE blocking_session_id > 0
   UNION ALL
   SELECT Session_Id, CAST(0 As SMALLINT)
   FROM sys.dm_exec_sessions As S
   WHERE EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Blocking_Session_Id)
   AND NOT EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Session_Id)
),
Bloqueios As (
   SELECT
       CAST(Sessao As VARCHAR(200)) As Cadeia,
       Sessao, Bloqueadora, 1 As Nivel
   FROM Sessoes
   UNION ALL
   SELECT CAST(B.Cadeia + ' -> ' + CAST(S.Sessao As VARCHAR(5)) As VARCHAR(200)),
       S.Sessao, B.Sessao, Nivel + 1
   FROM Bloqueios As B
   INNER JOIN Sessoes As S ON B.Sessao = S.Bloqueadora)
SELECT Cadeia FROM Bloqueios
WHERE Nivel = (SELECT MAX(Nivel) FROM Bloqueios)
ORDER BY Cadeia

-- Soma de Bloqueios - Mostra sessão que tem mais bloqueios indiretos
;WITH Sessoes (Sessao, Bloqueadora) As (
   SELECT Session_Id, Blocking_Session_Id
   FROM sys.dm_exec_requests As R
   WHERE blocking_session_id > 0
   UNION ALL
   SELECT Session_Id, CAST(0 As SMALLINT)
   FROM sys.dm_exec_sessions As S
   WHERE EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Blocking_Session_Id)
   AND NOT EXISTS (
       SELECT * FROM sys.dm_exec_requests As R
       WHERE S.Session_Id = R.Session_Id)
),
Bloqueios As (
   SELECT 
       Sessao, Bloqueadora, Sessao As Ref, 1 As Nivel
   FROM Sessoes
   UNION ALL
   SELECT S.Sessao, B.Sessao, B.Ref, Nivel + 1
   FROM Bloqueios As B
   INNER JOIN Sessoes As S ON B.Sessao = S.Bloqueadora)
SELECT Ref As Sessao,
   COUNT(DISTINCT R.Session_Id) As BloqueiosDiretos,
   COUNT(DISTINCT B.Sessao) - 1 As BloqueiosTotal,
   COUNT(DISTINCT B.Sessao) - COUNT(DISTINCT R.Session_Id) - 1 As BloqueiosIndiretos
FROM Bloqueios As B
   INNER JOIN sys.dm_exec_requests As R
       ON B.Ref = R.blocking_session_id
GROUP BY Ref
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
