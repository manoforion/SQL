USE [DB_MAN]
GO
/****** Object:  StoredProcedure [dbo].[DB_MAN_WriteStringToFile]    Script Date: 02-08-2016 16:08:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[DB_MAN_WriteStringToFile]
 (
	@String Varchar( max), --8000 in SQL Server 2000
	@FileAndPath VARCHAR(555)
)
AS
DECLARE  @objFileSystem int
        ,@objTextStream int ,
            @objErrorObject int,
            @strErrorMessage Varchar(1000 ),
          @Command varchar(1000 ),
          @hr int

set nocount on

select @strErrorMessage= 'opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

if @HR= 0 Select @objErrorObject =@objFileSystem , @strErrorMessage='Creating file "'+ @FileAndPath+'"'
if @HR= 0 execute @hr = sp_OAMethod   @objFileSystem   , 'CreateTextFile'
       , @objTextStream OUT , @FileAndPath, 2,True

if @HR= 0 Select @objErrorObject =@objTextStream,
      @strErrorMessage ='writing to the file "'+ @FileAndPath+'"'
if @HR= 0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String

if @HR= 0 Select @objErrorObject =@objTextStream, @strErrorMessage='closing the file "'+ @FileAndPath+'"'
if @HR= 0 execute @hr = sp_OAMethod  @objTextStream, 'Close'

if @hr<> 0
       begin
       Declare
            @Source varchar(255 ),
            @Description Varchar(255 ),
            @Helpfile Varchar(255 ),
            @HelpID int

       EXECUTE sp_OAGetErrorInfo  @objErrorObject,
            @source output,@Description output,@Helpfile output,@HelpID output
       Select @strErrorMessage= 'Error whilst '
                   +coalesce( @strErrorMessage,'doing something' )
                   +', '+ coalesce(@Description ,'')
       raiserror ( @strErrorMessage,16 ,1)
       end
EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objTextStream
