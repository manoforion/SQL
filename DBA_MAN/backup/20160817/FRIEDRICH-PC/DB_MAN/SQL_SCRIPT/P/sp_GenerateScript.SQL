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

CREATE PROC sp_GenerateScript (
  @server varchar(30) = null,
  @uname varchar(30) = null,
  @pwd varchar(30) = null,
  @dbname varchar(30) = null,
  @filename varchar(200) = 'c:\script.sql'
)
AS

DECLARE @object int
DECLARE @hr int
DECLARE @return varchar(200)
DECLARE @exec_str varchar(200)
DECLARE @tbname varchar(30)

SET NOCOUNT ON

-- Set the server to the local server
IF @server is NULL
  SELECT @server = @@servername

-- Set the database to the current database
IF @dbname is NULL
  SELECT @dbname = db_name()

-- Create an object that points to the SQL Server
EXEC @hr = sp_OACreate 'SQLDMO.SQLServer', @object OUT
IF @hr <> 0
BEGIN
  EXEC sp_displayoaerrorinfo @object, @hr
  RETURN
END

-- Connect to the SQL Server
IF (@uname is NULL) AND (@pwd is NULL)
  BEGIN
    -- Windows NT Authentication mode is used
    EXEC @hr = sp_OAMethod @object, 'Connect', NULL,  @server
    IF @hr <> 0
      BEGIN
        EXEC sp_displayoaerrorinfo @object, @hr
        RETURN
      END
  END
ELSE
IF (@uname is NULL)
  BEGIN
    -- Set the username to the current user name
    SELECT @uname = SYSTEM_USER
    EXEC @hr = sp_OAMethod @object,'Connect',NULL,@server,@uname,@pwd
    IF @hr <> 0
      BEGIN
        EXEC sp_displayoaerrorinfo @object, @hr
        RETURN
      END
  END
ELSE
IF (@pwd is NULL)
  BEGIN
    EXEC @hr = sp_OAMethod @object, 'Connect', NULL,  @server, @uname
    IF @hr <> 0
      BEGIN
        EXEC sp_displayoaerrorinfo @object, @hr
        RETURN
      END
  END
ELSE
  BEGIN
    EXEC @hr = sp_OAMethod @object,'Connect',NULL,@server,@uname,@pwd
    IF @hr <> 0
      BEGIN
        EXEC sp_displayoaerrorinfo @object, @hr
        RETURN
      END
  END

-- Verify the connection
EXEC @hr = sp_OAMethod @object, 'VerifyConnection', @return OUT
IF @hr <> 0
BEGIN
  EXEC sp_displayoaerrorinfo @object, @hr
  RETURN
END

SET @exec_str = 'DECLARE script_cursor CURSOR FOR SELECT name FROM '
              + @dbname + '..sysobjects WHERE type = ''U'' ORDER BY Name'
EXEC (@exec_str)

OPEN script_cursor
FETCH NEXT FROM script_cursor INTO @tbname
WHILE (@@fetch_status <> -1)
BEGIN
  SET @exec_str = 'Databases("'+ @dbname +'").Tables("'
                  + RTRIM(UPPER(@tbname))+'").Script(74077,"'
                  + @filename +'")'
  EXEC @hr = sp_OAMethod @object, @exec_str, @return OUT
  IF @hr <> 0
    BEGIN
      EXEC sp_displayoaerrorinfo @object, @hr
      RETURN
    END
  FETCH NEXT FROM script_cursor INTO @tbname
END
CLOSE script_cursor
DEALLOCATE script_cursor

-- Destroy the object
EXEC @hr = sp_OADestroy @object
IF @hr <> 0
BEGIN
  EXEC sp_displayoaerrorinfo @object, @hr
  RETURN
END
