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
	exec DB_MAN_Change_Owner 'matrix','comexin','dbo'
	use matrix; EXEC sp_changeobjectowner 'db_owner.clientes', 'dbo'
*/

CREATE PROCEDURE [dbo].[DB_MAN_Change_Owner] 
	(
		@db_name varchar(100),
		@currentOwner varchar(100),
		@newOwner varchar(50)
	)
AS
BEGIN
	DECLARE @currentObject nvarchar(517)
	DECLARE @qualifiedObject nvarchar(517)

	DECLARE @TEMP nvarchar(1000)
	DECLARE @TMP nvarchar(1000)

	DECLARE @ResultString NVARCHAR(MAX)
	DECLARE @Qry NVARCHAR(MAX)  


	--DECLARE alterOwnerCursor CURSOR FOR
	--SELECT [name]   FROM dbo.sysobjects WHERE xtype in ('FN','IF','P','TF','U','V', 'TT', 'TF') and USER_NAME(uid)=@currentOwner
	
	declare @sqlstatement nvarchar(1000)

	set @sqlstatement = 'set @cursor = cursor forward_only static for 
						(
						SELECT [name] FROM '+@db_name+'.dbo.sysobjects WHERE xtype in (''FN'',''IF'',''P'',''TF'',''U'',''V'', ''TT'', ''TF'') and USER_NAME(uid)='''+@currentOwner+'''	
						)
						open @cursor;
						'
	--declare @objcursor as cursor 
	print @sqlstatement
	declare @objcursor as cursor 
	exec sys.sp_executesql @sqlstatement ,N'@cursor cursor output',@objcursor output

	--OPEN alterOwnerCursor
	FETCH NEXT FROM @objcursor INTO @currentObject
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   SET @qualifiedObject = CAST(@currentOwner as varchar) + '.' + CAST(@currentObject as varchar)
	
		SET @TMP = 'USE ' + @db_name + ';EXEC sp_changeobjectowner  '''+@qualifiedObject+''','''+@newOwner+''';USE DB_MAN'
		PRINT (@TMP) 
		EXECUTE(@TMP) 
	    
		--EXEC sp_changeobjectowner @qualifiedObject, @newOwner 
	   

	   --print 'use '+@db_name+'; EXEC sp_changeobjectowner '+@TMP+', '+@newOwner+'; use DB_MAN;'
	   SET @TEMP = ' --- Executing '+@TMP
	   	   
	   exec dbo.DB_MAN_LOG @Msg=@TEMP, @Option='DT',@category='DBA_TOOLS',@status=0,@Separator='-'

	   --select @qualifiedObject, @newOwner
	   FETCH NEXT FROM @objcursor INTO @currentObject
	END
	CLOSE @objcursor
	DEALLOCATE @objcursor
END 







