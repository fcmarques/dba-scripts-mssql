USE [WalletDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	Create FileGroups and DataFiles
*/

ALTER DATABASE [WalletDB] ADD FILEGROUP [FG_SoftGamingTransaction_202010]
GO
ALTER DATABASE [WalletDB] ADD FILEGROUP [FG_SoftGamingTransaction_202011]
GO
ALTER DATABASE [WalletDB] ADD FILEGROUP [FG_SoftGamingTransaction_202012]
GO
ALTER DATABASE [WalletDB] ADD FILEGROUP [FG_SoftGamingTransaction_202101]
GO

ALTER DATABASE [WalletDB] ADD FILE ( NAME = N'SoftGamingTransaction_202010', FILENAME = N'G:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Data\WalletDB\SoftGamingTransaction_202010.ndf' , SIZE = 1048576KB , FILEGROWTH = 1048576KB ) TO FILEGROUP [FG_SoftGamingTransaction_202010]
GO
ALTER DATABASE [WalletDB] ADD FILE ( NAME = N'SoftGamingTransaction_202011', FILENAME = N'G:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Data\WalletDB\SoftGamingTransaction_202011.ndf' , SIZE = 1048576KB , FILEGROWTH = 1048576KB ) TO FILEGROUP [FG_SoftGamingTransaction_202011]
GO
ALTER DATABASE [WalletDB] ADD FILE ( NAME = N'SoftGamingTransaction_202012', FILENAME = N'G:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Data\WalletDB\SoftGamingTransaction_202012.ndf' , SIZE = 1048576KB , FILEGROWTH = 1048576KB ) TO FILEGROUP [FG_SoftGamingTransaction_202012]
GO
ALTER DATABASE [WalletDB] ADD FILE ( NAME = N'SoftGamingTransaction_202101', FILENAME = N'G:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Data\WalletDB\SoftGamingTransaction_202101.ndf' , SIZE = 1048576KB , FILEGROWTH = 1048576KB ) TO FILEGROUP [FG_SoftGamingTransaction_202101]
GO


/*
	Create new partition schema and funtion
*/

CREATE PARTITION FUNCTION [PF_SoftGamingTransaction_right](datetime) AS RANGE RIGHT FOR VALUES (N'2020-06-01', N'2020-07-01', N'2020-08-01', N'2020-09-01', N'2020-10-01', N'2020-11-01', N'2020-12-01')
GO

CREATE PARTITION SCHEME [PS_SoftGamingTransaction_right] AS PARTITION [PF_SoftGamingTransaction_right] TO ([PRIMARY], [FG_SoftGamingTransaction_202006], [FG_SoftGamingTransaction_202007],[FG_SoftGamingTransaction_202008], [FG_SoftGamingTransaction_202009],[FG_SoftGamingTransaction_202010], [FG_SoftGamingTransaction_202011], [FG_SoftGamingTransaction_202012], [FG_SoftGamingTransaction_202101])
GO

/*
	Rename actual table
*/

EXEC sp_rename 'SoftGamingTransaction', 'SoftGamingTransaction_old';  
GO

/*
	Create new empty table - 182867044
*/

CREATE TABLE [dbo].[SoftGamingTransaction](
	[Id] [bigint] IDENTITY(185000000,1) NOT NULL,
	[MethodId] [int] NOT NULL,
	[MemberId] [int] NOT NULL,
	[Tid] [nvarchar](50) NULL,
	[Currency] [nvarchar](10) NULL,
	[Amount] [bigint] NOT NULL,
	[GameId] [nvarchar](50) NOT NULL,
	[Extparam] [nvarchar](255) NULL,
	[Gamedesc] [nvarchar](255) NULL,
	[ActionId] [nvarchar](50) NULL,
	[Subtype] [nvarchar](50) NULL,
	[RoundInfoActions] [nvarchar](max) NULL,
	[Hmac] [nvarchar](500) NULL,
	[BlockedBalance] [bigint] NOT NULL,
	[BlockedBonusBalance] [bigint] NOT NULL,
	[BalanceAfter] [bigint] NOT NULL,
	[BonusBalanceAfter] [bigint] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[GameExtra] [nvarchar](255) NULL
) 
GO

ALTER TABLE [dbo].[SoftGamingTransaction] ADD  CONSTRAINT [PK_SoftGamingTransaction_r] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)
GO

ALTER TABLE [dbo].[SoftGamingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_SoftGamingTransaction_Member_] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Member] ([Id])
GO

ALTER TABLE [dbo].[SoftGamingTransaction] CHECK CONSTRAINT [FK_SoftGamingTransaction_Member_]
GO

ALTER TABLE [dbo].[SoftGamingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_SoftGamingTransaction_SoftGamingTransactionMethod] FOREIGN KEY([MethodId])
REFERENCES [dbo].[SoftGamingTransactionMethod] ([Id])
GO

ALTER TABLE [dbo].[SoftGamingTransaction] CHECK CONSTRAINT [FK_SoftGamingTransaction_SoftGamingTransactionMethod]
GO


/*n
	Create indexes
*/

CREATE CLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_Partition] ON [dbo].[SoftGamingTransaction]
(
	[CreatedDate] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_1] ON [dbo].[SoftGamingTransaction]
(
	[Tid] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_2] ON [dbo].[SoftGamingTransaction]
(
	[MethodId] ASC,
	[GameId] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_20] ON [dbo].[SoftGamingTransaction]
(
	[CreatedDate] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_24] ON [dbo].[SoftGamingTransaction]
(
	[ActionId] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_29] ON [dbo].[SoftGamingTransaction]
