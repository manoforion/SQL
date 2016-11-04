Create Proc Gen_AuditLevel

AS
BEGIN
	DECLARE @AuditLevel int
	DECLARE @AuditLevel_value int 

	EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE' ,
	   N'Software\Microsoft\MSSQLServer\MSSQLServer',
	   N'AuditLevel', @AuditLevel OUTPUT

	Set @AuditLevel_value = (select dbo.DB_MAN_VALIDATE_CONFIG ('AuditLevel') as validate_config)

	IF @AuditLevel_value >0 --THEN
		UPDATE [DB_MAN].[dbo].[Db_Man_Config]  set Db_Man_Config_Value= CASE WHEN @AuditLevel = 0 THEN 'None'
	   WHEN @AuditLevel = 1 THEN 'Successful logins only'
	   WHEN @AuditLevel = 2 THEN 'Failed logins only'
	   WHEN @AuditLevel = 3 THEN 'Both failed and successful logins' END where Db_Man_Config_Param='AuditLevel'
	else
		insert into [DB_MAN].[dbo].[Db_Man_Config] 
		SELECT 'AuditLevel',CASE WHEN @AuditLevel = 0 THEN 'None'
	   WHEN @AuditLevel = 1 THEN 'Successful logins only'
	   WHEN @AuditLevel = 2 THEN 'Failed logins only'
	   WHEN @AuditLevel = 3 THEN 'Both failed and successful logins'
	   END AS [AuditLevel]

END 

