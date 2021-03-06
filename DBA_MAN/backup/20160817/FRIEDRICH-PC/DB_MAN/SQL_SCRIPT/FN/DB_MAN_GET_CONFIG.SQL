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
CREATE FUNCTION [dbo].[DB_MAN_GET_CONFIG]
(
	@Param varchar(1000) 
)
RETURNS varchar (1000)
	AS
		BEGIN
			declare @Db_Man_Config_Value varchar(1000) 
			Set @Db_Man_Config_Value = (Select [Db_Man_Config_Value] from [DB_MAN].[dbo].[Db_Man_Config] where Db_Man_Config_Param=@Param )
RETURN @Db_Man_Config_Value;
END
