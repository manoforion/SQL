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
CREATE FUNCTION [dbo].[DB_MAN_ReadfileAsString]
(
@Path_Filename VARCHAR(100)
)
RETURNS 
 Varchar(max)
AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
		@Chunk Varchar(8000),
		@String varchar(max),
	    @hr int,
		@YesOrNo int

Select @String=''
select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@Path_Filename+'"',@command=@Path_Filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile', @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@Path_Filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@Path_Filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Read', @chunk OUTPUT,4000
	SELECT @String=@string+@chunk
	end
if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@Path_Filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	select @String=@strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	RETURN @string
END
