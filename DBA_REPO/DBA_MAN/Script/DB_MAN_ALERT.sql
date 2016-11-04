/****** Object:  Table [dbo].[DB_MAN_ALERT]    Script Date: 01-08-2016 12:15:44 ******/
DROP TABLE [dbo].[DB_MAN_ALERT]
GO

CREATE TABLE [dbo].[DB_MAN_ALERT](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[id_db] [int] NULL,
	[Db_Name] [varchar](1000) NULL,
	[action] [varchar](1000) NOT NULL,
	[Value] [varchar](1000) NULL,
	[registry] [varchar](1000) NULL,
	[alert] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


