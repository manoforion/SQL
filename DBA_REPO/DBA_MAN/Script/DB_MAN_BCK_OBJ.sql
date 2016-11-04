drop PROCEDURE [dbo].[DB_MAN_BCK_OBJ] 

go
/*
Exec [dbo].[DB_MAN_BCK_OBJ] 'F:\DBA_MAN\backup\',1,1,1
*/

CREATE PROCEDURE [dbo].[DB_MAN_BCK_OBJ] 
	(
		@path varchar (max ),
		@P INT , 
		@FN INT , 
		@V INT,
		@Svr_Name varchar(1000) = 'N'
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

declare @name_server varchar (100)

IF @Svr_Name='Y' --THEN
	set  @name_server= @@SERVERNAME
--END IF


SELECT @date_backup = CONVERT( VARCHAR(20 ),GETDATE(), 112)

declare c cursor local for
       (
             SELECT  [DB_MAN_CATALOG_OBJET], [type] FROM Sys .objects  WHERE
                   (
                   @FN =1 AND type in ( N'FN', N'IF', N'TF', N'FS', N'FT')
                   OR
                   @P =1 AND type IN ( N'P', N'PC')
                   OR
                   @V =1 AND type IN ( N'V')
                   )
                   AND name NOT LIKE '%sp_MSdel%' --exclude replication procs
                   AND name NOT LIKE '%sp_MSins%'
                   AND name NOT LIKE '%sp_MSupd%'
       )
Declare @ID NVARCHAR ( MAX )
Declare @WI varchar (10 )

set @temp = @path + @date_backup +'\'
       set @temp = 'mkdir ' + @temp
       print @temp
       EXEC xp_cmdshell @temp ,no_output ;

IF @Svr_Name='Y' --THEN
	BEGIN
		set @temp = @path + @date_backup +'\'+ @name_server+'\'
			   set @temp = 'mkdir ' + @temp
			   print @temp
			   EXEC xp_cmdshell @temp ,no_output ;


		set @temp = @path + @date_backup +'\'+ @name_server+'\SQL_SCRIPT\'
			   set @temp = 'mkdir ' + @temp
			   print @temp
			   EXEC xp_cmdshell @temp ,no_output ;

		set @path = @path + @date_backup +'\'+ @name_server+'\SQL_SCRIPT\'
	END
ELSE
	BEGIN
		set @temp = @path + @date_backup +'\SQL_SCRIPT\'
			   set @temp = 'mkdir ' + @temp
			   print @temp
			   EXEC xp_cmdshell @temp ,no_output ;

		set @path = @path + @date_backup +'\SQL_SCRIPT\'
	END


CREATE TABLE #Proc_Def (Def TEXT)
Open c
     fetch next from c into @ID, @WI
     while @@fetch_status = 0
             BEGIN
                    truncate table #Proc_Def
                               INSERT #Proc_Def SELECT definition FROM sys .sql_modules sm WITH ( NOLOCK ) LEFT JOIN sys. objects so ON so.object_id = sm. object_id  WHERE so .name = @ID
                    --EXEC sys.sp_helptext @objname = @ID
                    INSERT #Proc_Def SELECT       'GO'
                    --Print OBJECT_DEFINITION(@ID))+' GO'
                    --PRINT @ID
                               set @temp = @path + '\' + @WI
                               set @temp = 'mkdir ' + @temp
                               print @temp
                               EXEC xp_cmdshell @temp ,no_output ;
                               set @WI = replace( @WI,' ' ,'')
                               set @temp = @path +'\' +@WI+ '\'+@ID +'.SQL'
                               print @temp
                               --select * from #Proc_Def
                               set @temp = 'BCP "SELECT * FROM vitamina.dbo.#Proc_Def" queryout "'+ @temp+'" -c -T'
                               EXEC XP_cmdshell   @temp ,no_output


     fetch next from c into @ID, @WI
       END
close c

-- SELECT * FROM #Proc_Def
--DROP TABLE #Proc_Def
SET NOCOUNT OFF;

END