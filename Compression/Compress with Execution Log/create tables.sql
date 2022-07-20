<<<<<<< HEAD
USE [DBDBA]
GO

/****** Object:  Table [dbo].[log_compress_indexes]    Script Date: 17/05/2021 17:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_compress_indexes](
	[ObjectName] [sysname] NULL,
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[ObjectType] [varchar](5) NOT NULL,
	[Command] [nvarchar](864) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[log_compress_tables]    Script Date: 17/05/2021 17:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_compress_tables](
	[ObjectName] [sysname] NOT NULL,
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[ObjectType] [varchar](5) NOT NULL,
	[Command] [nvarchar](180) NOT NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO

=======
USE [DBDBA]
GO

/****** Object:  Table [dbo].[log_compress_indexes]    Script Date: 17/05/2021 17:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_compress_indexes](
	[ObjectName] [sysname] NULL,
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[ObjectType] [varchar](5) NOT NULL,
	[Command] [nvarchar](864) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[log_compress_tables]    Script Date: 17/05/2021 17:10:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[log_compress_tables](
	[ObjectName] [sysname] NOT NULL,
	[SchemaName] [nvarchar](128) NULL,
	[TableName] [nvarchar](128) NULL,
	[ObjectType] [varchar](5) NOT NULL,
	[Command] [nvarchar](180) NOT NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL
) ON [PRIMARY]
GO

>>>>>>> d4022b1c698892c56d61a9072b03678cdc0fa4fe
