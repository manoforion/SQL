/*
____________ ___  ___  ___   _   _	
|  _  \ ___ \|  \/  | / _ \ | \ | |	
| | | | |_/ /| .  . |/ /_\ \|  \| |	
| | | | ___ \| |\/| ||  _  || . ` |	
| |/ /| |_/ /| |  | || | | || |\  |	
|___/ \____/ \_|  |_/\_| |_/\_| \_/	
         ______						
        |_2016_|						
*/
/*
	exec DB_MAN_Create_BAK 'friedrich','f:\DBA_MANxxxxxx\backup\friedrich.bak'
	select  * from [dbo].[DBA_MAN_TABLE_LOG] order by id_log_table 
*/

CREATE Procedure [dbo].[DB_MAN_Create_BAK]
	(
		@DB_NAME as varchar(1000),
		@DB_PATH as varchar(1000)
	)
as
BEGIN
	set nocount on
	declare @result varchar(1000)
	declare @begintime datetime
	declare @SQL nvarchar(max)
	declare @databasename varchar(1000)
	Declare @temp varchar(1000)

	set @sql='BACKUP DATABASE '+@DB_NAME+' TO DISK = '''+@DB_PATH+''''

	--print @sql

	IF OBJECT_ID('tempdb.dbo.#Results') IS NOT NULL DROP TABLE #Results
	CREATE TABLE #Results 
		(
			LogDate datetime,
			ProcessInfo nvarchar(100),
			LogText nvarchar(4000)
		)
	BEGIN TRY
	
		SELECT @begintime = GETDATE()
		EXEC sp_executesql @SQL --your backup statement string
	
		INSERT #Results EXEC  xp_readerrorlog 0, 1, N'backed up',@databasename,@begintime
	
		SELECT @result = LogText from #Results where ProcessInfo = 'Backup' order by logdate desc
		
		Set @TEMP = 'Backup Database '+@DB_NAME+' is OK'
		Exec dbo.DBA_MAN_LOG  @TEMP, 'DT','Backup',1

		set @temp='Gen Backup '+ @DB_NAME +' into ' + @DB_PATH
		exec dbo.DBA_MAN_LOG  @TEMP, 'DT','Backup',1

	END TRY

	BEGIN CATCH
		INSERT #Results EXEC  xp_readerrorlog 0, 1, N'Backup',@databasename,@begintime
		
		SELECT @result = LogText from #Results where ProcessInfo = 'spid'+cast(@@SPID as varchar(6)) order by logdate desc
		
		Set @TEMP = 'Backup Database '+@DB_NAME+' Failed'
		Exec dbo.DBA_MAN_LOG  @TEMP, 'DT','Backup',3
	END CATCH

	--select @result
	
	--select * from #results
end 





