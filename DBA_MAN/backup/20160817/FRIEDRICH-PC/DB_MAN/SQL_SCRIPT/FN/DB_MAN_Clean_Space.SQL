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
