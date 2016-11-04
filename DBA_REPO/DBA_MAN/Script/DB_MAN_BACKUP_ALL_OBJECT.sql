drop PROCEDURE [dbo].[DB_MAN_BACKUP_ALL_OBJECT] 
go

/*
EXEC [dbo].[DB_MAN_ADD_CONFIG]  'BACKUP_ALL_OBJECT','F:\DBA_MAN\backup'


select dbo.DB_MAN_GET_CONFIG('BACKUP_FOLDER')

[dbo].[DB_MAN_BACKUP_ALL_OBJECT]  'DB_MAN'
*/

CREATE PROCEDURE [dbo].[DB_MAN_BACKUP_ALL_OBJECT] 
	(	
		@DB_NAME varchar(200),
		@P INT  = 1, 
		@FN INT = 1 , 
		@V INT  = 1
	)
-- backup stored procedure , function y views
AS
BEGIN

SET NOCOUNT ON;

IF OBJECT_ID ('tempdb..#Proc_Def') IS NOT NULL DROP TABLE #Proc_Def
--DROP TABLE #Proc_Def
DECLARE @t TABLE ( Test INT )

declare @temp varchar (2000)
declare @date_backup varchar (20)
declare @path varchar (max )
declare @name_server varchar (100)

DECLARE @retvalue varchar(max)  
DECLARE @ParmDef nvarchar(50);
DECLARE @SQL nvarchar(1000);

set  @name_server= @@SERVERNAME

set @path = (select [dbo].[DB_MAN_GET_CONFIG] ('BACKUP_ALL_OBJECT'))

SELECT @date_backup = CONVERT( VARCHAR(20 ),GETDATE(), 112)

declare @sqlstatement nvarchar(1000)


--set @vsql = 'set @cursor = cursor forward_only static for ' + @vquery + ' open @cursor;'

set @sqlstatement = 'set @cursor = cursor forward_only static for (
             SELECT  [name], [type] FROM '+@DB_NAME+'.Sys.objects  WHERE
                   (
                   '+cast(@FN as varchar(1))+' =1 AND type in ( N''FN'', N''IF'', N''TF'', N''FS'', N''FT'')
                   OR
                   '+cast(@P as varchar(1))+' =1 AND type IN ( N''P'', N''PC'')
                   OR
                   '+cast(@V as varchar(1))+' =1 AND type IN ( N''V'')
                   )
                   AND name NOT LIKE ''%sp_MSdel%'' --exclude replication procs
                   AND name NOT LIKE ''%sp_MSins%''
                   AND name NOT LIKE ''%sp_MSupd%''
       )
	   open @cursor;
	   '

--exec sys.sp_executesql @sqlstatement
declare @objcursor as cursor 
exec sys.sp_executesql @sqlstatement
	,N'@cursor cursor output'	
	,@objcursor output

Declare @ID NVARCHAR ( MAX )
Declare @WI varchar (10 )

set @temp = @path + @date_backup +'\'
       set @temp = 'mkdir ' + @temp
       
       EXEC xp_cmdshell @temp ,no_output ;

set @temp = @path + @date_backup +'\'+ @name_server+'\'
       set @temp = 'mkdir ' + @temp
       
       EXEC xp_cmdshell @temp ,no_output ;

set @temp = @path + @date_backup +'\'+ @name_server+'\'+@DB_NAME+'\'
       set @temp = 'mkdir ' + @temp
       
       EXEC xp_cmdshell @temp ,no_output ;

set @temp = @path + @date_backup +'\'+ @name_server+'\'+@DB_NAME+'\SQL_SCRIPT\'
       set @temp = 'mkdir ' + @temp
       
       EXEC xp_cmdshell @temp ,no_output ;

set @path = @path + @date_backup +'\'+ @name_server+'\'+@DB_NAME+'\SQL_SCRIPT\'

CREATE TABLE #Proc_Def (Def TEXT)

     fetch next from @objcursor into @ID, @WI
     while @@fetch_status = 0
             BEGIN
                    truncate table #Proc_Def
					
					declare @TMP nvarchar(1000)
					SET @TMP = 'INSERT #Proc_Def SELECT definition FROM '+@DB_NAME+'.sys .sql_modules sm WITH ( NOLOCK ) LEFT JOIN '+@DB_NAME+'.sys. objects so ON so.object_id = sm. object_id  WHERE so .name = '''+@ID+''''
                  --  select * from #Proc_Def
					EXECUTE sp_executesql @statement=@TMP

					--EXEC sys.sp_helptext @objname = @ID
                    INSERT #Proc_Def SELECT       'go'
                    set @temp = @path + @WI
                    set @temp = 'mkdir ' + @temp
                    EXEC xp_cmdshell @temp ,no_output ;
                    set @WI = replace( @WI,' ' ,'')
                    set @temp = @path +'\' +@WI+ '\'+@ID +'.SQL'
					
					SELECT @SQL	= N'SELECT @retvalOUT =definition FROM '+@DB_NAME+'.sys.sql_modules sm WITH ( NOLOCK ) LEFT JOIN '+@DB_NAME+'.sys. objects so ON so.object_id = sm. object_id  WHERE so .name = '''+@ID+''''
					SET @ParmDef	= N'@retvalOUT varchar(max) OUTPUT';
					
					EXEC sp_executesql @SQL, @ParmDef, @retvalOUT=@retvalue OUTPUT;
					
					declare @SIGNATURE varchar(1000)
					set @SIGNATURE = '/*'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '____________ ___  ___  ___   _   _	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '|  _  \ ___ \|  \/  | / _ \ | \ | |	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '| | | | |_/ /| .  . |/ /_\ \|  \| |	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '| | | | ___ \| |\/| ||  _  || . ` |	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '| |/ /| |_/ /| |  | || | | || |\  |	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '|___/ \____/ \_|  |_/\_| |_/\_| \_/	'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '         ______						'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '        |_2016_|						'+ CHAR(13)+CHAR(10)
					set @SIGNATURE = @SIGNATURE + '*/'+ CHAR(13)+CHAR(10)
					set @retvalue = @SIGNATURE + @retvalue
					EXEC [DB_MAN_WriteStringToFile] @retvalue,@temp 
					fetch next from @objcursor into @ID, @WI
       END
close @objcursor


SET NOCOUNT OFF;
END



/*
EXEC [dbo].[DB_MAN_ADD_CONFIG]  'BACKUP_ALL_OBJECT','F:\DBA_MAN\backup'


select dbo.DB_MAN_GET_CONFIG('BACKUP_FOLDER')

[dbo].[DB_MAN_BACKUP_ALL_OBJECT]  'DB_MAN'
*/
