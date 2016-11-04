
  IF object_id(N'DB_MAN_VALIDATE_CONFIG', N'FN') IS NOT NULL
    DROP FUNCTION DB_MAN_VALIDATE_CONFIG
  GO	
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