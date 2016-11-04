CREATE PROCEDURE [dbo].[DB_MAN_TEMPLATE_MAIL]

   (
            @TO as varchar (128),
            @CC as varchar (128),
            @asunto as varchar (128),
            @GLOSA as Varchar (max),
            @Notificacion as Varchar (1024),
            @incrustado as varchar (max),
            @firma as varchar (512)

   )

AS

declare @SQL as varchar( max)
declare @TEMP as varchar( 512)

SET @TEMP = 'e:\friedrich\envia.bat'
EXEC master.. xp_CMDShell @TEMP, no_output

set @SQL= ''
set @SQL= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' + CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<html xmlns="http://www.w3.org/1999/xhtml">' + CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<head>' + CHAR( 13)+CHAR (10)
set @SQL= @SQL + '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' + CHAR (13)+ CHAR(10 )
set @SQL= @SQL + '<title>Notificacion</title>' + CHAR (13)+ CHAR(10 )
set @SQL= @SQL + '<style>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'div{'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'margin: 2em 0;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'height: 600px;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '/*text-align:center;*/'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'padding: 10px;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'width: 60%;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'border: #FF9900 solid 2px;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '.border1{'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '-moz-border-radius: 1em;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '-webkit-border-radius: 1em;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'border-radius: 1em;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'div.scroll'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '{'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'width:770px;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'height:250px;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'overflow-y:scroll;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'overflow-x:hidden;'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'h1 {text-align:center;}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'p.date {text-align:right;}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + 'p.main {text-align:justify;}'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</style>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</head>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<body>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<div class="border1">' + CHAR (13)+ CHAR(10 )
set @SQL= @SQL + '<table>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<img src="http://mantenciones.vitamina.cl:8080/css/identity/sysaid_logo.png">'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<tr><td><br/>'+@GLOSA +'</td></tr>'+ CHAR( 13)+CHAR (10)
set @SQL= @SQL + '<tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<div class="scroll">' + CHAR (13)+ CHAR(10 )
set @SQL= @SQL + '<p class="main">'+ CHAR(13 )+CHAR( 10)

set @SQL= @SQL + ''+@incrustado +''+ CHAR( 13)+CHAR (10)

set @SQL= @SQL + '</p>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</div>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + ''+@Notificacion +''+ CHAR( 13)+CHAR (10)
set @SQL= @SQL + '</td>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '<tr><td><br/>Saludos <br/>' +@firma+ '</td></tr>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</table>'+ CHAR(13 )+CHAR( 10)

set @SQL= @SQL + '</div>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</body>'+ CHAR(13 )+CHAR( 10)
set @SQL= @SQL + '</html>'+ CHAR(13 )+CHAR( 10)

exec [DBA_MAN_WriteStringToFile] @SQL, 'e:\friedrich\','mail.html'


EXEC msdb.. sp_send_dbmail
@profile_name='Profile_Reporte' ,
@recipients = @TO ,
--@blind_copy_recipients ='friedrich@vitamina.com',
@copy_recipients =@CC ,
@subject=@asunto ,
@body_format = 'HTML',
@file_attachments  = 'E:\Friedrich\mail.html' ,
@body=@SQL

/* SET NOCOUNT ON */
   RETURN