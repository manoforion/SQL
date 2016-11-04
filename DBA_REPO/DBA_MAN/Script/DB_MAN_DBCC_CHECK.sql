IF object_id('DB_MAN_DBCC_CHECK') IS not NULL
    drop procedure DB_MAN_DBCC_CHECK
GO
--select * from [dbo].[DB_MAN_ALERT]
Create Procedure DB_MAN_DBCC_CHECK
	
AS 
BEGIN
	SET NOCOUNT ON;
	DBCC TRACEON (3604);


	CREATE TABLE #temp (
			Id INT IDENTITY(1,1), 
			--id INT ,
			ParentObject VARCHAR(255),
			[Object] VARCHAR(255),
			Field VARCHAR(255),
			[Value] VARCHAR(255)
	)

	CREATE TABLE #Results (
			ID int,
			DBName VARCHAR(255),
			LastGoodDBCC datetime,
			Diferency varchar(100),
			Alert int 
	)

	DECLARE @Name VARCHAR(255);

	DECLARE looping_cursor CURSOR
	FOR

	SELECT name FROM master.dbo.sysdatabases WHERE CONVERT(varchar(500),databasepropertyex(name, 'Status'),0) = 'ONLINE' /*and name='DBA_REPO'*/

	OPEN looping_cursor
	FETCH NEXT FROM looping_cursor INTO @Name
	WHILE @@FETCH_STATUS = 0
		BEGIN

			truncate table #temp

			INSERT INTO #temp
			EXECUTE('DBCC DBINFO (['+@Name+']) WITH TABLERESULTS');
        
			INSERT INTO #Results
			SELECT db_id(@Name) as [db_id],@Name,VALUE ,case ISNULL(value,'1900-01-01 00:00:00.000')
				WHEN '1900-01-01 00:00:00.000' Then 'Never'
				ELSE 
					CAST(DATEDIFF(month, ISNULL(value,'1900-01-01 00:00:00.000'), getdate()) AS NVARCHAR(50)) + ' Month(s)'
				End Diferency,''
			FROM #temp
			WHERE Field = 'dbi_dbccLastKnownGood';

		FETCH NEXT FROM looping_cursor INTO @Name
		END
	CLOSE looping_cursor;
	DEALLOCATE looping_cursor;

	update #Results set alert= case Diferency when 'Never' then 3 when '0 Month(s)' then 1 else 2 end 

	delete from [DB_MAN].[dbo].[DB_MAN_ALERT] where [action] ='dbcc checkdb'
	insert into [DB_MAN].[dbo].[DB_MAN_ALERT] 
	select id as id_db,DBName,'dbcc checkdb' as [action] ,convert(nvarchar(MAX), LastGoodDBCC, 120) as [Value], Diferency as [registry],alert 
	--into [DB_MAN].[dbo].[DB_MAN_ALERT]
	FROM #Results

	DROP TABLE #temp
	DROP TABLE #Results
END

--DBCC CHECKDB('3GatewayOut') WITH NO_INFOMSGS
--DBCC DBINFO ('DBA_REPO') WITH TABLERESULTS
--DBCC PAGE ('3GatewayOut', 1, 9, 3)WITH TABLERESULTS
