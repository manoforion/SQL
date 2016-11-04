drop Function DB_MAN_Clean_Space
go
create Function DB_MAN_Clean_Space
	(
		@string varchar(1000)
	)
Returns Varchar (1000)
as
BEGIN
	--DECLARE @TestString AS VARCHAR(20)
	--SET @TestString = 'Test   String   fuck'
	--To remove the extra spaces we need to use
	SET @string= REPLACE(REPLACE(REPLACE(@string,' ',' %'),'% ',''),'%','')
	return @string

END

select dbo.DB_MAN_Clean_Space('hola    como     estas ') as salida