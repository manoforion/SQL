alter PROCEDURE spHTMLtidy
 (
  @Before varchar(MAX),--max in SQL 2005, 8000 in SQL 2000
  @After varchar (MAX) output,--max in SQL 2005, 8000 in SQL 2000
  @Messages Varchar(MAX) output,--max in SQL 2005, 8000 in SQL 2000
--and now the HTML Tidy Switches. Change these to get the formatting you wish
  @Switches varchar(MAX)=
'
accessibility-check: 0
add-xml-decl: yes
add-xml-space: no
alt-text: image
ascii-chars: yes
assume-xml-procins: no
bare: no
break-before-br: yes
char-encoding: ascii
clean: no
css-prefix: c
decorate-inferred-ul: yes
doctype: auto
drop-empty-paras: yes
drop-font-tags: no
drop-proprietary-attributes: no
enclose-block-text: no
enclose-text: no
escape-cdata: no
fix-backslash: yes
fix-bad-comments: yes
fix-uri: no
force-output: yes
gnu-emacs: no
hide-comments: no
hide-endtags: no
indent: yes
indent-attributes: no
indent-cdata: no
indent-spaces: 2
input-encoding: latin1
input-xml: no
join-classes: no
join-styles: yes
keep-time: yes
language
literal-attributes: no
logical-emphasis: no
lower-literals: no
markup: yes
merge-divs: auto
ncr: yes
new-blocklevel-tags
new-empty-tags
new-inline-tags
new-pre-tags
newline
numeric-entities: no
output-bom: auto
output-encoding: ascii
output-html: no
output-xhtml: yes
output-xml: no
preserve-entities
punctuation-wrap: no
quiet: yes
quote-ampersand: yes
quote-marks: no
quote-nbsp: yes
repeated-attributes: keep-last
replace-color: no
show-body-only: no
show-errors: 6
show-warnings: yes
slide-style: -
split: no
tab-size: 4
tidy-mark: no
uppercase-attributes: no
uppercase-tags: no
vertical-space: no
word-2000: no
wrap: 80
wrap-asp: no
wrap-attributes: no
wrap-jste: no
wrap-php: no
wrap-script-literals: no
wrap-sections: yes
write-back: no


'
) 
/*Declare @ProcessedFile varchar(max)
Declare @Messages varchar(max)
Declare @UnprocessedFile varchar(max)
Select @UnprocessedFile = '<html>
<head	<title>awful HTML</head>
<body>
<p>This is my first real HTML<br><div>
<table><tr><th>What a mess</tr>
<tr><td></td>this is supposed to be in the table</tr><td></td>
<tr>this is awful<td>and this is a line</td></tr>
</table>
</body>
</html>
'

Execute spHTMLtidy @UnprocessedFile, @processedFile output, @Messages output
Select [before]=@unprocessedFile
Select [after]=@ProcessedFile
Select [messages]=@Messages

*/
AS
DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objFolder int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@filename varchar(80),
		@ToFilename Varchar(80),
		@ConfigFilename Varchar(80),
		@Path varchar(255),
		@Chunk Varchar(8000),
		@YesOrNo int,
		@Bucket int
set nocount on
Select @filename='', @path=''
select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Getting the temporary folder'
if @HR=0 execute @hr = sp_OAGetProperty   @objFileSystem  , 'GetSpecialFolder(2)'
	, @objFolder OUT

if @HR=0 Select @strErrorMessage='Getting the temporary filename'
if @HR=0 execute @hr = sp_OAGetProperty   @objFileSystem  , 'GetTempName'
	, @filename OUT

if @HR=0 Select @strErrorMessage='Getting the temporary output filename'
if @HR=0 execute @hr = sp_OAGetProperty   @objFileSystem  , 'GetTempName'
	, @Tofilename OUT

if @HR=0 Select @strErrorMessage='Getting the temporary config filename'
if @HR=0 execute @hr = sp_OAGetProperty   @objFileSystem  , 'GetTempName'
	, @Configfilename OUT

--write the pre-processed HTML/XML to disk

if @HR=0 Select @objErrorObject=@objfolder, @strErrorMessage='Creating file "'+@Filename+'"'
if @HR=0 execute @hr = sp_OAMethod   @objFolder  , 'CreateTextFile'
	, @objTextStream OUT, @Filename,2,True

if @HR=0 Select @objErrorObject=@objFolder, @strErrorMessage='getting the path name'
if @HR=0 execute @hr = sp_OAGetProperty   @objFolder  , 'Path'
	, @path OUT

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@Filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @Before

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@Filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'

--now write the config file to disk

if @HR=0 Select @objErrorObject=@objfolder, @strErrorMessage='Creating file "'+@ConfigFilename+'"'
if @HR=0 execute @hr = sp_OAMethod   @objFolder  , 'CreateTextFile'
	, @objTextStream OUT, @ConfigFilename,2,True

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@ConfigFilename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @Switches

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@ConfigFilename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


--lets do this in a way that gets the output

create table #output (line varchar(2000))
--select @command='type '+@path+'\'+@filename+'|tidy>'+@path+'\'+@Tofilename+' -config '+@path+'\'+@Configfilename+''
select @command='tidy -config '+@path+'\'+@Configfilename+' '+@path+'\'+@filename+'>'+@path+'\'+@Tofilename+''
if @HR=0  
	insert into #output
		execute master..xp_cmdshell @command

select @Messages=Coalesce(@Messages,'')+coalesce(line,'') from #output where line is not null

if @HR=0 
	Select @objErrorObject=
		@objFileSystem, 
		@strErrorMessage='Opening file "'+@path+'\'+@Tofilename+'"',
		@command=@path+'\'+@ToFilename


if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

Select @After=''
WHILE @hr=0
	BEGIN --this is chunked to fix a bug in some OS versions
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT
	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, @Chunk='',
		@strErrorMessage='reading chunk from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Read', @chunk OUTPUT,4000
	if @HR=0 SELECT @After=@After+@chunk
	end

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@ToFilename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'
--delete the output file
if @HR=0 Select @objErrorObject=@objFileSystem, 
	@strErrorMessage='deleting the file"'+@path+'\'+@ToFilename+'"',
	@command=@path+'\'+@ToFilename
if @HR=0 
	execute @hr = sp_OAMethod @objFileSystem, 'Deletefile',null, @command

--delete the config file
if @HR=0 Select @objErrorObject=@objFileSystem, 
	@strErrorMessage='deleting the file"'+@path+'\'+@ConfigFilename+'"',
	@command=@path+'\'+@ConfigFilename
if @HR=0 
	execute @hr = sp_OAMethod @objFileSystem, 'Deletefile',null, @command


--and finally, the input file
if @HR=0 Select @objErrorObject=@objFileSystem, 
	@strErrorMessage='deleting the file"'+@path+'\'+@Filename+'"',
	@command=@path+'\'+@Filename
if @HR=0 
	execute @hr = sp_OAMethod @objFileSystem, 'Deletefile',null, @command

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
	raiserror (@strErrorMessage,16,1)
	end
EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objTextStream
