

exec DB_MAN_RecoverDeletedRecord 'DB_MAN_ALERT'
go
CREATE PROCEDURE [dbo].[DB_MAN_RecoverDeletedRecord] (
       @TableName SYSNAME
       ,@RollbackPoint DATETIME = NULL
       )
AS
BEGIN
       SET NOCOUNT ON

       DECLARE @AllocationUnitID AS BIGINT
       DECLARE @TotalColumn AS SMALLINT
       DECLARE @TotalFLC AS SMALLINT
       DECLARE @TotalVLC AS SMALLINT
       DECLARE @TotalFLC_Length AS SMALLINT
       DECLARE @FetchData AS VARCHAR(MAX)
       DECLARE @BlobData AS BIT = 0
       DECLARE @VSP AS VARCHAR(MAX)
       DECLARE @VL AS INT

       BEGIN TRY
              --Getting allocationunit id of table
              SELECT @AllocationUnitID = AU.allocation_unit_id
              FROM sys.allocation_units AU
              INNER JOIN sys.partitions P ON P.hobt_id = AU.container_id
              WHERE P.object_id = OBJECT_ID(@TableName)
                     AND AU.type = 1

              --Information about table
              SELECT @TotalColumn = COUNT(*)
                     ,@TotalFLC = ISNULL(COUNT(CASE
                                         WHEN user_type_id NOT IN (
                                                       34
                                                       ,35
                                                       ,98
                                                       ,99
                                                       ,128
                                                       ,129
                                                       ,130
                                                       ,165
                                                       ,167
                                                       ,231
                                                       ,241
                                                       ,256
                                                       ) --Image,text,sql_variant,ntext,hirarchyid,geometry,geography,varbinary,varchar,nvarchar,xml,sysname
                                                THEN 1
                                         END), 0)
                     ,@TotalVLC = ISNULL(COUNT(CASE
                                         WHEN user_type_id IN (
                                                       34
                                                       ,35
                                                       ,98
                                                       ,99
                                                       ,128
                                                       ,129
                                                       ,130
                                                       ,165
                                                       ,167
                                                       ,231
                                                       ,241
                                                       ,256
                                                       )
                                                THEN 1
                                         END), 0)
                     ,@TotalFLC_Length = ISNULL(SUM(CASE
                                         WHEN user_type_id NOT IN (
                                                       34
                                                       ,35
                                                       ,98
                                                       ,99
                                                       ,128
                                                      ,129
                                                       ,130
                                                       ,165
                                                       ,167
                                                       ,231
                                                       ,241
                                                       ,256
                                                       )
                                                THEN max_length
                                         END), 0)
              FROM sys.columns
              WHERE object_id = OBJECT_ID(@TableName);

              WITH cteFC
              AS (
                     SELECT column_id
                           ,max_length
                           ,user_type_id
                           ,precision
                           ,scale
                           ,NAME
                     FROM sys.columns
                     WHERE user_type_id NOT IN (
                                  34
                                  ,35
                                  ,98
                                  ,99
                                  ,128
                                  ,129
                                  ,130
                                  ,165
                                  ,167
                                  ,231
                                  ,241
                                  ,256
                                  )
                           AND object_id = OBJECT_ID(@TableName)
                     )
                     ,cteFCR
              AS (
                     SELECT TOP (100) PERCENT P.column_id
                           ,SUM(C.max_length) AS StartPoint
                     FROM cteFC C
                     INNER JOIN cteFC P ON C.column_id <= P.column_id
                     GROUP BY p.column_id
                     ORDER BY column_id
                     )
              SELECT C.column_id CI
                     ,cast((C.StartPoint - P.max_length) + 1 AS VARCHAR) SP
                     ,cast(P.max_length AS VARCHAR) ML
                     ,cast(P.user_type_id AS VARCHAR) AS UTI
                     ,cast(precision AS VARCHAR) AS P
                     ,cast(scale AS VARCHAR) AS S
                     ,QUotename(NAME) AS N
                     ,cast(0 AS VARCHAR) AS SE
              INTO #FLC
              FROM cteFCR C
              INNER JOIN cteFC P ON C.column_id = P.column_id;

              INSERT INTO #FLC
              SELECT column_id
                     ,0
                     ,max_length
                     ,user_type_id
                     ,precision
                     ,scale
                     ,QUotename(NAME) AS N
                     ,ROW_NUMBER() OVER (
                           ORDER BY column_id
                           )
              FROM sys.columns
              WHERE user_type_id IN (
                           34
                           ,35
                           ,98
                           ,99
                           ,128
                           ,129
                           ,130
                           ,165
                           ,167
                           ,231
                           ,241
                           ,256
                           )
                     AND object_id = OBJECT_ID(@TableName);

              SET @FetchData =
                     'WITH Converter (
                     hex
                     ,bin
                     )
              AS (
                     SELECT ''0''
                           ,''0000''
                    
                     UNION ALL
                    
                     SELECT ''1''
                           ,''0001''
                    
                     UNION ALL
                    
                     SELECT ''2''
                           ,''0010''
                    
                     UNION ALL
                    
                     SELECT ''3''
                           ,''0011''
                    
                     UNION ALL
                    
                     SELECT ''4''
                           ,''0100''
                    
                     UNION ALL
                    
                     SELECT ''5''
                           ,''0101''
                    
                     UNION ALL
                    
                     SELECT ''6''
                           ,''0110''
                    
                     UNION ALL
                    
                     SELECT ''7''
                           ,''0111''
                    
                     UNION ALL
                    
                     SELECT ''8''
                           ,''1000''
                    
                     UNION ALL
                    
                     SELECT ''9''
                           ,''1001''
                    
                     UNION ALL
                    
                     SELECT ''A''
                           ,''1010''
                    
                     UNION ALL
                    
                     SELECT ''B''
                           ,''1011''
                    
                     UNION ALL
                    
                     SELECT ''C''
                           ,''1100''
                    
                     UNION ALL
                    
                     SELECT ''D''
                           ,''1101''
                    
                     UNION ALL
                    
                     SELECT ''E''
                           ,''1110''
                    
                     UNION ALL
                    
                     SELECT ''F''
                           ,''1111''
                     )
                     ,N1 (n)
              AS (
                     SELECT 1
                    
                     UNION ALL
                    
                     SELECT 1
                     )
                     ,N2 (n)
              AS (
                     SELECT 1
                     FROM N1 AS X
                           ,N1 AS Y
                     )
                     ,N3 (n)
              AS (
                     SELECT 1
                     FROM N2 AS X
                           ,N2 AS Y
                     )
                     ,N4 (n)
              AS (
                     SELECT ROW_NUMBER() OVER (
                                  ORDER BY X.n
                                  )
                     FROM N3 AS X
                           ,N3 AS Y
                     )
                     ,cteTL
              AS (
                     SELECT BL.[Transaction ID]
                           ,BL.[RowLog Contents 0] AS LG
                           ,S.[Transaction Name]
                           ,BL.[Transaction ID] TID
                           ,S.[Begin Time]
                           ,CONVERT(VARCHAR, SUBSTRING(BL.[RowLog Contents 0], 1, 2), 2) PageType
                           ,CONVERT(VARCHAR, SUBSTRING(BL.[RowLog Contents 0], 3, 2), 2) NullBitMask
                           ,SUBSTRING(BL.[RowLog Contents 0], 5, '
                     + CAST(@TotalFLC_Length AS VARCHAR) + ') FLC
                           ,CONVERT(VARCHAR, SUBSTRING(BL.[RowLog Contents 0], 5 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ', 2), 2) TotalColumn
                           ,CONVERT(VARCHAR, SUBSTRING(BL.[RowLog Contents 0], 7 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ', CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0)), 2) NullColumn
                          
                           ,REVERSE((
                                  SELECT REPLACE(SUBSTRING( CONVERT(VARCHAR(8000),    cast(reverse(SUBSTRING(BL.[RowLog Contents 0], 7 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ', CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0))) as binary(' + cast(CEILING(@TotalColumn / 8.0) AS VARCHAR) + '))  , 2), n, 1), hex, bin)
                                  FROM N4 AS Nums
                                  JOIN Converter AS C ON SUBSTRING(CONVERT(VARCHAR(8000),    cast(reverse(SUBSTRING(BL.[RowLog Contents 0], 7 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ', CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0))) as binary(' + cast(CEILING(@TotalColumn / 8.0) AS VARCHAR) +
                     '))    , 2), n, 1) = hex
                                  WHERE n <= LEN(CONVERT(VARCHAR(8000),     cast(reverse(SUBSTRING(BL.[RowLog Contents 0], 7 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ', CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0)) ) as binary(' + cast(CEILING(@TotalColumn / 8.0) AS VARCHAR) + '))     , 2))
                                  FOR XML PATH('''')
                                  )) AS NullBinary


                           ,CAST(CAST(REVERSE(SUBSTRING(BL.[RowLog Contents 0], 3, 2)) AS BINARY (2)) AS SMALLINT) + CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0) VLC
                    
                           ,convert(VARCHAR, cast(REVERSE(cast(cast(CAST(CAST(REVERSE(SUBSTRING(BL.[RowLog Contents 0], 3, 2)) AS BINARY (2)) AS SMALLINT) + CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0) + 2 * (2 + ' + CAST(@TotalVLC AS VARCHAR) + ') AS SMALLINT) AS VARBINARY(2))) AS BINARY (2)), 2) + CONVERT(VARCHAR(8000), SUBSTRING(BL.[RowLog Contents 0], 9 + ' + CAST(@TotalFLC_Length AS VARCHAR) + ' + CEILING(' + CAST(@TotalColumn AS VARCHAR) + ' / 8.0), 2 * ' + CAST(@TotalVLC AS VARCHAR) +
                     '), 2) VLO
                          
                     FROM sys.fn_dblog(NULL, NULL) BL
                     INNER JOIN sys.fn_dblog(NULL, NULL) S ON BL.[Transaction ID] = S.[Transaction ID]
                     WHERE BL.AllocUnitId = ' + CAST(@AllocationUnitID AS VARCHAR) + '
                           AND BL.Operation IN (''LOP_DELETE_ROWS'')
                           AND S.Operation = ''LOP_BEGIN_XACT''
                           AND S.[Begin Time] <= ''' + CONVERT(VARCHAR, ISNULL(@RollbackPoint, GETDATE()), 127) + '''
                     ) SELECT '

              SELECT @VSP = CASE
                           WHEN @BlobData = 0
                                  AND UTI IN (
                                         34
                                         ,35
                                         ,98
                                         ,99
                                         ,128
                                         ,129
                                         ,130
                                         ,165
                                         ,167
                                         ,231
                                         ,241
                                         ,256
                                         )
                                  THEN 'CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO,(' + SE + ' - 1) * 4 + 1 ,4),2)) AS BINARY(2)) AS INT)'
                           ELSE @VSP
                           END
                     ,@FetchData += 'CASE
              WHEN SUBSTRING(NullBinary, ' + cast(CI AS VARCHAR) + ', 1) = 1
                     THEN NULL
              ELSE ' + CASE UTI
                           WHEN 36 --uniqueidentifier
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS UNIQUEIDENTIFIER)'
                           WHEN 40 --date
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS DATE)'
                           WHEN 41 --time
                                  THEN 'CAST(0x07 + SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS TIME)'
                           WHEN 42 --datetime2
                                  THEN 'CAST(0x07 + SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS DATETIME2)'
                           WHEN 43 --datetimeoffset
                                  THEN 'CAST(0x07 + SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS DATETIMEOFFSET)'
                           WHEN 58 --smalldatetime
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(4)) AS SMALLDATETIME)'
                           WHEN 61 --datetime
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(8)) AS DATETIME)'
                           WHEN 48 --tinyint
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS TINYINT)'
                           WHEN 52 --smallint
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(2)) AS SMALLINT)'
                           WHEN 56 --int
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(4)) AS INT)'
                           WHEN 127 --bigint
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(8)) AS BIGINT)'
                           WHEN 59 --real
                                  THEN 'CONVERT(REAL, SIGN(CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (4)) AS BIGINT)) * (1.0 + (CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (4)) AS BIGINT) & 0x007FFFFF) * POWER(CAST(2 AS REAL), - 23)) * POWER(CAST(2 AS REAL), (((CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (4)) AS BIGINT)) & 0x7F800000) / EXP(23 * LOG(2)) - 127)))'
                           WHEN 62 --float
                                  THEN 'CONVERT(FLOAT, STR(CONVERT(FLOAT, SIGN(CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (8)) AS BIGINT)) * (1.0 + (CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (8)) AS BIGINT) & 0x000FFFFFFFFFFFFF) * POWER(CAST(2 AS FLOAT), - 52)) * POWER(CAST(2 AS FLOAT), ((CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS BINARY (8)) AS BIGINT) & 0x7FF0000000000000) / EXP(52 * LOG(2)) - 1023))), 53, 8))'
                           WHEN 60 --money
                                  THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(8)) AS MONEY)'
                           WHEN 122 --smallmoney
                                   THEN 'CAST(CAST(REVERSE(SUBSTRING(FLC, ' + SP + ', ' + ML + ')) AS VARBINARY(4)) AS SMALLMONEY)'
                           WHEN 106 --decimal
                                  THEN 'CAST(CAST(' + P + ' AS BINARY (1)) + CAST(' + S + ' AS BINARY (1)) + 0x00 + CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS BINARY (9)) AS DECIMAL(' + P + ', ' + S + '))'
                           WHEN 108 --numeric
                                  THEN 'CAST(CAST(' + P + ' AS BINARY (1)) + CAST(' + S + ' AS BINARY (1)) + 0x00 + CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS BINARY (17)) AS NUMERIC(' + p + ', ' + S + '))'
                           WHEN 104 --bit
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') % 2 AS BIT)'
                           WHEN 173 --binary
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS BINARY (' + ML + '))'
                           WHEN 175 --char
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS CHAR(' + ML + '))'
                           WHEN 239 --nchar
                                  THEN 'CAST(SUBSTRING(FLC, ' + SP + ', ' + ML + ') AS NCHAR(' + CAST(ML / 2 AS VARCHAR) + '))'
                           WHEN 189 --timestamp
                                  THEN 'SUBSTRING(FLC, ' + SP + ', ' + ML + ')'
                           WHEN 34 --image
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  )'
                           WHEN 35 --text
                                  --THEN  'SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  )'
                                  THEN '
(SELECT CONVERT(VARCHAR(MAX), SUBSTRING([RowLog Contents 0], 21, CAST(CAST(REVERSE(SUBSTRING([RowLog Contents 0], 15, 2)) AS BINARY (2)) AS INTEGER)))
FROM sys.fn_dblog(NULL, NULL)
WHERE Operation = ''LOP_DELETE_ROWS''
       AND context = ''LCX_TEXT_MIX''
       AND [Transaction ID] = TID
       AND [Slot ID] = 2
       AND [Page ID] = REPLACE(CONVERT(VARCHAR, CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  ), 13, 2)) AS BINARY (2)), 1) + '':'' + CONVERT(VARCHAR, CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  ), 9, 4)) AS BINARY (4)), 1), ''0x'', ''''))
'
                           WHEN 98 --sql_variant
                                  THEN '
                                  CASE
                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 36
                                  THEN CAST(CAST(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),3,16) AS UNIQUEIDENTIFIER) AS SQL_VARIANT)
                                 
                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 56
                                  THEN CAST(CAST(CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),3,4)) AS VARBINARY(4)) AS INT) AS SQL_VARIANT)


                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP +
                                         '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 61
                                  THEN CAST(CAST(CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),3,8)) AS VARBINARY(8)) AS DATETIME) AS SQL_VARIANT)

                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 108
                                  THEN CAST(CAST(CAST(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),3,1) AS BINARY (1)) + CAST(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP +
                                         ' )     ),4,1) AS BINARY (1)) + 0x00 + CAST(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),5,8016) AS BINARY (17)) AS NUMERIC(38,20)) AS SQL_VARIANT)

                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 165
                                  THEN CAST(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),11,8016) AS SQL_VARIANT)

                                  WHEN SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),1,1) = 167
                                  THEN CAST(CONVERT(VARCHAR(8000),(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP +
                                         '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     ),9,8016)),2) AS SQL_VARIANT)
                                  END '
                           WHEN 99 --ntext
                                  THEN '
                                         (SELECT CONVERT(NVARCHAR(MAX), SUBSTRING([RowLog Contents 0], 21, CAST(CAST(REVERSE(SUBSTRING([RowLog Contents 0], 15, 2)) AS BINARY (2)) AS INTEGER)))
                                         FROM sys.fn_dblog(NULL, NULL)
                                         WHERE Operation = ''LOP_DELETE_ROWS''
                                                AND context = ''LCX_TEXT_MIX''
                                                AND [Transaction ID] = TID
                                                AND [Slot ID] = 3
                                                AND [Page ID] = REPLACE(CONVERT(VARCHAR, CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  ), 13, 2)) AS BINARY (2)), 1) + '':'' + CONVERT(VARCHAR, CAST(REVERSE(SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,   16  ), 9, 4)) AS BINARY (4)), 1), ''0x'', ''''))
                                         '
                           WHEN 128 --hierarchyid
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ' )     )'
                           WHEN 129 --geometry
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '    ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -   (' + @VSP + ' )    )'
                           WHEN 130 --geography
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')     )'
                           WHEN 165 --varbinary
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')     )'
                           WHEN 167 --varchar
                                  THEN 'CASE WHEN ' + ML + ' = -1 AND SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')      ) ,1,8) = 0x0400000001000000
                                                THEN
                                                       STUFF(( SELECT  CAST([RowLog Contents 1] AS VARCHAR(MAX)) [text()]
                                                       FROM sys.fn_dblog(NULL, NULL)
                                                       WHERE [Transaction ID] = TID
                                                              AND Context = ''LCX_TEXT_MIX''
                                                              AND Operation = ''LOP_MODIFY_ROW''
                                                              AND convert(varchar(max),SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP +
                                         ')      ) ,9,8000),2) like ''%'' + convert(varchar,convert(binary(4),reverse(CONVERT(BINARY(4),SUBSTRING([Page ID],6,8),2))),2) + convert(varchar,convert(binary(2),reverse(CONVERT(BINARY(2),SUBSTRING([Page ID],1,4),2))),2) + ''%''
                                                       ORDER BY [Current LSN]
                                                       FOR XML PATH(''''),TYPE).value(''.'', ''VARCHAR(MAX)''), 1, 2, '' '')
                                                ELSE CAST(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')      ) AS VARCHAR(MAX))
                                         END '
                           WHEN 231 --nvarchar
                                  THEN 'CASE WHEN ' + ML + ' = -1 AND SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')      ) ,1,8) = 0x0400000E01000000
                                                THEN                                                  
                                                       STUFF(( SELECT  CAST([RowLog Contents 1] AS nVARCHAR(MAX)) [text()]
                                                       FROM sys.fn_dblog(NULL, NULL)
                                                       WHERE [Transaction ID] = TID
                                                              AND Context = ''LCX_TEXT_MIX''
                                                              AND Operation = ''LOP_MODIFY_ROW''
                                                              AND convert(nvarchar(max),SUBSTRING(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP +
                                         ')      ) ,9,8000),2) like ''%'' + convert(nvarchar,convert(binary(4),reverse(CONVERT(BINARY(4),SUBSTRING([Page ID],6,8),2))),2) + convert(nvarchar,convert(binary(2),reverse(CONVERT(BINARY(2),SUBSTRING([Page ID],1,4),2))),2) + ''%''
                                                       ORDER BY [Current LSN]
                                                       FOR XML PATH(''''),TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 2, '' '')
                                                ELSE CAST(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -  ( ' + @VSP + ')      ) AS NVARCHAR(MAX))
                                         END '
                           WHEN 241 --xml
                                  THEN 'SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) - ( ' + @VSP + ' )     )'
                           WHEN 256 --sysname
                                  THEN 'CAST(SUBSTRING(LG,   1 + ' + @VSP + '     ,    CAST(CAST(REVERSE(CONVERT(BINARY(2),SUBSTRING(VLO, 4 * ' + SE + ' + 1 ,4),2)) AS BINARY(2)) AS INT) -   (' + @VSP + ' )     ) AS SYSNAME)'
                           END + 'END AS ' + N + ', ' + CHAR(10) + CHAR(13)
                     ,@VSP = CASE
                           WHEN UTI IN (
                                         34
                                         ,35
                                         ,99
                                         )
                                  THEN @VSP + ' + 16 '
                           ELSE @VSP
                           END
                     ,@BlobData = CASE
                           WHEN UTI IN (
                                         34
                                         ,35
                                         ,99
                                         )
                                  THEN 1
                           WHEN UTI IN (
                                         34
                                         ,35
                                         ,98
                                         ,99
                                         ,128
                                         ,129
                                         ,130
                                         ,165
                                         ,167
                                         ,231
                                         ,241
                                         ,256
                                         )
                                  THEN 0
                           ELSE @BlobData
                           END
              FROM #FLC
              ORDER BY CI

              SET @FetchData = LEFT(@FetchData, LEN(@FetchData) - 4)
              SET @FetchData += ' FROM cteTL
              ORDER BY [Begin Time]'

              SELECT @FetchData

              EXECUTE (@FetchData)
       END TRY

       BEGIN CATCH
              SELECT ERROR_MESSAGE()
       END CATCH
END