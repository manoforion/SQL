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
  CREATE FUNCTION DB_MAN_VALIDATE_CONFIG
	(
		@Param varchar(1000) 
		
	)
  RETURNS int
  AS
  BEGIN
	declare @Param_value int
	Set @Param_value = (Select count(*) from [DB_MAN].[dbo].[Db_Man_Config] where Db_Man_Config_Param=@Param )
			



  RETURN @Param_value;
  END
