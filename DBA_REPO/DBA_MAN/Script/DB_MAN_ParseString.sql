/* Let's create our parsing function... */
IF EXISTS ( SELECT  [object_id]
            FROM    sys.objects
            WHERE   name = 'DB_MAN_ParseString' )
    DROP FUNCTION dbo.DB_MAN_ParseString;
GO

CREATE FUNCTION dbo.DB_MAN_ParseString
(
          @stringToParse VARCHAR(8000)
        , @delimiter     CHAR(1)
)
RETURNS @parsedString TABLE (stringValue VARCHAR(128))
AS
/*********************************************************************************
Usage:
    SELECT *
    FROM DB_MAN_ParseString(<string>, <delimiter>);

Test Cases:

    1.  multiple strings separated by space
        SELECT * FROM dbo.DB_MAN_ParseString('  aaa  bbb  ccc ', ' ');

    2.  multiple strings separated by comma
        SELECT * FROM dbo.DB_MAN_ParseString(',aaa,bbb,,,ccc,', ',');
*********************************************************************************/
BEGIN

    /* Declare variables */
    DECLARE @trimmedString  VARCHAR(8000);

    /* We need to trim our string input in case the user entered extra spaces */
    SET @trimmedString = LTRIM(RTRIM(@stringToParse));

    /* Let's create a recursive CTE to break down our string for us */
    WITH parseCTE (StartPos, EndPos)
    AS
    (
        SELECT 1 AS StartPos
            , CHARINDEX(@delimiter, @trimmedString + @delimiter) AS EndPos
        UNION ALL
        SELECT EndPos + 1 AS StartPos
            , CHARINDEX(@delimiter, @trimmedString + @delimiter , EndPos + 1) AS EndPos
        FROM parseCTE
        WHERE CHARINDEX(@delimiter, @trimmedString + @delimiter, EndPos + 1) <> 0
    )

    /* Let's take the results and stick it in a table */
    INSERT INTO @parsedString
    SELECT SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)
    FROM parseCTE
    WHERE LEN(LTRIM(RTRIM(SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)))) > 0
    OPTION (MaxRecursion 8000);

    RETURN;
END
GO

