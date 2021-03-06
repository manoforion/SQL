/*
SELECT dbo.DB_MAN_SplitIndex(';', 'hola;como;estas', 2)
*/

CREATE FUNCTION [dbo].[DB_MAN_SplitIndex]
	(
		@Delimiter varchar(20) = ' ', 
		@Search varchar(max), 
		@index int
	)
  RETURNS varchar(max)
  AS
  BEGIN
  DECLARE @ix int,
  @pos int,
  @rt varchar(max)

  DECLARE @tb TABLE (Val varchar(max), id int identity(1,1))

  SET @ix = 1
  SET @pos = 1

  WHILE @ix <= LEN(@search) + 1 BEGIN

  SET @ix = CHARINDEX(@Delimiter, @Search, @ix)

  IF @ix = 0
  SET @ix = LEN(@Search)
  ELSE
  SET @ix = @ix - 1

  INSERT INTO @tb
  SELECT SUBSTRING(@Search, @pos, @ix - @pos + 1)

  SET @ix = @ix + 2
  SET @pos = @ix
  END

  SELECT @Rt = Val FROM @Tb WHERE id = @index
  RETURN @Rt
  END