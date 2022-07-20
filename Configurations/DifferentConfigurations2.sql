<<<<<<< HEAD
-- Instance Configurations
SELECT dev.configuration_id,
    dev.name,
    dev.value AS DevValue,
    int.value AS IntValue
FROM
(
    SELECT *
    FROM [BRDEVDB01].[master].[sys].[configurations]
) dev
INNER JOIN
(
    SELECT *
    FROM [SPORTSPRODDB01].[master].[sys].[configurations]
) int
ON dev.configuration_id = int.configuration_id
    AND (dev.value != int.value
         OR dev.value_in_use != int.value_in_use);

-- Database Configurations

select 'SPORTSPRODDB01' as servername, * from SPORTSPRODDB01.master.sys.databases
where name = 'SportsBook'
union all
select 'BRDEVDB01' as servername, * from BRDEVDB01.master.sys.databases
where name = 'UOF_IN_MEMORY';

-- Database Scoped Configurations

SELECT dev.configuration_id,
    dev.name,
    dev.value AS DevValue,
    int.value AS IntValue
FROM
(
    SELECT *
    FROM [BRDEVDB01].[UOF_IN_MEMORY].[sys].[database_scoped_configurations]
) dev
INNER JOIN
(
    SELECT *
    FROM [SPORTSPRODDB01].[SportsBook].[sys].[database_scoped_configurations]
) int
ON dev.configuration_id = int.configuration_id
=======
-- Instance Configurations
SELECT dev.configuration_id,
    dev.name,
    dev.value AS DevValue,
    int.value AS IntValue
FROM
(
    SELECT *
    FROM [BRDEVDB01].[master].[sys].[configurations]
) dev
INNER JOIN
(
    SELECT *
    FROM [SPORTSPRODDB01].[master].[sys].[configurations]
) int
ON dev.configuration_id = int.configuration_id
    AND (dev.value != int.value
         OR dev.value_in_use != int.value_in_use);

-- Database Configurations

select 'SPORTSPRODDB01' as servername, * from SPORTSPRODDB01.master.sys.databases
where name = 'SportsBook'
union all
select 'BRDEVDB01' as servername, * from BRDEVDB01.master.sys.databases
where name = 'UOF_IN_MEMORY';

-- Database Scoped Configurations

SELECT dev.configuration_id,
    dev.name,
    dev.value AS DevValue,
    int.value AS IntValue
FROM
(
    SELECT *
    FROM [BRDEVDB01].[UOF_IN_MEMORY].[sys].[database_scoped_configurations]
) dev
INNER JOIN
(
    SELECT *
    FROM [SPORTSPRODDB01].[SportsBook].[sys].[database_scoped_configurations]
) int
ON dev.configuration_id = int.configuration_id
>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
    AND (dev.value != int.value);