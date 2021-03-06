USE [DB_MAN]
GO
/****** Object:  UserDefinedFunction [dbo].[DB_MAN_File_Exist]    Script Date: 03-08-2016 17:59:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
select [dbo].[DB_MAN_File_Exist]('F:\DBA_MAN\gen_file\test.htm')
*/

ALTER FUNCTION [dbo].[DB_MAN_File_Exist]
	(
		@path varchar(8000)
	)
RETURNS BIT
AS
BEGIN
     DECLARE @result INT
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT
     RETURN cast(@result as bit)
END;
