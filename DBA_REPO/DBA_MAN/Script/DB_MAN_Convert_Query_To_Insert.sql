
drop procedure [DB_MAN_Convert_Query_To_Insert]
go
CREATE PROCEDURE dbo.DB_MAN_Convert_Query_To_Insert (@input NVARCHAR(max), @target NVARCHAR(max)) AS BEGIN

    DECLARE @fields NVARCHAR(max);
    DECLARE @select NVARCHAR(max);

    -- Get the defintion from sys.columns and assemble a string with the fields/transformations for the dynamic query
    SELECT
        @fields = COALESCE(@fields + ', ', '') + '[' + name +']', 
        @select = COALESCE(@select + ', ', '') + ''''''' + ISNULL(CAST([' + name + '] AS NVARCHAR(max)), ''NULL'')+'''''''
    FROM tempdb.sys.columns 
    WHERE [object_id] = OBJECT_ID(N'tempdb..'+@input);

    -- Run the a dynamic query with the fields from @select into a new temp table
    CREATE TABLE #ConvertQueryToInsertTemp (strings nvarchar(max))
    DECLARE @stmt NVARCHAR(max) = 'INSERT INTO #ConvertQueryToInsertTemp SELECT '''+ @select + ''' AS [strings] FROM '+@input
    exec sp_executesql @stmt

    -- Output the final insert statement 
    SELECT 'INSERT INTO ' + @target + ' (' + @fields + ') VALUES (' + REPLACE(strings, '''NULL''', 'NULL') +')' FROM #ConvertQueryToInsertTemp

    -- Clean up temp tables
    DROP TABLE #ConvertQueryToInsertTemp
    SET @stmt = 'DROP TABLE ' + @input
    exec sp_executesql @stmt
END