(
	[MemberId] ASC
)
INCLUDE ( 	[MethodId],
	[Tid],
	[Currency],
	[Amount],
	[GameId],
	[Extparam],
	[Gamedesc],
	[ActionId],
	[Subtype],
	[RoundInfoActions],
	[Hmac],
	[BlockedBalance],
	[BlockedBonusBalance],
	[BalanceAfter],
	[BonusBalanceAfter],
	[Status],
	[GameExtra]) ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_30] ON [dbo].[SoftGamingTransaction]
(
	[GameId] ASC
)ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_32] ON [dbo].[SoftGamingTransaction]
(
	[MemberId] ASC
)
INCLUDE ( 	[MethodId],
	[Tid],
	[Currency],
	[Amount],
	[GameId],
	[Extparam],
	[Gamedesc],
	[ActionId],
	[Subtype],
	[RoundInfoActions],
	[Hmac],
	[BlockedBalance],
	[BlockedBonusBalance],
	[BalanceAfter],
	[BonusBalanceAfter],
	[Status],
	[CreatedDate],
	[GameExtra]) ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_34] ON [dbo].[SoftGamingTransaction]
(
	[MemberId] ASC,
	[Amount] ASC
)
INCLUDE ( 	[MethodId],
	[Tid],
	[Currency],
	[GameId],
	[Extparam],
	[Gamedesc],
	[ActionId],
	[Subtype],
	[RoundInfoActions],
	[Hmac],
	[BlockedBalance],
	[BlockedBonusBalance],
	[BalanceAfter],
	[BonusBalanceAfter],
	[Status],
	[CreatedDate],
	[GameExtra])  ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

CREATE NONCLUSTERED INDEX [IX_WalletDB_SoftGamingTransaction_r_38] ON [dbo].[SoftGamingTransaction]
(
	[MemberId] ASC,
	[Amount] ASC
)
INCLUDE ( 	[MethodId],
	[Tid],
	[Currency],
	[GameId],
	[Extparam],
	[Gamedesc],
	[ActionId],
	[Subtype],
	[RoundInfoActions],
	[Hmac],
	[BlockedBalance],
	[BlockedBonusBalance],
	[BalanceAfter],
	[BonusBalanceAfter],
	[Status],
	[GameExtra])  ON PS_SoftGamingTransaction_right ([CreatedDate])
GO

/*
	Insert last 24h of data
*/

SET IDENTITY_INSERT SoftGamingTransaction ON;  

INSERT INTO [dbo].[SoftGamingTransaction]
           ([id]
		   ,[MethodId]
           ,[MemberId]
           ,[Tid]
           ,[Currency]
           ,[Amount]
           ,[GameId]
           ,[Extparam]
           ,[Gamedesc]
           ,[ActionId]
           ,[Subtype]
           ,[RoundInfoActions]
           ,[Hmac]
           ,[BlockedBalance]
           ,[BlockedBonusBalance]
           ,[BalanceAfter]
           ,[BonusBalanceAfter]
           ,[Status]
           ,[CreatedDate]
           ,[GameExtra])

SELECT      [id]
		   ,[MethodId]
           ,[MemberId]
           ,[Tid]
           ,[Currency]
           ,[Amount]
           ,[GameId]
           ,[Extparam]
           ,[Gamedesc]
           ,[ActionId]
           ,[Subtype]
           ,[RoundInfoActions]
           ,[Hmac]
           ,[BlockedBalance]
           ,[BlockedBonusBalance]
           ,[BalanceAfter]
           ,[BonusBalanceAfter]
           ,[Status]
           ,[CreatedDate]
           ,[GameExtra]
FROM [dbo].[SoftGamingTransaction_old]
WHERE CreatedDate > '2020-07-01 00:00:00' 
GO

/*
	Insert last month of data
*/

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
DECLARE @CurrentDate AS DATETIME

SET @StartDate = '2020-06-18'
SET @EndDate = '2020-06-20'
SET @CurrentDate = @StartDate

WHILE (@CurrentDate < @EndDate)
BEGIN
    BEGIN
		INSERT INTO [dbo].[SoftGamingTransaction]
				   ([id]
				   ,[MethodId]
				   ,[MemberId]
				   ,[Tid]
				   ,[Currency]
				   ,[Amount]
				   ,[GameId]
				   ,[Extparam]
				   ,[Gamedesc]
				   ,[ActionId]
				   ,[Subtype]
				   ,[RoundInfoActions]
				   ,[Hmac]
				   ,[BlockedBalance]
				   ,[BlockedBonusBalance]
				   ,[BalanceAfter]
				   ,[BonusBalanceAfter]
				   ,[Status]
				   ,[CreatedDate]
				   ,[GameExtra])

		SELECT      [id]
				   ,[MethodId]
				   ,[MemberId]
				   ,[Tid]
				   ,[Currency]
				   ,[Amount]
				   ,[GameId]
				   ,[Extparam]
				   ,[Gamedesc]
				   ,[ActionId]
				   ,[Subtype]
				   ,[RoundInfoActions]
				   ,[Hmac]
				   ,[BlockedBalance]
				   ,[BlockedBonusBalance]
				   ,[BalanceAfter]
				   ,[BonusBalanceAfter]
				   ,[Status]
				   ,[CreatedDate]
				   ,[GameExtra]
		FROM [dbo].[SoftGamingTransaction_old]
		WHERE CreatedDate between @CurrentDate and @CurrentDate + 1;
    END

    SET @CurrentDate = @CurrentDate + 1; /*increment current date*/
END