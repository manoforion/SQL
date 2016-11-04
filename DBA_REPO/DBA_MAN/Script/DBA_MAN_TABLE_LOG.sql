CREATE TABLE [dbo].[DBA_MAN_TABLE_LOG](
	[Id_Log_Table] [int] IDENTITY(1,1) NOT NULL,
	[Date_Log] [date] NOT NULL,
	[Hour_Log] [time](7) NOT NULL,
	[Message] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


