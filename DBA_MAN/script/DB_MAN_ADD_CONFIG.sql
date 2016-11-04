Create proc DB_MAN_ADD_CONFIG 
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


go


