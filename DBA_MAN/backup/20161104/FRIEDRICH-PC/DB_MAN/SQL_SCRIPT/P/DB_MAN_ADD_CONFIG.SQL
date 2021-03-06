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
EXEC [dbo].[DB_MAN_ADD_CONFIG]  'BACKUP_ALL_OBJECT','F:\DBA_MAN\backup'
*/

CREATE proc [dbo].[DB_MAN_ADD_CONFIG] 
(
	@Param varchar(1000),
	@ValueParam varchar(1000)
)
AS
	BEGIN
		--validate first
		declare @validate int 
		set @validate =(select dbo.DB_MAN_VALIDATE_CONFIG (@Param) as validate_config)
	
		if @validate>0 --then
			UPDATE [DB_MAN].[dbo].[Db_Man_Config]  set Db_Man_Config_Value=@ValueParam  where Db_Man_Config_Param=@Param
		else
			insert into [DB_MAN].[dbo].[Db_Man_Config] values (@Param,@ValueParam ) 
	END


