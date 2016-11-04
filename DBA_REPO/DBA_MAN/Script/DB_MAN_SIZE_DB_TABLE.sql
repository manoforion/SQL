USE [DB_MAN]
GO

DROP TABLE [dbo].[DB_MAN_SIZE_DB_TABLE]
GO


CREATE TABLE [dbo].[DB_MAN_SIZE_DB_TABLE](
	[database_id] [int] NOT NULL,
	[name] [sysname] NOT NULL,
	[state_desc] [nvarchar](60) NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[total_size] [decimal](18, 2) NULL,
	[data_size] [decimal](18, 2) NULL,
	[data_used_size] [decimal](18, 2) NULL,
	[log_size] [decimal](18, 2) NULL,
	[log_used_size] [decimal](18, 2) NULL,
	[full_last_date] [datetime] NULL,
	[full_size] [decimal](18, 2) NULL,
	[log_last_date] [datetime] NULL,
	[log_sized] [decimal](18, 2) NULL
) ON [PRIMARY]

GO


