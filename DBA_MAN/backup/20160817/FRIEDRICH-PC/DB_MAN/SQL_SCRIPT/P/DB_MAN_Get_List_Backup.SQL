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
Create Proc DB_MAN_Get_List_Backup
	
As
	BEGIN
		SET DATEFORMAT ymd;
		create table #table 
			(
				id_db int
				,[DB_Name] varchar(1000)
				,[action] varchar(1000)
				,[value] datetime
				,[registry] varchar(1000)
				,[alert] int

			)

		insert into #table 
		SELECT	db_id(sdb.Name) as [id_db]
		,sdb.Name AS [DB_Name]
		,'Backup database' as [action]
		,ISNULL(bus.backup_finish_date,'1900-01-01 00:00:00.000') as Value
		--,bus.backup_finish_date
		,	CASE ISNULL(bus.backup_finish_date,'1900-01-01 00:00:00.000')
			WHEN '1900-01-01 00:00:00.000' Then 'Never'
			ELSE 
				CAST(DATEDIFF(day, ISNULL(bus.backup_finish_date,'1900-01-01 00:00:00.000'), getdate()) AS NVARCHAR(50)) + ' day(s)'
			End as [registry]
			,0
		FROM sys.sysdatabases sdb 
		LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
		GROUP BY sdb.Name,bus.backup_finish_date

		

		update #table set value=convert(nvarchar(MAX), value, 120), alert= case [registry] when 'Never' then 3 when '0 day(s)' then 1 else 2 end 
		--select *,cast(value as varchar(1000)),convert(nvarchar(MAX), value, 120) from #table
		delete from [DB_MAN].[dbo].[DB_MAN_ALERT] where [action] ='Backup database'
		insert into [DB_MAN].[dbo].[DB_MAN_ALERT]

		select id_db,[db_Name],[action],convert(nvarchar(MAX), value, 120) as [value],registry,alert from #table 

	END 

