

USE [DB_MAN]
GO
/****** Object:  StoredProcedure [dbo].[DBA_MAN_LOG]    Script Date: 02-08-2016 15:17:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DBA_MAN_LOG] (
    @Msg VARCHAR(2048),
  	@Option VARCHAR(100) = '',
	@category varchar(100) = 'Default',
	@status int =0,
    @Separator VARCHAR(10) = '-'
    )
/*
@Option is a string containing possible values as B,A,D,T
if you want to print separator before message, include B
if you want to print separator after message, include A
if you want to print date, include D
if you want to print time, include T
Sample: 'BAD'

select * from DBA_MAN_TABLE_LOG order by id_log_table desc

The order of characters does not matter. it is not case sensitive

Usage:
	exec dbo.DBA_MAN_LOG 'Dated Log', 'DT'
	exec dbo.DBA_MAN_LOG 'Dated Log', 'DT','Category'
	exec dbo.DBA_MAN_LOG 'Dated Log', 'DT','Category',777
    exec dbo.DBA_MAN_LOG 'Timed Log', 'T','Category',777
    exec dbo.DBA_MAN_LOG 'Dated Log', 'D','Category',777
    exec dbo.DBA_MAN_LOG 'With Separator and Time', 'BT','Category',777, '-'
    exec dbo.DBA_MAN_LOG 'With Separator and Date', 'BAD','Category',777, '*'
    exec dbo.DBA_MAN_LOG 'With Separator and DateTime', 'BADT','Category',777, '-'
*/
AS
BEGIN
	set nocount on
    declare @tempStr varchar(100)
    set @tempStr = replicate(@Separator, 50)
    IF charindex('B', upper(@Option)) > 0
        raiserror (@tempStr, 10, 1) with nowait

    DECLARE @prompt VARCHAR(max) = ''

    IF charindex('D', upper(@Option)) > 0
        SET @prompt = convert(VARCHAR, SysDatetime(), 101) + ' '

    IF charindex('T', upper(@Option)) > 0
        SET @prompt = @prompt + convert(VARCHAR, SysDatetime(), 108) + ' '
    
	SET @prompt = @prompt + @Msg

    raiserror (@prompt, 10, 1) with nowait

    set @tempStr = replicate(@Separator, 50)
    IF charindex('A', upper(@Option)) > 0
        raiserror (@tempStr, 10, 1) with nowait
	--Register into DBA_MAN_TABLE_LOG
		insert into DBA_MAN_TABLE_LOG 	values(convert(VARCHAR, SysDatetime(), 101),convert(VARCHAR, SysDatetime(), 108),@Msg,@category,@status)
    RETURN
END

