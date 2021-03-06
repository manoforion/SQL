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
exec [dbo].[DB_MAN_ADD_CONFIG] 'BACKUP_FOLDER','F:\DBA_MAN\backup\'
exec [dbo].[DB_MAN_ADD_CONFIG] 'TMP_MAIL_FILE','F:\DBA_MAN\gen_file\TMP_MAIL_FILE.html'
select * from [dbo].[Db_Man_Config]
*/

create procedure DB_MAN_DB_ALL_BACKUP

as
BEGIN
	DECLARE @name VARCHAR( 50) -- database name
	DECLARE @path VARCHAR( 256) -- path for backup files
	DECLARE @fileName VARCHAR( 256) -- filename for backup
	DECLARE @fileDate VARCHAR( 20) -- used for file name
	declare @temp varchar( 512) -- build temporaly
	DECLARE @name_server varchar( 512) -- server name

	-- specify database backup directory
	SET @path = (select dbo.DB_MAN_GET_CONFIG('BACKUP_FOLDER'))

	SET @name_server = (Select @@SERVERNAME)

	-- specify filename format
	SELECT @fileDate = CONVERT(VARCHAR (20), GETDATE(),112 )
	--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')

				   SET @fileName = @path  + @fileDate + '\'
				   set @temp = 'mkdir ' + @fileName
				   print @fileName
				   EXEC xp_cmdshell @temp ,no_output;

	DECLARE db_cursor CURSOR FOR
	SELECT name FROM sys.databases  WHERE name NOT IN ('master','carga', 'model','msdb' ,'tempdb','ReportServerTempDB','ReportServer')  and [state] <>6 -- exclude these databases

	OPEN db_cursor

	FETCH NEXT FROM db_cursor INTO @name

	WHILE @@FETCH_STATUS = 0
	BEGIN
               
			   
				   set @temp='Backup database '+@name+''
				   exec dbo.DBA_MAN_LOG  @TEMP, 'DT'

				   SET @fileName = @path  + @fileDate + '\'

				   /*
				   SET @fileName = @fileName  + @name_server +'\'
				   set @temp = 'mkdir ' + @fileName
				   print @temp
				   EXEC xp_cmdshell @temp ,no_output;
				   */
				   SET @fileName = @fileName  + @name +'\'
				   set @temp = 'mkdir ' + @fileName
               
				   EXEC xp_cmdshell @temp ,no_output;
				   set @TEMP = 'Gen Path :'+@temp+'' 

				   exec dbo.DBA_MAN_LOG  @TEMP, 'DT'

				   SET @fileName = @fileName + @name + '.BAK'

				   exec DB_MAN_Create_BAK @name,@fileName

			   

		   FETCH NEXT FROM db_cursor INTO @name
	END


	CLOSE db_cursor

	DEALLOCATE db_cursor

END

