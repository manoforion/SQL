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
CREATE PROCEDURE DB_MAN_ALL_TO_DBO 

AS
BEGIN
	DECLARE cursore CURSOR FOR 


	select specific_schema as 'schema', specific_name AS 'name'
	FROM INFORMATION_SCHEMA.routines
	WHERE specific_schema <> 'dbo' 

	UNION ALL

	SELECT TABLE_SCHEMA AS 'schema', TABLE_NAME AS 'name'
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA <> 'dbo' 



	DECLARE @schema sysname, 
	 @tab sysname, 
	 @sql varchar(500) 


	OPEN cursore     
	FETCH NEXT FROM cursore INTO @schema, @tab 

	WHILE @@FETCH_STATUS = 0     
	BEGIN 
	 SET @sql = 'ALTER SCHEMA dbo TRANSFER [' + @schema + '].[' + @tab +']'    
	 PRINT @sql   
	 exec (@sql)  
	 FETCH NEXT FROM cursore INTO @schema, @tab     
	END 

	CLOSE cursore     
	DEALLOCATE cursore
END