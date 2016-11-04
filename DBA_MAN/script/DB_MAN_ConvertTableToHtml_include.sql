CREATE PROCEDURE [dbo]. [DB_MAN_ConvertTableToHtml_include](
      @SqlQuery AS NVARCHAR (4000),
      @Html AS VARCHAR (MAX) OUTPUT
)

/***ejemplo ***/
/*
DECLARE @Html AS VARCHAR(MAX)
EXECUTE DB_MAN_ConvertTableToHtml_include 'select * from db_man.dbo.Db_Man_Config ',@Html OUTPUT
print @Html
*/
AS

      DECLARE @Header AS NVARCHAR( MAX)
      DECLARE @Column AS NVARCHAR( MAX)
      DECLARE @Query AS NVARCHAR( MAX)
      DECLARE @temp as varchar( MAX)
      DECLARE @Css AS VARCHAR( MAX)
      set @Header= ''
      set @Column= ''
      Set @temp= ''
      SET @Css= '
            <style type="text/css">

            table.gridtable {
                font-family: verdana,arial,sans-serif;
                font-size:11px;
                color:#333333;
                border-width: 1px;
                border-color: #666666;
                border-collapse: collapse;
            }

            table.gridtable th {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #666666;
                background-color: #dedede;
            }

            table.gridtable td {
                border-width: 1px;
                padding: 8px;
                border-style: solid;
                border-color: #666666;
                background-color: #ffffff;
            }

            </style>
            '
BEGIN
        SET @SqlQuery = REPLACE (@SqlQuery, '|','''' )
      SET @Query = 'SELECT * INTO ##columns FROM ( ' + @SqlQuery + ') Temp'
      EXECUTE(@Query )

      SELECT @Column = @Column + 'ISNULL(' + QUOTENAME( name) +' ,'' '')' + ' AS TD, '
      FROM tempdb. SYs.columns
      WHERE object_id = OBJECT_ID('tempdb..##columns' )

      SET  @Column = LEFT(@Column ,LEN( @Column)-1 )

      SELECT @Header = @Header + '<TH>' +   name + '</TH>'
      FROM tempdb. SYs.columns
      WHERE object_id = OBJECT_ID('tempdb..##columns' )

      SET @Header = '<TR>' + @Header  + '</TR>'

      SET @Query = 'SET  @Html = (SELECT ' + @Column + ' FROM ( ' + @SqlQuery + ') AS TR
       FOR XML AUTO ,ROOT(''TABLE''), ELEMENTS)'

      EXECUTE SP_EXECUTESQL @Query,N'@Html VARCHAR(MAX) OUTPUT',@Html OUTPUT
	  

      SET  @temp = @Css + REPLACE(@Html ,'<TABLE>' ,'<TABLE  style="width: 100%;" class="gridtable">' + @Header)

       --set @temp = ISNULL(@temp,0)

        --if @temp=0
             --SET  @Html ='No informacion Disponible'
        --else
             SET  @Html = @temp


      DROP TABLE ##columns

END